import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerUI extends StatelessWidget {
  final String title;
  final String artist;
  final Widget cover;
  final AudioPlayer player;

  final bool isShuffle;
  final LoopMode loopMode;

  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleLoop;

  const AudioPlayerUI({
    super.key,
    required this.title,
    required this.artist,
    required this.cover,
    required this.player,
    required this.isShuffle,
    required this.loopMode,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleShuffle,
    required this.onToggleLoop,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),

          // ===== COVER =====
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
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: cover,
            ),
          ),

          SizedBox(height: screenHeight * 0.05),

          // ===== TITLE =====
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            artist,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),

          SizedBox(height: screenHeight * 0.05),

          // ===== PROGRESS =====
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = player.duration ?? Duration.zero;

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                      activeTrackColor: Colors.blueAccent,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.blueAccent,
                    ),
                    child: Slider(
                      min: 0,
                      max: duration.inMilliseconds.toDouble(),
                      value: position.inMilliseconds
                          .toDouble()
                          .clamp(0, duration.inMilliseconds.toDouble()),
                      onChanged: (value) {
                        player.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _time(position),
                        _time(duration),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // ===== CONTROLS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: isShuffle ? Colors.blueAccent : Colors.white24,
                ),
                onPressed: onToggleShuffle,
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Colors.white,
                  size: 45,
                ),
                onPressed: onPrevious,
              ),
              StreamBuilder<bool>(
                stream: player.playingStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data ?? false;
                  return GestureDetector(
                    onTap: () =>
                        playing ? player.pause() : player.play(),
                    child: Container(
                      height: 75,
                      width: 75,
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: Colors.white,
                  size: 45,
                ),
                onPressed: onNext,
              ),
              IconButton(
                icon: Icon(
                  loopMode == LoopMode.one
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color: loopMode == LoopMode.one
                      ? Colors.blueAccent
                      : Colors.white24,
                ),
                onPressed: onToggleLoop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _time(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return Text(
      "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}",
      style: const TextStyle(color: Colors.white54, fontSize: 11),
    );
  }
}
