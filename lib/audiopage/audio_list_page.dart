import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../helpers/media_permission.dart';
import '../models/audio_model.dart';
import '../services/playlist_storage_service.dart';
import 'audio_player_page.dart';

class AudioListPage extends StatefulWidget {
  const AudioListPage({super.key});

  @override
  State<AudioListPage> createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  List<AssetEntity> audios = [];

  @override
  void initState() {
    super.initState();
    loadAudios();
  }

  Future<void> loadAudios() async {
    final granted = await requestMediaPermission();
    if (!granted) return;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
      onlyAll: true,
    );

    if (albums.isEmpty) return;

    final assets = await albums.first.getAssetListPaged(page: 0, size: 1000);

    setState(() {
      audios = assets;
    });
  }

  // DIALOG TAMBAH KE PLAYLIST (Sesuai UI Musik Online)
  void _showAddToPlaylistDialog(AssetEntity asset) {
    String folderName = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B52),
        title: const Text("Simpan ke Playlist Musik", style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nama Playlist Musik (Misal: Lagu Lokal)",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent)),
          ),
          onChanged: (value) => folderName = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () async {
              if (folderName.trim().isNotEmpty) {
                // Konversi AssetEntity ke AudioModel untuk disimpan
                final audioModel = AudioModel(
                  title: asset.title ?? 'Audio Lokal',
                  artist: 'Lokal',
                  audioUrl: asset.id, 
                  duration: asset.duration,
                  coverUrl: '', // Audio lokal menggunakan placeholder
                );
                await PlaylistStorageService.addAudioToGroup(folderName.trim(), audioModel);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil disimpan ke folder $folderName'),
                      backgroundColor: Colors.pinkAccent,
                    ),
                  );
                }
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E), // Latar belakang gelap
      body: audios.isEmpty
          ? const Center(
              child: Text("Tidak ada audio", style: TextStyle(color: Colors.white54)),
            )
          : ListView.builder(
              itemCount: audios.length,
              itemBuilder: (context, index) {
                final audio = audios[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  // Menggunakan CircleAvatar agar sama dengan UI Online
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.indigo],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (audio.title ?? 'M')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  title: Text(
                    audio.title ?? 'Unknown',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Menambahkan subtitle durasi agar sama dengan UI Online
                  subtitle: Text(
                    _formatDuration(audio.duration),
                    style: const TextStyle(color: Colors.grey),
                  ),

                  // Tambahkan tombol "+" pink sesuai UI Online
                  trailing: IconButton(
                    icon: const Icon(Icons.playlist_add, color: Colors.pinkAccent),
                    onPressed: () => _showAddToPlaylistDialog(audio),
                  ),

                  onTap: () {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => AudioPlayerPage(audioList: audios, initialIndex: index),
  ));
},
                );
              },
            ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}