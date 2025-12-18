import 'package:flutter/material.dart';
import '../../services/pixabay_services.dart';
import '../../models/audio_model.dart';
import '../../services/playlist_storage_service.dart'; // Import service untuk simpan playlist
import 'online_audio_player_page.dart';
import '../../helpers/internet_checker.dart';

class OnlineAudioPage extends StatefulWidget {
  const OnlineAudioPage({super.key});

  @override
  State<OnlineAudioPage> createState() => _OnlineAudioPageState();
}

class _OnlineAudioPageState extends State<OnlineAudioPage> {
  final PixabayService _apiService = PixabayService();
  final ScrollController _scrollController = ScrollController();

  List<AudioModel> _audios = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchAudios();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchAudios();
      }
    });
  }

  Future<void> _fetchAudios({bool refresh = false}) async {
    if (_isLoading) return;

    final connected = await hasInternet();
    if (!connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada internet')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    if (refresh) {
      _offset = 0;
      _audios.clear();
      _hasMore = true;
    }

    try {
      final newAudios = await _apiService.fetchMusic(
        offset: _offset,
        limit: _limit,
      );
      if (mounted) {
        setState(() {
          _audios.addAll(newAudios);
          _hasMore = newAudios.length == _limit;
          _offset += newAudios.length;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat audio')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI BARU: DIALOG UNTUK PENGELOMPOKAN PLAYLIST MUSIK ---
  void _showAddToPlaylistDialog(AudioModel audio) {
    String folderName = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B52), // Menyesuaikan tema gelap
        title: const Text("Simpan ke Playlist", style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nama Playlist Musik (Misal: Jazz)",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.pinkAccent),
            ),
          ),
          onChanged: (value) => folderName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () async {
              if (folderName.trim().isNotEmpty) {
                // Memanggil logika penambahan ke grup audio di service
                await PlaylistStorageService.addAudioToGroup(folderName.trim(), audio);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"$folderName" diperbarui!'),
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E), // Tema gelap konsisten
      body: RefreshIndicator(
        onRefresh: () => _fetchAudios(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _audios.length + 1,
          itemBuilder: (context, index) {
            if (index == _audios.length) {
              return _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            final audio = _audios[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(audio.coverUrl),
              ),
              title: Text(
                audio.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                audio.artist,
                style: const TextStyle(color: Colors.grey),
              ),
              
              // TOMBOL TAMBAH KE FOLDER PLAYLIST
              trailing: IconButton(
                icon: const Icon(Icons.playlist_add, color: Colors.pinkAccent),
                onPressed: () => _showAddToPlaylistDialog(audio),
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnlineAudioPlayerPage(
                      audioList: _audios, 
                      initialIndex: index,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}