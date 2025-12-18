import 'package:flutter/material.dart';
import '../../services/pixabay_services.dart';
import '../../models/video_model.dart';
import 'online_video_player_page.dart';

class OnlineVideoPage extends StatelessWidget {
  const OnlineVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoModel>>(
      future: PixabayService().fetchVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final videos = snapshot.data!;
        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];

            return ListTile(
              leading: Image.network(
                video.thumbnail,
                width: 80,
                fit: BoxFit.cover,
              ),
              title: Text(
                video.title,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "${video.views} views",
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnlineVideoPlayerPage(videoUrl: video.videoUrl),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
