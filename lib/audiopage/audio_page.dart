import 'package:flutter/material.dart';
import 'audio_list_page.dart';
import 'audio_playlist_page.dart';
import 'online_audio_page.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        OnlineAudioPage(),     // audio online
        AudioListPage(),       // audio lokal
        AudioPlaylistPage(),   // playlist
      ],
    );
  }
}
