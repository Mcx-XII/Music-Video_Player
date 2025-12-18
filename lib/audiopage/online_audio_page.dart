import 'package:flutter/material.dart';
import '../../services/pixabay_services.dart';
import '../../models/audio_model.dart';
import 'online_audio_player_page.dart';

class OnlineAudioPage extends StatelessWidget {
  const OnlineAudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AudioModel>>(
      future: PixabayService().fetchMusic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString(),
                style: const TextStyle(color: Colors.red)),
          );
        }

        final audios = snapshot.data!;
        return ListView.builder(
          itemCount: audios.length,
          itemBuilder: (context, index) {
            final audio = audios[index];

            return ListTile(
              leading: Image.network(audio.coverUrl, width: 48),
              title: Text(
                audio.title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                audio.artist,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OnlineAudioPlayerPage(audio: audio),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
