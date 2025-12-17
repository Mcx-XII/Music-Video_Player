import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'video_player_page.dart';
import 'dart:io';


class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<AssetEntity> videos = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!ps.hasAccess) {
      PhotoManager.openSetting();
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      onlyAll: true, // PENTING
    );

    if (albums.isEmpty) return;

    final media = await albums.first.getAssetListPaged(page: 0, size: 100);

    setState(() {
      videos = media;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const Center(
        child: Text("Tidak ada video", style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return ListTile(
          title: FutureBuilder<File?>(
            future: video.file,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("...");
              final name = snapshot.data!.path.split('/').last;
              return Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              );
            },
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VideoPlayerPage(video: video)),
            );
          },
          leading: FutureBuilder<Uint8List?>(
            future: video.thumbnailDataWithSize(const ThumbnailSize(200, 120)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 80,
                  height: 45,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SizedBox(
                  width: 80,
                  height: 45,
                  child: Icon(Icons.video_file, color: Colors.white),
                );
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  snapshot.data!,
                  width: 80,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
