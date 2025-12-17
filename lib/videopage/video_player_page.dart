import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class VideoPlayerPage extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const VideoPlayerPage({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  late int _currentIndex;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // 🔓 Set orientasi agar bisa landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initController(_currentIndex);
  }

  Future<void> _initController(int index) async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videos[index].videoUrl),
    );

    try {
      await _controller.initialize();
      _controller.play();
      _controller.addListener(_videoListener);
      setState(() {});
      _startHideTimer();
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();

    // 🔒 Kembalikan ke portrait saat keluar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _changeVideo(int index) {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _currentIndex = index;
    _initController(_currentIndex);
  }

  void _next() {
    if (_currentIndex < widget.videos.length - 1) {
      _changeVideo(_currentIndex + 1);
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _changeVideo(_currentIndex - 1);
    }
  }

  void _seekForward() {
    final pos = _controller.value.position;
    _controller.seekTo(pos + const Duration(seconds: 5));
  }

  void _seekBackward() {
    final pos = _controller.value.position;
    _controller.seekTo(pos - const Duration(seconds: 5));
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            
            // Area Tap Kiri (Backward)
            Positioned.fill(
              right: MediaQuery.of(context).size.width / 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: _seekBackward,
              ),
            ),

            // Area Tap Kanan (Forward)
            Positioned.fill(
              left: MediaQuery.of(context).size.width / 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: _seekForward,
              ),
            ),

            if (_showControls) ...[
              // Tombol Back
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Kontrol Tengah
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      onPressed: _previous,
                    ),
                    IconButton(
                      iconSize: 70,
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: _next,
                    ),
                  ],
                ),
              ),

              // Progress Bar & Durasi
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black38,
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.blue,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_format(position), style: const TextStyle(color: Colors.white)),
                            Text(_format(duration), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}