import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

class AudioPlayerPage extends StatefulWidget {
  final AssetEntity audio;

  const AudioPlayerPage({super.key, required this.audio});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    loadAudio();
  }

  Future<void> loadAudio() async {
    final file = await widget.audio.file;
    if (file != null) {
      try {
        await _player.setFilePath(file.path);

        // ✅ FIX: Ganti 'add' menjadi 'addToHistory' sesuai nama di HistoryService
        await HistoryService.addToHistory(
          HistoryItem(
            type: HistoryType.audio,
            title: widget.audio.title ?? 'Audio Lokal',
            url: widget.audio.id, // Menggunakan ID sebagai URL unik untuk media lokal
            thumbnail: '',
            assetId: widget.audio.id,
            playedAt: DateTime.now(),
          ),
        );
      } catch (e) {
        debugPrint("Error loading local audio: $e");
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna tema ungu gelap agar seragam
      backgroundColor: const Color.fromARGB(255, 34, 27, 68),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.audio.title ?? 'Audio Player',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art Placeholder dengan inisial nama lagu
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  (widget.audio.title ?? 'M')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          // Tombol Kontrol Play/Pause
          IconButton(
            iconSize: 80,
            color: Colors.white,
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
            onPressed: () async {
              if (isPlaying) {
                await _player.pause();
              } else {
                await _player.play();
              }
              if (mounted) setState(() => isPlaying = !isPlaying);
            },
          ),
          
          const Text(
            "PUTAR LOKAL",
            style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}