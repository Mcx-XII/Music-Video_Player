import 'package:flutter/material.dart';
import '../models/audio_model.dart';
import '../services/playlist_storage_service.dart';
import 'online_audio_player_page.dart';

class AudioPlaylistPage extends StatefulWidget {
  const AudioPlaylistPage({super.key});

  @override
  State<AudioPlaylistPage> createState() => _AudioPlaylistPageState();
}

class _AudioPlaylistPageState extends State<AudioPlaylistPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioModel>>(
      // Memanggil fungsi pengambil data dari service yang kita buat
      future: PlaylistStorageService.getAudioPlaylist(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final playlist = snapshot.data ?? [];

        if (playlist.isEmpty) {
          return const Center(
            child: Text("Playlist Musik kosong", style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            final audio = playlist[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(audio.coverUrl),
              ),
              title: Text(audio.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(audio.artist, style: const TextStyle(color: Colors.white54)),
              onTap: () {
                // Berpindah ke player dengan mengirim seluruh list agar bisa Next/Prev
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnlineAudioPlayerPage(
                      audioList: playlist,
                      initialIndex: index,
                    ),
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