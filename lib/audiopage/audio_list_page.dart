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
      onlyAll: true,
    );

    if (albums.isEmpty) return;

    final assets = await albums.first.getAssetListPaged(page: 0, size: 1000);

    setState(() {
      audios = assets;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (audios.isEmpty) {
      return const Center(
        child: Text("Tidak ada audio", style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: audios.length,
      itemBuilder: (context, index) {
        final audio = audios[index];

        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.indigo],
              ),
            ),
            child: Center(
              child: Text(
                (audio.title ?? 'M')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          title: Text(
            audio.title ?? 'Unknown',
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AudioPlayerPage(audio: audio)),
            );
          },
        );
      },
    );
  }
}
