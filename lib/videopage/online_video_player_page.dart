import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnlineVideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const OnlineVideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<OnlineVideoPlayerPage> createState() => _OnlineVideoPlayerPageState();
}

class _OnlineVideoPlayerPageState extends State<OnlineVideoPlayerPage> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            controller.value.isPlaying
                ? controller.pause()
                : controller.play();
            setState(() {});
          },
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
