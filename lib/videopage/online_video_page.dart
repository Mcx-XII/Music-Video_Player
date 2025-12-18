import 'package:flutter/material.dart';
import '../../services/pixabay_services.dart';
import '../../models/video_model.dart';
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

    // Listener untuk infinite scroll (pagination)
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
          const SnackBar(content: Text('Tidak ada internet')),
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
      // Pastikan fetchVideos di service Anda mendukung parameter 'page'
      final newVideos = await _apiService.fetchVideos(query: ''); 
      
      setState(() {
        _videos.addAll(newVideos);
        // Jika data yang datang lebih sedikit dari per_page, berarti sudah habis
        _hasMore = newVideos.isNotEmpty; 
        _page++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat video')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E), // Menyesuaikan tema gelap aplikasi
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
                          Container(color: Colors.grey, width: 100, height: 60),
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
                    onTap: () {
                      // FIX: Mengirim seluruh List dan Index yang diklik
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