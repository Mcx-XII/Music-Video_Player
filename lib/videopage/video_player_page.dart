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

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  String? videoName;

  Future<void> loadVideo() async {
    final file = await widget.video.file;
    if (file == null) return;

    videoName = file.path.split('/').last;

    controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {});
        controller!.play();

        // ✅ SIMPAN RIWAYAT VIDEO LOKAL
        HistoryService.add(
          HistoryItem(
            type: HistoryType.video,
            title: widget.video.title ?? 'Video',
            url: widget.video.id,
            thumbnail: '',
            assetId: widget.video.id,
            playedAt: DateTime.now(),
          ),
        );
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
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
                videoName ?? "Video",
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
            setState(() {
              controller!.value.isPlaying
                  ? controller!.pause()
                  : controller!.play();
            });
          },
          child: AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: VideoPlayer(controller!),
          ),
        ),
      ),
    );
  }
}
