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

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    // ✅ PAKAI PERMISSION VERSI LAMA (WORKING)
    final granted = await requestMediaPermission();
    if (!granted) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final videos = await albums.first.getAssetListPaged(
      page: 0,
      size: 50,
    );

    if (mounted) {
      setState(() {
        _videos = videos;
        _loading = false;
      });
    }
  }

  // ================= PLAYLIST =================
  void _showAddToPlaylistDialog(AssetEntity asset) {
    String folderName = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B52),
        title: const Text("Simpan ke Playlist",
            style: TextStyle(color: Colors.white)),
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
        child: Text("Tidak ada video",
            style: TextStyle(color: Colors.white54)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E),
      body: ListView.builder(
        itemCount: _videos.length,
        itemBuilder: (context, index) {
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
              icon: const Icon(Icons.playlist_add,
                  color: Colors.blueAccent),
              onPressed: () => _showAddToPlaylistDialog(video),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerPage(
                    videoList: _videos,
                    initialIndex: index,
                  ),
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
