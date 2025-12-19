import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'video_player_page.dart';
import '../models/video_model.dart';
import '../services/playlist_storage_service.dart';
import '../utils/media_permission.dart'; // 🔥 PAKAI YANG LAMA

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<AssetEntity> _videos = [];
  bool _loading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        _loadVideos(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // WAJIB
    super.dispose();
  }

  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  Future<void> _loadVideos({bool loadMore = false}) async {
    final granted = await requestMediaPermission();
    if (!granted) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (_loadingMore || !_hasMore) return;
    if (_loadingMore || !_hasMore) return;

    _loadingMore = true;

    if (!loadMore) {
      _videos.clear();
      _page = 0;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      _hasMore = false;
      _loading = false;
      return;
    }

    final newVideos = await albums.first.getAssetListPaged(
      page: _page,
      size: 50, // 🔥 aman & cepat
    );

    if (newVideos.isEmpty) {
      _hasMore = false;
    } else {
      _videos.addAll(newVideos);
      _page++;
    }

    _loading = false;
    _loadingMore = false;

    if (mounted) setState(() {});
  }

  // ================= PLAYLIST =================
  void _showAddToPlaylistDialog(AssetEntity asset) {
    String folderName = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B52),
        title: const Text(
          "Simpan ke Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nama Playlist",
            hintStyle: TextStyle(color: Colors.white54),
          ),
          onChanged: (v) => folderName = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (folderName.trim().isEmpty) return;

              final videoModel = VideoModel(
                title: asset.title ?? 'Video Lokal',
                videoUrl: asset.id,
                thumbnail: '',
                views: 0,
              );

              await PlaylistStorageService.addVideoToGroup(
                folderName.trim(),
                videoModel,
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Disimpan ke playlist")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text("Tidak ada video", style: TextStyle(color: Colors.white54)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _videos.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // ===== LOADING INDICATOR BAWAH =====
          if (index == _videos.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final video = _videos[index];

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AssetEntityImage(
                video,
                width: 100,
                height: 60,
                fit: BoxFit.cover,
                thumbnailSize: const ThumbnailSize(120, 80),
              ),
            ),
            title: Text(
              video.title ?? 'Video Lokal',
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _formatDuration(video.duration),
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.playlist_add, color: Colors.blueAccent),
              onPressed: () => _showAddToPlaylistDialog(video),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      VideoPlayerPage(videoList: _videos, initialIndex: index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}";
  }
}
