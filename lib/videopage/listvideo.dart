import 'package:flutter/material.dart';
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
        // LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // ERROR
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Terjadi kesalahan: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // DATA KOSONG
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Video tidak tersedia',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final videos = snapshot.data!;

        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];

            return ListTile(
              // ▶️ KLIK VIDEO
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerPage(
                      videoUrl: video.videoUrl,
                      title: video.title,
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
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 40,
                        color: Colors.grey.shade700,
                        child: const Icon(Icons.broken_image,
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      color: Colors.black.withOpacity(0.3),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
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

              subtitle: Text(
                '${video.views} views',
                style: const TextStyle(color: Colors.grey),
              ),

              trailing: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            );
          },
        );
      },
    );
  }
}
