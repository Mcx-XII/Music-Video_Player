import 'package:flutter/material.dart';
import '../services/pixabay_services.dart';
import '../models/video_model.dart';
import '../videopage/video_player_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 1. Controller untuk menangkap teks yang diketik
  final TextEditingController _searchController = TextEditingController();
  final PixabayService _apiService = PixabayService();
  
  List<VideoModel> _searchResults = [];
  bool _isLoading = false;

  // 2. Fungsi untuk menjalankan pencarian
  void _onSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Mengambil data dari API dengan parameter query
      final results = await _apiService.fetchVideos(query: _searchController.text);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1B3E),
        elevation: 0,
        // 3. Menambahkan kolom input di AppBar
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Cari video di sini...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _onSearch(), // Cari saat tekan Enter
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch, // Cari saat tekan ikon kaca pembesar
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? const Center(
                  child: Text('Ketik sesuatu untuk mencari video',
                      style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final video = _searchResults[index];
                    return ListTile(
                      onTap: () {
                        // Navigasi ke VideoPlayerPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerPage(
                              videos: _searchResults,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
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
                    );
                  },
                ),
    );
  }
}