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

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Tidak ada video ditemukan', 
            style: TextStyle(color: Colors.white)),
          );
        }

        final List<VideoModel> videos = snapshot.data!;

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
                      videos: videos, // Langsung mengirim List<VideoModel>
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
                      video.thumbnail, // Menggunakan properti dari VideoModel
                      width: 60,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.broken_image, color: Colors.white),
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      color: Colors.black.withAlpha(77), // Pengganti withOpacity
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
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