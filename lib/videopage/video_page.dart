import 'package:flutter/material.dart';
import 'listvideo.dart';
import 'listvideoplaylist.dart';
import 'online_video_page.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        OnlineVideoPage(), // video online
        VideoList(),       // video lokal
        PlaylistList(),    // playlist
      ],
    );
  }
}
