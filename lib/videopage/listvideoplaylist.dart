import 'package:flutter/material.dart';
import '../models/playlist_group_model.dart';
import '../services/playlist_storage_service.dart';
import 'online_video_player_page.dart';

class ListVideoPlaylist extends StatefulWidget {
  const ListVideoPlaylist({super.key});

  @override
  State<ListVideoPlaylist> createState() => _ListVideoPlaylistState();
}

class _ListVideoPlaylistState extends State<ListVideoPlaylist> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlaylistGroup>>(
      future: PlaylistStorageService.getVideoGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final groups = snapshot.data ?? [];
        if (groups.isEmpty) {
          return const Center(child: Text("Belum ada grup playlist", style: TextStyle(color: Colors.white54)));
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ExpansionTile(
              leading: const Icon(Icons.folder, color: Colors.amber),
              title: Text(group.name, style: const TextStyle(color: Colors.white)),
              children: group.videos.map((video) => ListTile(
                leading: Image.network(video.thumbnail, width: 50, fit: BoxFit.cover),
                title: Text(video.title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => OnlineVideoPlayerPage(videoList: group.videos, initialIndex: group.videos.indexOf(video)),
                  ));
                },
              )).toList(),
            );
          },
        );
      },
    );
  }
}