import 'package:flutter/material.dart';
import 'listvideo.dart';
import 'listvideoplaylist.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        VideoList(),
        PlaylistList(),
      ],
    );
  }
}
