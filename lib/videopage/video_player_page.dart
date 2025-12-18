import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import 'dart:async';

class VideoPlayerPage extends StatefulWidget {
  final List<AssetEntity> videoList; // Menerima List
  final int initialIndex;

  const VideoPlayerPage({super.key, required this.videoList, required this.initialIndex});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  late int currentIndex;
  bool _showControls = true;
  Timer? _hideTimer;
  bool _showSeekNotify = false;
  String _seekText = "";

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initVideo();
  }

  void _initVideo() async {
    if (_controller != null) await _controller!.dispose();
    
    final asset = widget.videoList[currentIndex];
    final file = await asset.file;
    if (file == null) return;

    _controller = VideoPlayerController.file(file);
    try {
      await _controller!.initialize();
      // Simpan History
      HistoryService.addToHistory(HistoryItem(type: HistoryType.video, title: asset.title ?? 'Lokal', url: asset.id, thumbnail: '', assetId: asset.id, playedAt: DateTime.now()));
      
      if (mounted) {
        setState(() {});
        _controller!.play();
        _startTimer();
      }
    } catch (e) { debugPrint("Error: $e"); }

    _controller!.addListener(() { if (mounted) setState(() {}); });
  }

  void _startTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller!.value.isPlaying) setState(() => _showControls = false);
    });
  }

  void _seek(Duration offset, String text) {
    _controller!.seekTo(_controller!.value.position + offset);
    setState(() { _seekText = text; _showSeekNotify = true; });
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) setState(() => _showSeekNotify = false); });
  }

  @override
  void dispose() { _controller?.dispose(); _hideTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(onTap: () { setState(() => _showControls = !_showControls); if (_showControls) _startTimer(); }, child: Center(child: AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)))),
          
          // Double Tap Seek Layer
          Positioned.fill(child: Row(children: [
            Expanded(child: GestureDetector(onDoubleTap: () => _seek(const Duration(seconds: -5), "-5s"), behavior: HitTestBehavior.translucent)),
            Expanded(child: GestureDetector(onDoubleTap: () => _seek(const Duration(seconds: 5), "+5s"), behavior: HitTestBehavior.translucent)),
          ])),

          if (_showSeekNotify) Center(child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(50)), child: Text(_seekText, style: const TextStyle(color: Colors.white, fontSize: 20)))),

          if (_showControls) ...[
            // Top Bar
            Positioned(top: 0, left: 0, right: 0, child: Container(color: Colors.black45, child: SafeArea(child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              Expanded(child: Text(widget.videoList[currentIndex].title ?? "Video Lokal", style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
            ])))),

            // Middle Controls
            Center(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              IconButton(icon: const Icon(Icons.skip_previous, size: 50, color: Colors.white), onPressed: () { if (currentIndex > 0) { currentIndex--; _initVideo(); } }),
              IconButton(icon: Icon(_controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle, size: 80, color: Colors.white), onPressed: () {
                setState(() => _controller!.value.isPlaying ? _controller!.pause() : _controller!.play());
                _startTimer();
              }),
              IconButton(icon: const Icon(Icons.skip_next, size: 50, color: Colors.white), onPressed: () { if (currentIndex < widget.videoList.length - 1) { currentIndex++; _initVideo(); } }),
            ])),

            // Bottom Progress
            Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.black45, padding: const EdgeInsets.all(15), child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: [
              VideoProgressIndicator(_controller!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Colors.blueAccent)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_format(_controller!.value.position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                Text(_format(_controller!.value.duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
              ]),
            ])))),
          ]
        ],
      ),
    );
  }

  String _format(Duration d) => "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}