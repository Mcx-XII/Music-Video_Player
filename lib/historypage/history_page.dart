import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../videopage/online_video_player_page.dart';
import '../audiopage/online_audio_player_page.dart';
import '../models/audio_model.dart';
import 'package:photo_manager/photo_manager.dart';
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
      backgroundColor: const Color.fromARGB(255, 54, 45, 94),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("RIWAYAT", style: TextStyle(color: Colors.white, fontSize: 16)),
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
              child: Text(
                'Belum ada riwayat pemutaran',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                leading: _buildThumbnail(item),
                title: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _formatTime(item.playedAt),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: Icon(
                  item.type == HistoryType.video ? Icons.play_circle_outline : Icons.music_note,
                  color: Colors.white38,
                  size: 20,
                ),
                onTap: () {
                  // --- LOGIKA PUTAR ULANG DARI RIWAYAT ---
                  if (item.type == HistoryType.video) {
                    if (item.assetId != null) {
                      // VIDEO LOKAL (FIXED)
                      AssetEntity.fromId(item.assetId!).then((asset) {
                        if (asset != null && context.mounted) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(
                              videoList: [asset], // Sekarang minta List
                              initialIndex: 0,    // Sekarang minta Index
                            ),
                          ));
                        }
                      });
                    } else {
                      // VIDEO ONLINE (Sudah Benar)
                      final videoItem = VideoModel(
                        title: item.title,
                        videoUrl: item.url,
                        thumbnail: item.thumbnail,
                        views: 0,
                      );
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => OnlineVideoPlayerPage(
                          videoList: [videoItem], 
                          initialIndex: 0,
                        ),
                      ));
                    }
                  } else {
                    // AUDIO
                    if (item.assetId != null) {
                      // AUDIO LOKAL (FIXED)
                      AssetEntity.fromId(item.assetId!).then((asset) {
                        if (asset != null && context.mounted) {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => AudioPlayerPage(
                              audioList: [asset], // Sekarang minta List
                              initialIndex: 0,    // Sekarang minta Index
                            ),
                          ));
                        }
                      });
                    } else {
                      // AUDIO ONLINE (Sudah Benar)
                      final audio = AudioModel(
                        title: item.title,
                        artist: 'Unknown Artist',
                        audioUrl: item.url,
                        duration: 0,
                        coverUrl: item.thumbnail,
                      );
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => OnlineAudioPlayerPage(
                          audioList: [audio], 
                          initialIndex: 0,
                        ),
                      ));
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

  Widget _buildThumbnail(HistoryItem item) {
    if (item.thumbnail.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.thumbnail,
          width: 56, height: 56, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(item),
        ),
      );
    }
    return _fallbackIcon(item);
  }

  Widget _fallbackIcon(HistoryItem item) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white10,
      ),
      child: Icon(
        item.type == HistoryType.video ? Icons.videocam : Icons.audiotrack,
        color: Colors.white54,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} j yang lalu';
    return '${diff.inDays} h yang lalu';
  }
}