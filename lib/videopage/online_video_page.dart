import 'package:flutter/material.dart';
import '../../services/pixabay_services.dart';
import '../../models/video_model.dart';
import 'online_video_player_page.dart';

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
  int _page = 1; // halaman API untuk paginasi

  @override
  void initState() {
    super.initState();
    _fetchVideos();

    // Listener untuk infinite scroll
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

    setState(() => _isLoading = true);
    if (refresh) {
      _page = 1;
      _videos.clear();
      _hasMore = true;
    }

    try {
      final newVideos = await _apiService.fetchVideos(page: _page);
      setState(() {
        _videos.addAll(newVideos);
        _isLoading = false;
        _hasMore = newVideos.isNotEmpty;
        _page++;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat: $e')),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _fetchVideos(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _videos.length + 1,
        itemBuilder: (context, index) {
          if (index == _videos.length) {
            return _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }

          final video = _videos[index];
          return ListTile(
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
            subtitle: Text(
              "${video.views} views",
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OnlineVideoPlayerPage(videoUrl: video.videoUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
