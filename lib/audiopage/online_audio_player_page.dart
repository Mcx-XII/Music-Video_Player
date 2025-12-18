import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_model.dart';
import '../services/playlist_storage_service.dart'; // Import service untuk simpan playlist
import 'dart:async';

class OnlineAudioPlayerPage extends StatefulWidget {
  final List<AudioModel> audioList;
  final int initialIndex;

  const OnlineAudioPlayerPage({
    super.key, 
    required this.audioList, 
    required this.initialIndex
  });

  @override
  State<OnlineAudioPlayerPage> createState() => _OnlineAudioPlayerPageState();
}

class _OnlineAudioPlayerPageState extends State<OnlineAudioPlayerPage> {
  AudioPlayer? _player;
  late int currentIndex;
  
  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initAudio(widget.audioList[currentIndex].audioUrl);
  }

  void _initAudio(String url) async {
    if (_player != null) {
      await _player!.dispose();
    }
    
    _player = AudioPlayer();
    try {
      await _player!.setUrl(url);
      if (mounted) {
        setState(() {});
        _player!.play();
      }
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  // --- FUNGSI BARU: DIALOG TAMBAH KE PLAYLIST ---
  void _showAddToPlaylistDialog(AudioModel audio) {
    String folderName = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2B52),
        title: const Text("Simpan ke Playlist", style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nama Playlist (Misal: Jazz)",
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
                await PlaylistStorageService.addAudioToGroup(folderName.trim(), audio);
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

  void _playNext() {
    if (currentIndex < widget.audioList.length - 1) {
      setState(() {
        currentIndex++;
      });
      _initAudio(widget.audioList[currentIndex].audioUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ini adalah lagu terakhir")),
      );
    }
  }

  void _playPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _initAudio(widget.audioList[currentIndex].audioUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ini adalah lagu pertama")),
      );
    }
  }

  void _toggleLoop() {
    setState(() {
      if (_loopMode == LoopMode.off) {
        _loopMode = LoopMode.one;
        _player?.setLoopMode(LoopMode.one);
      } else {
        _loopMode = LoopMode.off;
        _player?.setLoopMode(LoopMode.off);
      }
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_player == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1D1B3E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final currentAudio = widget.audioList[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1D1B3E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('NOW PLAYING', 
          style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              // ALBUM ART
              Container(
                width: screenHeight * 0.35,
                height: screenHeight * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    currentAudio.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              // INFO LAGU
              Text(
                currentAudio.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                currentAudio.artist,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              
              // --- POSISI TOMBOL TAMBAH PLAYLIST (NEW) ---
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.playlist_add, color: Colors.blueAccent, size: 28),
                    onPressed: () => _showAddToPlaylistDialog(currentAudio),
                  ),
                ),
              ),

              // PROGRESS SLIDER
              StreamBuilder<Duration>(
                stream: _player!.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _player!.duration ?? Duration.zero;
                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          activeTrackColor: Colors.blueAccent,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: Colors.blueAccent,
                        ),
                        child: Slider(
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
                          onChanged: (value) => _player!.seek(Duration(milliseconds: value.toInt())),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            Text(_formatDuration(duration), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // KONTROL UTAMA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle, 
                      color: _isShuffle ? Colors.blueAccent : Colors.white24, size: 22),
                    onPressed: () => setState(() => _isShuffle = !_isShuffle),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 45),
                    onPressed: _playPrevious,
                  ),
                  StreamBuilder<bool>(
                    stream: _player!.playingStream,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      return GestureDetector(
                        onTap: () => isPlaying ? _player!.pause() : _player!.play(),
                        child: Container(
                          height: 75, width: 75,
                          decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                          child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 50),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 45),
                    onPressed: _playNext,
                  ),
                  IconButton(
                    icon: Icon(_loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat, 
                      color: _loopMode == LoopMode.one ? Colors.blueAccent : Colors.white24, size: 22),
                    onPressed: _toggleLoop,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}