import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'video_player_page.dart';
import '../models/video_model.dart';
import '../services/playlist_storage_service.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<AssetEntity> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );
      if (paths.isNotEmpty) {
        final List<AssetEntity> entities = await paths[0].getAssetListRange(
          start: 0,
          end: 100,
        );
        setState(() => _videos = entities);
      }
    }
  }

  // DIALOG TAMBAH KE PLAYLIST (Sesuai UI Online)
  void _showAddToPlaylistDialog(AssetEntity asset) {
    String folderName = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B52),
        title: const Text("Simpan ke Playlist", style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nama Playlist (Misal: Lokal Fav)",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          ),
          onChanged: (value) => folderName = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (folderName.trim().isNotEmpty) {
                // Konversi AssetEntity ke VideoModel sementara untuk disimpan
                final videoModel = VideoModel(
                  title: asset.title ?? 'Video Lokal',
                  videoUrl: asset.id, 
                  thumbnail: '', // Thumbnail lokal diambil lewat assetId nanti
                  views: 0,
                );
                await PlaylistStorageService.addVideoToGroup(folderName.trim(), videoModel);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Berhasil disimpan ke folder $folderName')),
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
      backgroundColor: const Color(0xFF1D1B3E), // Warna latar belakang sama dengan Online
      body: _videos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding sama dengan Online
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AssetEntityImage(
                      video,
                      width: 100, // Ukuran lebar sama (100)
                      height: 60, // Ukuran tinggi sama (60)
                      fit: BoxFit.cover,
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize(200, 120),
                    ),
                  ),
                  title: Text(
                    video.title ?? 'Video Lokal',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _formatDuration(video.duration),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  
                  // Tombol Tambah ke Playlist agar sama dengan UI Online
                  trailing: IconButton(
                    icon: const Icon(Icons.playlist_add, color: Colors.blueAccent),
                    onPressed: () => _showAddToPlaylistDialog(video),
                  ),

onTap: () {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => VideoPlayerPage(videoList: _videos, initialIndex: index),
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