import 'package:flutter/material.dart';
import '../services/pixabay_services.dart';
import '../models/audio_model.dart';
import '../models/video_model.dart'; // Pastikan ini ada
import '../videopage/online_video_player_page.dart';
import '../audiopage/online_audio_player_page.dart';
import '../helpers/internet_checker.dart';

// --- Model Search Result Umum ---
enum SearchResultType { video, audio }

class SearchResult {
  final SearchResultType type;
  final String title;
  final String url;
  final String thumbnail; 
  final String? artist;

  SearchResult({
    required this.type,
    required this.title,
    required this.url,
    required this.thumbnail,
    this.artist,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final PixabayService _apiService = PixabayService();

  List<SearchResult> _searchResults = [];
  bool _isLoading = false;

  void _onSearch() async {
    if (_searchController.text.isEmpty) return;

    // Sembunyikan keyboard saat mulai mencari
    FocusScope.of(context).unfocus();

    final connected = await hasInternet();
    if (!connected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada koneksi internet')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ambil data Video dan Audio secara paralel
      final videos = await _apiService.fetchVideos(query: _searchController.text);
      final audios = await _apiService.fetchMusic(); // Gunakan fetchMusic tanpa query jika service belum mendukung

      final results = <SearchResult>[];

      // Map Video ke SearchResult
      results.addAll(
        videos.map((v) => SearchResult(
          type: SearchResultType.video,
          title: v.title,
          url: v.videoUrl,
          thumbnail: v.thumbnail,
        )),
      );

      // Map Audio ke SearchResult
      results.addAll(
        audios.map((a) => SearchResult(
          type: SearchResultType.audio,
          title: a.title,
          url: a.audioUrl,
          thumbnail: a.coverUrl,
          artist: a.artist,
        )),
      );

      if (!mounted) return;
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat hasil pencarian')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 34, 27, 68), // Sesuaikan warna background aplikasi
      child: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari video atau audio...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color.fromARGB(255, 54, 45, 94),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),

          // LIST HASIL PENCARIAN
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : _searchResults.isEmpty
                    ? const Center(
                        child: Text(
                          'Ketik sesuatu untuk mencari video/audio',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.network(
                                    item.thumbnail,
                                    width: 80,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.grey, width: 80, height: 50),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        item.type == SearchResultType.video
                                            ? Icons.videocam
                                            : Icons.audiotrack,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.type == SearchResultType.video ? "Video" : (item.artist ?? "Unknown Artist"),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            onTap: () {
                              if (item.type == SearchResultType.video) {
                                // Bungkus ke dalam VideoModel
                                final videoItem = VideoModel(
                                  title: item.title,
                                  videoUrl: item.url,
                                  thumbnail: item.thumbnail,
                                  views: 0,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OnlineVideoPlayerPage(
                                      videoList: [videoItem], // Masukkan ke dalam List
                                      initialIndex: 0,
                                    ),
                                  ),
                                );
                              } else {
                                // Logika Audio
                                final audio = AudioModel(
                                  title: item.title,
                                  artist: item.artist ?? 'Unknown Artist',
                                  audioUrl: item.url,
                                  duration: 0,
                                  coverUrl: item.thumbnail,
                                );

                                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OnlineAudioPlayerPage(
      audioList: [audio], // Kirim lagu sebagai list tunggal
      initialIndex: 0,
    ),
  ),
);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}