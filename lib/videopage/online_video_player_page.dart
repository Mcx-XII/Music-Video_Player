import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnlineVideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String videoTitle; // tambahkan ini

  const OnlineVideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.videoTitle, // required
  });

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
        automaticallyImplyLeading: false, // kita buat custom back button
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.videoTitle, // pakai judul asli
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
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
