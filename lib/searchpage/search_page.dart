import 'package:flutter/material.dart';
import '../services/pixabay_services.dart';
import '../models/audio_model.dart';
import '../videopage/online_video_player_page.dart';
import '../audiopage/online_audio_player_page.dart';

// --- Model Search Result Umum ---
enum SearchResultType { video, audio }

class SearchResult {
  final SearchResultType type;
  final String title;
  final String url;
  final String thumbnail; // video: thumbnail, audio: coverUrl
  final String? artist; // hanya untuk audio

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

    setState(() => _isLoading = true);

    try {
      final videos = await _apiService.fetchVideos(
        query: _searchController.text,
      );

      final audios = await _apiService.fetchMusic(
        query: _searchController.text,
      );

      final results = <SearchResult>[];

      results.addAll(
        videos.map(
          (v) => SearchResult(
            type: SearchResultType.video,
            title: v.title,
            url: v.videoUrl,
            thumbnail: v.thumbnail,
          ),
        ),
      );

      results.addAll(
        audios.map(
          (a) => SearchResult(
            type: SearchResultType.audio,
            title: a.title,
            url: a.audioUrl,
            thumbnail: a.coverUrl,
            artist: a.artist,
          ),
        ),
      );

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
    return Container(
      color: const Color.fromARGB(255, 54, 45, 94),
      child: Column(
        children: [
          // SEARCH BAR (karena AppBar di main.dart)
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
                fillColor: const Color.fromARGB(255, 89, 85, 155),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
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
                            leading: Stack(
                              children: [
                                Image.network(
                                  item.thumbnail,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      item.type == SearchResultType.video
                                          ? Icons.videocam
                                          : Icons.audiotrack,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: item.type == SearchResultType.audio &&
                                    item.artist != null
                                ? Text(
                                    item.artist!,
                                    style:
                                        const TextStyle(color: Colors.grey),
                                  )
                                : null,
                            onTap: () {
                              if (item.type == SearchResultType.video) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OnlineVideoPlayerPage(
                                      videoUrl: item.url,
                                      videoTitle: item.title,
                                    ),
                                  ),
                                );
                              } else {
                                final audio = AudioModel(
                                  title: item.title,
                                  artist: item.artist ?? 'Unknown',
                                  audioUrl: item.url,
                                  duration: 0,
                                  coverUrl: item.thumbnail,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        OnlineAudioPlayerPage(audio: audio),
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
