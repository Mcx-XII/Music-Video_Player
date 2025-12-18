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
import '../models/video_model.dart'; // Import VideoModel agar bisa digunakan di onTap

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<HistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = HistoryService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 54, 45, 94),
      body: FutureBuilder<List<HistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.white24, height: 1),
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                leading: _buildThumbnail(item),
                title: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _formatTime(item.playedAt),
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Icon(
                  item.type == HistoryType.video
                      ? Icons.videocam
                      : Icons.audiotrack,
                  color: Colors.white,
                ),
                onTap: () {
                  // ===== VIDEO =====
                  if (item.type == HistoryType.video) {
                    // LOCAL VIDEO
                    if (item.assetId != null) {
                      AssetEntity.fromId(item.assetId!).then((asset) {
                        if (asset != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VideoPlayerPage(video: asset),
                            ),
                          );
                        }
                      });
                    }
                    // ONLINE VIDEO (DI-FIX DI SINI)
                    else {
                      // Buat VideoModel dari data HistoryItem
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
                            videoList: [videoItem], // Bungkus dalam List
                            initialIndex: 0,        // Berikan index awal 0
                          ),
                        ),
                      );
                    }
                  }
                  // ===== AUDIO =====
                  else {
                    // LOCAL AUDIO ✅
                    if (item.assetId != null) {
                      AssetEntity.fromId(item.assetId!).then((asset) {
                        if (asset != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AudioPlayerPage(audio: asset),
                            ),
                          );
                        }
                      });
                    }
                    // ONLINE AUDIO
                    else {
                      final audio = AudioModel(
                        title: item.title,
                        artist: 'Unknown',
                        audioUrl: item.url,
                        duration: 0,
                        coverUrl: item.thumbnail,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OnlineAudioPlayerPage(audio: audio),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  /// ================= THUMBNAIL =================

  Widget _buildThumbnail(HistoryItem item) {
    // ONLINE (video / audio)
    if (item.thumbnail.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.thumbnail,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(item),
        ),
      );
    }

    // LOCAL VIDEO SAJA
    if (item.assetId != null && item.type == HistoryType.video) {
      return FutureBuilder<AssetEntity?>(
        future: AssetEntity.fromId(item.assetId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _fallbackIcon(item);

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AssetEntityImage(
              snapshot.data!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }

    // AUDIO LOKAL → ICON
    return _fallbackIcon(item);
  }

  Widget _fallbackIcon(HistoryItem item) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.indigo],
        ),
      ),
      child: Icon(
        item.type == HistoryType.video ? Icons.videocam : Icons.audiotrack,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}