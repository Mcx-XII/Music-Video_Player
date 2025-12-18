import 'package:flutter/material.dart';
import '../../services/pixabay_services.dart';
import '../../models/video_model.dart';
import '../../services/playlist_storage_service.dart'; 
import 'online_video_player_page.dart';
import '../../helpers/internet_checker.dart';

class OnlineVideoPage extends StatefulWidget {
  const OnlineVideoPage({super.key});

  @override
  State<OnlineVideoPage> createState() => _OnlineVideoPageState();
}

class _OnlineVideoPageState extends State<OnlineVideoPage> {
  final PixabayService _apiService = PixabayService();
  final ScrollController _scrollController = ScrollController();

  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchVideos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchVideos();
      }
    });
  }

  Future<void> _fetchVideos({bool refresh = false}) async {
    if (_isLoading) return;

    final connected = await hasInternet();
    if (!connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada koneksi internet')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    if (refresh) {
      _page = 1;
      _videos.clear();
      _hasMore = true;
    }

    try {
      final newVideos = await _apiService.fetchVideos(query: '', page: _page); 
      
      if (mounted) {
        setState(() {
          _videos.addAll(newVideos);
          _hasMore = newVideos.isNotEmpty; 
          _page++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat video dari Pixabay')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI BARU: DIALOG PILIH/BUAT PLAYLIST ---
  void _showAddToPlaylistDialog(VideoModel video) {
    String folderName = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B52),
        title: const Text("Simpan ke Playlist", style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nama Playlist (Misal: Favorit)",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          ),
          onChanged: (value) => folderName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (folderName.trim().isNotEmpty) {
                // Menggunakan fungsi group yang baru dibuat di service
                await PlaylistStorageService.addVideoToGroup(folderName.trim(), video);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Berhasil ditambah ke: $folderName')),
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
      backgroundColor: const Color(0xFF1D1B3E), 
      body: RefreshIndicator(
        onRefresh: () => _fetchVideos(refresh: true),
        child: _videos.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _videos.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _videos.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final video = _videos[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        video.thumbnail,
                        width: 100,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Container(color: Colors.grey, width: 100, height: 60, child: const Icon(Icons.broken_image)),
                      ),
                    ),
                    title: Text(
                      video.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "${video.views} views",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    
                    // TOMBOL TAMBAH KE KELOMPOK PLAYLIST
                    trailing: IconButton(
                      icon: const Icon(Icons.playlist_add, color: Colors.blueAccent),
                      onPressed: () => _showAddToPlaylistDialog(video),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnlineVideoPlayerPage(
                            videoList: _videos, 
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