import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import '../models/audio_model.dart';
import '../services/playlist_storage_service.dart';
import 'dart:async';

class AudioPlayerPage extends StatefulWidget {
  final List<AssetEntity> audioList; // Menerima List agar bisa Next/Prev
  final int initialIndex;

  const AudioPlayerPage({super.key, required this.audioList, required this.initialIndex});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  late int currentIndex;
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initAudio();
  }

  void _initAudio() async {
    final asset = widget.audioList[currentIndex];
    final file = await asset.file;
    if (file != null) {
      try {
        await _player.setFilePath(file.path);
        
        // Catat ke History
        HistoryService.addToHistory(
          HistoryItem(
            type: HistoryType.audio,
            title: asset.title ?? 'Audio Lokal',
            url: asset.id,
            thumbnail: '',
            assetId: asset.id,
            playedAt: DateTime.now(),
          ),
        );

        if (mounted) {
          setState(() {});
          _player.play();
        }
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
  }

  void _playNext() {
    if (currentIndex < widget.audioList.length - 1) {
      setState(() => currentIndex++);
      _initAudio();
    }
  }

  void _playPrevious() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _initAudio();
    }
  }

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
            hintText: "Nama Folder",
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent)),
          ),
          onChanged: (value) => folderName = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () async {
              if (folderName.trim().isNotEmpty) {
                final model = AudioModel(
                  title: asset.title ?? 'Lokal', artist: 'Lokal',
                  audioUrl: asset.id, duration: asset.duration, coverUrl: '',
                );
                await PlaylistStorageService.addAudioToGroup(folderName.trim(), model);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentAsset = widget.audioList[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
        title: const Text('LOCAL AUDIO', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              // Album Art Placeholder
              Container(
                width: screenHeight * 0.35, height: screenHeight * 0.35,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.indigo])),
                child: Center(child: Text((currentAsset.title ?? 'M')[0].toUpperCase(), style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(currentAsset.title ?? 'Unknown', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const Text("Media Lokal", style: TextStyle(color: Colors.white54, fontSize: 14)),
              
              Align(alignment: Alignment.centerRight, child: IconButton(icon: const Icon(Icons.playlist_add, color: Colors.pinkAccent, size: 28), onPressed: () => _showAddToPlaylistDialog(currentAsset))),

              // Slider
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final dur = _player.duration ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        activeColor: Colors.pinkAccent, inactiveColor: Colors.white12,
                        max: dur.inMilliseconds.toDouble(), value: pos.inMilliseconds.toDouble().clamp(0, dur.inMilliseconds.toDouble()),
                        onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(_format(pos), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(_format(dur), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ]),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // Kontrol
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton(icon: Icon(Icons.shuffle, color: _isShuffle ? Colors.pinkAccent : Colors.white24), onPressed: () => setState(() => _isShuffle = !_isShuffle)),
                IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 45), onPressed: _playPrevious),
                StreamBuilder<bool>(
                  stream: _player.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () => isPlaying ? _player.pause() : _player.play(),
                      child: Container(height: 70, width: 70, decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle), child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 45)),
                    );
                  },
                ),
                IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 45), onPressed: _playNext),
                IconButton(icon: Icon(Icons.repeat, color: _loopMode == LoopMode.one ? Colors.pinkAccent : Colors.white24), onPressed: () {
                  setState(() => _loopMode = _loopMode == LoopMode.off ? LoopMode.one : LoopMode.off);
                  _player.setLoopMode(_loopMode);
                }),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _format(Duration d) => "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
}