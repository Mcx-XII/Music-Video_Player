import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../helpers/media_permission.dart';
import 'audio_player_page.dart';

class AudioListPage extends StatefulWidget {
  const AudioListPage({super.key});

  @override
  State<AudioListPage> createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> {
  List<AssetEntity> audios = [];

  @override
  void initState() {
    super.initState();
    loadAudios();
  }

  Future<void> loadAudios() async {
    final granted = await requestMediaPermission();
    if (!granted) return;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
    );

    final assets = await albums.first.getAssetListPaged(
      page: 0,
      size: 1000,
    );

    setState(() {
      audios = assets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio List', style: const TextStyle(color: Colors.white),), backgroundColor: const Color.fromARGB(255, 34, 27, 68)),
      body: ListView.builder(
        itemCount: audios.length,
        itemBuilder: (context, index) {
          final audio = audios[index];

          return ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(audio.title ?? 'Unknown', style: const TextStyle(color: Colors.white),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AudioPlayerPage(audio: audio),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
