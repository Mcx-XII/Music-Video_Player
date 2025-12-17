import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';

class VideoPlayerPage extends StatefulWidget {
  final List<VideoItem> videos;
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

    // 🔓 ROTASI BEBAS
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _loadVideo(_currentIndex);
  }

  Future<void> _loadVideo(int index) async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videos[index].videoUrl),
    );

    await _controller.initialize();
    _controller.play();

    setState(() {});
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();

    // 🔒 BALIK KE PORTRAIT
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
      setState(() => _showControls = false);
    });
  }

  void _next() {
    if (_currentIndex < widget.videos.length - 1) {
      _currentIndex++;
      _controller.dispose();
      _loadVideo(_currentIndex);
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _controller.dispose();
      _loadVideo(_currentIndex);
    }
  }

  // 🔁 DOUBLE TAP SEEK
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
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
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
            // 🎬 VIDEO
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            // 👈 DOUBLE TAP BACKWARD
            Positioned.fill(
              left: 0,
              right: MediaQuery.of(context).size.width / 2,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: _seekBackward,
              ),
            ),

            // 👉 DOUBLE TAP FORWARD
            Positioned.fill(
              left: MediaQuery.of(context).size.width / 2,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: _seekForward,
              ),
            ),

            // 🎮 PLAY / NEXT / PREV
            if (_showControls)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white),
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
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                    ),
                    IconButton(
                      iconSize: 48,
                      icon:
                          const Icon(Icons.skip_next, color: Colors.white),
                      onPressed: _next,
                    ),
                  ],
                ),
              ),

            // ⏱ PROGRESS BAR
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_format(position),
                              style:
                                  const TextStyle(color: Colors.white)),
                          Text(_format(duration),
                              style:
                                  const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
