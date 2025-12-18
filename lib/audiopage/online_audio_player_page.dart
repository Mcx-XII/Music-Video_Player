import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/audio_model.dart';
import '../../services/history_service.dart';
import '../../models/history_item.dart';

class OnlineAudioPlayerPage extends StatefulWidget {
  final AudioModel audio;

  const OnlineAudioPlayerPage({super.key, required this.audio});

  @override
  State<OnlineAudioPlayerPage> createState() => _OnlineAudioPlayerPageState();
}

class _OnlineAudioPlayerPageState extends State<OnlineAudioPlayerPage> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    player.setUrl(widget.audio.audioUrl);

    // ✅ SIMPAN RIWAYAT AUDIO ONLINE
    HistoryService.add(
      HistoryItem(
        type: HistoryType.audio,
        title: widget.audio.title,
        url: widget.audio.audioUrl,
        thumbnail: widget.audio.coverUrl,
        playedAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.audio.title, // judul audio dari model
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(widget.audio.coverUrl, width: 220),
          const SizedBox(height: 24),
          IconButton(
            iconSize: 64,
            color: Colors.white,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () async {
              isPlaying ? await player.pause() : await player.play();
              setState(() => isPlaying = !isPlaying);
            },
          ),
        ],
      ),
    );
  }
}
