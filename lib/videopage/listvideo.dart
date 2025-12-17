import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../models/video_model.dart';
import '../services/pixabay_services.dart';
import 'video_player_page.dart';

class VideoList extends StatelessWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoModel>>(
      future: PixabayService().fetchVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final apiVideos = snapshot.data!;

        // 🔥 KONVERSI API → VideoItem
        final videos = apiVideos.map((v) {
          return VideoItem(
            title: v.title,
            videoUrl: v.videoUrl,
            thumbnail: v.thumbnail,
          );
        }).toList();

        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];

            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerPage(
                      videos: videos,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnail,
                      width: 60,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      color: Colors.black.withOpacity(0.3),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ],
                ),
              ),
              title: Text(
                video.title,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.more_vert, color: Colors.white),
            );
          },
        );
      },
    );
  }
}
