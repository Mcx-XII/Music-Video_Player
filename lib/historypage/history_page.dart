import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../videopage/online_video_player_page.dart';
import '../audiopage/online_audio_player_page.dart';
import '../models/audio_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../audiopage/audio_player_page.dart';
import '../videopage/video_player_page.dart';
import '../models/video_model.dart'; 

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<HistoryItem>> _loadHistory() async {
    return await HistoryService.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 27, 68), // Disamakan dengan Player
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("RIWAYAT PEMUTARAN", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white54),
            onPressed: () async {
              await HistoryService.clearHistory();
              setState(() {}); 
            },
          )
        ],
      ),
      body: FutureBuilder<List<HistoryItem>>(
        future: _loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat', style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                leading: _buildThumbnail(item),
                title: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _formatTime(item.playedAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                trailing: Icon(
                  item.type == HistoryType.video ? Icons.videocam : Icons.audiotrack,
                  color: item.type == HistoryType.video ? Colors.blueAccent : Colors.pinkAccent,
                  size: 18,
                ),
                onTap: () => _handleOnTap(item),
              );
            },
          );
        },
      ),
    );
  }

  // --- LOGIKA THUMBNAIL DINAMIS (FIXED) ---
  Widget _buildThumbnail(HistoryItem item) {
    // 1. Jika Online (Sudah ada URL Thumbnail)
    if (item.thumbnail.isNotEmpty && item.thumbnail.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(item.type == HistoryType.audio ? 50 : 8),
        child: Image.network(
          item.thumbnail,
          width: 50, height: 50, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackThumbnail(item),
        ),
      );
    }

    // 2. Jika Lokal Video (Ambil dari AssetEntity)
    if (item.assetId != null && item.type == HistoryType.video) {
      return FutureBuilder<AssetEntity?>(
        future: AssetEntity.fromId(item.assetId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _fallbackThumbnail(item);
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AssetEntityImage(
              snapshot.data!,
              width: 50, height: 50, fit: BoxFit.cover,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize(200, 200),
            ),
          );
        },
      );
    }

    // 3. Jika Lokal Audio (Gunakan Inisial seperti UI Musik Online)
    return _fallbackThumbnail(item);
  }

  Widget _fallbackThumbnail(HistoryItem item) {
    final bool isAudio = item.type == HistoryType.audio;
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        shape: isAudio ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isAudio ? null : BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: isAudio 
            ? [Colors.deepPurple, Colors.pinkAccent] 
            : [Colors.blueGrey, Colors.black87],
        ),
      ),
      child: Center(
        child: Text(
          item.title.isNotEmpty ? item.title[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleOnTap(HistoryItem item) {
    if (item.type == HistoryType.video) {
      if (item.assetId != null) {
        AssetEntity.fromId(item.assetId!).then((asset) {
          if (asset != null && mounted) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => VideoPlayerPage(videoList: [asset], initialIndex: 0),
            ));
          }
        });
      } else {
        final video = VideoModel(title: item.title, videoUrl: item.url, thumbnail: item.thumbnail, views: 0);
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => OnlineVideoPlayerPage(videoList: [video], initialIndex: 0),
        ));
      }
    } else {
      if (item.assetId != null) {
        AssetEntity.fromId(item.assetId!).then((asset) {
          if (asset != null && mounted) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => AudioPlayerPage(audioList: [asset], initialIndex: 0),
            ));
          }
        });
      } else {
        final audio = AudioModel(title: item.title, artist: 'Online', audioUrl: item.url, duration: 0, coverUrl: item.thumbnail);
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => OnlineAudioPlayerPage(audioList: [audio], initialIndex: 0),
        ));
      }
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}h yang lalu';
  }
}
