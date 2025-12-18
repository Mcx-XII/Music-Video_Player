import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

class VideoPlayerPage extends StatefulWidget {
  final AssetEntity video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? controller;
  String? videoName;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  Future<void> loadVideo() async {
    final file = await widget.video.file;
    if (file == null) return;

    videoName = file.path.split('/').last;

    controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          controller!.play();

          // ✅ FIX: Menggunakan 'addToHistory' sesuai nama di HistoryService
          HistoryService.addToHistory(
            HistoryItem(
              type: HistoryType.video,
              title: widget.video.title ?? videoName ?? 'Video Lokal',
              url: widget.video.id, // ID unik untuk media lokal
              thumbnail: '',
              assetId: widget.video.id,
              playedAt: DateTime.now(),
            ),
          );
        }
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan Loading jika video belum siap
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
        elevation: 0,
        automaticallyImplyLeading: false,
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
                widget.video.title ?? videoName ?? "Video Player",
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            if (controller != null) {
              setState(() {
                controller!.value.isPlaying
                    ? controller!.pause()
                    : controller!.play();
              });
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pemutar Video
              AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
              
              // Ikon Pause jika video sedang tidak berjalan
              if (!controller!.value.isPlaying)
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black45,
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                ),
            ],
          ),
        ),
      ),
    );
  }
}