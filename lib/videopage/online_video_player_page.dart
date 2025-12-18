import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import '../models/history_item.dart';      // Import model history
import '../services/history_service.dart'; // Import service history
import 'dart:async';

class OnlineVideoPlayerPage extends StatefulWidget {
  final List<VideoModel> videoList;
  final int initialIndex;

  const OnlineVideoPlayerPage({
    super.key,
    required this.videoList,
    required this.initialIndex,
  });

  @override
  State<OnlineVideoPlayerPage> createState() => _OnlineVideoPlayerPageState();
}

class _OnlineVideoPlayerPageState extends State<OnlineVideoPlayerPage> {
  VideoPlayerController? _controller; 
  late int currentIndex;
  bool _showControls = true;
  Timer? _hideTimer;
  String _seekNotification = "";
  bool _showSeekNotify = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initializePlayer(widget.videoList[currentIndex].videoUrl);
  }

  // Fungsi untuk inisialisasi atau ganti video
  void _initializePlayer(String url) async {
    // 1. Pastikan controller lama dibuang dengan benar
    if (_controller != null) {
      await _controller!.dispose();
      setState(() {
        _controller = null; 
      });
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      // --- LOGIKA HISTORY: OTOMATIS MENCATAT SAAT VIDEO DIMULAI ---
      final currentVideo = widget.videoList[currentIndex];
      await HistoryService.addToHistory(
        HistoryItem(
          type: HistoryType.video, // Tipe Video sesuai enum kamu
          title: currentVideo.title,
          url: currentVideo.videoUrl,
          thumbnail: currentVideo.thumbnail,
          playedAt: DateTime.now(),
        ),
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {}); 
        _controller!.play();
        _startHideTimer();
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }

    _controller!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _playNext() {
    if (currentIndex < widget.videoList.length - 1) {
      setState(() {
        currentIndex++;
      });
      _initializePlayer(widget.videoList[currentIndex].videoUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ini adalah video terakhir")),
      );
    }
  }

  void _playPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _initializePlayer(widget.videoList[currentIndex].videoUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ini adalah video pertama")),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false) && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _showSeekAnimation(String text) {
    setState(() {
      _seekNotification = text;
      _showSeekNotify = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showSeekNotify = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),

          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () {
                      _controller!.seekTo(_controller!.value.position - const Duration(seconds: 5));
                      _showSeekAnimation("-5s");
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () {
                      _controller!.seekTo(_controller!.value.position + const Duration(seconds: 5));
                      _showSeekAnimation("+5s");
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),
          ),

          if (_showSeekNotify)
            Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(50)),
                child: Text(_seekNotification, 
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),

          if (_showControls) ...[
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: Colors.black45,
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white), 
                        onPressed: () => Navigator.pop(context)
                      ),
                      Expanded(
                        child: Text(
                          widget.videoList[currentIndex].title,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 50, color: Colors.white),
                    onPressed: _playPrevious,
                  ),
                  IconButton(
                    icon: Icon(
                      _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, 
                      size: 85, color: Colors.white
                    ),
                    onPressed: () {
                      setState(() {
                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      });
                      _startHideTimer();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 50, color: Colors.white),
                    onPressed: _playNext,
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                color: Colors.black45,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.blue, 
                          bufferedColor: Colors.white30, 
                          backgroundColor: Colors.white12
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_controller!.value.position), 
                            style: const TextStyle(color: Colors.white)),
                          Text(_formatDuration(_controller!.value.duration), 
                            style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}