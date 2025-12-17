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
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        // error
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final videos = snapshot.data!;

        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];

            return ListTile(
              // 🔥 INI BAGIAN PENTING (KLIK VIDEO)
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerPage(
                      videoUrl: video.videoUrl, // URL video dari API
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
