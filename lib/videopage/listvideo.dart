import 'package:flutter/material.dart';

class VideoList extends StatelessWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60,
              height: 40,
              color: Colors.grey.shade700,
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),
          title: const Text(
            "My Awesome Vacation",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            "128 MB • 04:32",
            style: TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.more_vert, color: Colors.white),
        );
      },
    );
  }
}
