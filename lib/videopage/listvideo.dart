import 'package:flutter/material.dart';
import 'video_player_page.dart';

class VideoList extends StatelessWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 40,
              color: Colors.grey.shade700,
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),
          title: const Text(
            "Sample Offline Video",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            "assets/videos/sample2.mp4",
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VideoPlayerPage(
                  videoPath: 'assets/videos/sample2.mp4',
                  isAsset: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
