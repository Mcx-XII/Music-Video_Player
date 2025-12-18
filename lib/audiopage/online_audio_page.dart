import 'package:flutter/material.dart';
import '../../services/pixabay_services.dart';
import '../../models/audio_model.dart';
import 'online_audio_player_page.dart';
import '../../helpers/internet_checker.dart';

class OnlineAudioPage extends StatefulWidget {
  const OnlineAudioPage({super.key});

  @override
  State<OnlineAudioPage> createState() => _OnlineAudioPageState();
}

class _OnlineAudioPageState extends State<OnlineAudioPage> {
  final PixabayService _apiService = PixabayService();
  final ScrollController _scrollController = ScrollController();

  List<AudioModel> _audios = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchAudios();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchAudios();
      }
    });
  }

  Future<void> _fetchAudios({bool refresh = false}) async {
    if (_isLoading) return;

    final connected = await hasInternet();
    if (!connected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tidak ada internet')));
      return;
    }

    setState(() => _isLoading = true);

    if (refresh) {
      _offset = 0;
      _audios.clear();
      _hasMore = true;
    }

    try {
      final newAudios = await _apiService.fetchMusic(
        offset: _offset,
        limit: _limit,
      );
      setState(() {
        _audios.addAll(newAudios);
        _hasMore = newAudios.length == _limit;
        _offset += newAudios.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memuat audio')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _fetchAudios(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _audios.length + 1,
        itemBuilder: (context, index) {
          if (index == _audios.length) {
            return _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }

          final audio = _audios[index];
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
      builder: (context) => OnlineAudioPlayerPage(
        // Ganti '_audios' sesuai dengan nama variabel List di bagian atas State kamu
        audioList: _audios, 
        initialIndex: index,
      ),
    ),
  );
},
          );
        },
      ),
    );
  }
}
