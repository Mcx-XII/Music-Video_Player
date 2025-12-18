import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_manager/photo_manager.dart';

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
      await _player.setFilePath(file.path);
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 4, // bikin judul lebih dekat
        title: Text(
          widget.audio.title ?? 'Audio Player',
          style: const TextStyle(color: Colors.white),
        ),
      ),

      body: Center(
        child: IconButton(
          iconSize: 64,
          color: Colors.white,
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () async {
            if (isPlaying) {
              await _player.pause();
            } else {
              await _player.play();
            }
            setState(() {
              isPlaying = !isPlaying;
            });
          },
        ),
      ),
    );
  }
}
