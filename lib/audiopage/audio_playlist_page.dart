import 'package:flutter/material.dart';
import '../models/audio_group_model.dart'; // Import model folder audio
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
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E), // Menyesuaikan tema gelap aplikasi
      body: FutureBuilder<List<AudioGroup>>(
        // Memanggil fungsi pengambil daftar folder musik dari service
        future: PlaylistStorageService.getAudioGroups(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data ?? [];

          if (groups.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada playlist musik.\nTambahkan lagu dari tab Online!", 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              
              // Menggunakan ExpansionTile agar folder bisa dibuka-tutup
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.library_music, color: Colors.pinkAccent),
                  title: Text(
                    group.name, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${group.audios.length} Lagu", 
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  children: group.audios.map((audio) {
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 32, right: 16),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(audio.coverUrl),
                      ),
                      title: Text(
                        audio.title, 
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      subtitle: Text(
                        audio.artist, 
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      onTap: () {
                        // Berpindah ke player dengan mengirim list lagu di dalam folder tersebut
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OnlineAudioPlayerPage(
                              audioList: group.audios, 
                              initialIndex: group.audios.indexOf(audio),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}