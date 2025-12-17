import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  bool _showControls = true;
  bool _showForward = false;
  bool _showBackward = false;

  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    // 🔥 PAKSA LANDSCAPE SAAT MASUK VIDEO
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // fullscreen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();

    // 🔥 BALIK NORMAL SAAT KELUAR VIDEO
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _showControls = false);
    });
  }

  void _seekForward() async {
    final pos = await _controller.position;
    if (pos == null) return;

    _controller.seekTo(pos + const Duration(seconds: 5));

    setState(() => _showForward = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _showForward = false);
    });
  }

  void _seekBackward() async {
    final pos = await _controller.position;
    if (pos == null) return;

    _controller.seekTo(pos - const Duration(seconds: 5));

    setState(() => _showBackward = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _showBackward = false);
    });
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

    final duration = _controller.value.duration;
    final position = _controller.value.position;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          details.localPosition.dx < width / 2
              ? _seekBackward()
              : _seekForward();
        },
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            if (_showBackward)
              const Positioned(
                left: 50,
                top: 0,
                bottom: 0,
                child: Icon(Icons.replay_5, size: 90, color: Colors.white),
              ),

            if (_showForward)
              const Positioned(
                right: 50,
                top: 0,
                bottom: 0,
                child: Icon(Icons.forward_5, size: 90, color: Colors.white),
              ),

            if (_showControls)
              Center(
                child: IconButton(
                  iconSize: 70,
                  color: Colors.white,
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ),

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
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_format(position),
                              style: const TextStyle(color: Colors.white)),
                          Text(_format(duration),
                              style: const TextStyle(color: Colors.white)),
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
