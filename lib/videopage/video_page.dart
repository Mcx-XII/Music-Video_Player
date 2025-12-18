import 'package:flutter/material.dart';
import 'listvideo.dart';
import 'listvideoplaylist.dart';
import 'online_video_page.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Hapus kata 'const' di depan TabBarView agar data playlist bisa di-refresh
    return TabBarView(
      children: [
        // Tab 1: Video Online (Pixabay)
        const OnlineVideoPage(), 
        
        // Tab 2: Video Lokal (Internal Storage)
        const VideoList(), 
        
        // Tab 3: Playlist Video (Data tersimpan di SharedPreferences)
        // FIX: Pastikan tidak memakai 'const' di sini
        ListVideoPlaylist(), 
      ],
    );
  }
}