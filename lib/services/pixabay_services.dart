import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/audio_model.dart';

class PixabayService {
  static const String _apiKey = '53760982-441bef9febf220741a37948c6';
  static const String _jamendoClientId = 'd2b618dd';

  // --- FUNGSI AUDIO (JAMENDO) ---
  Future<List<AudioModel>> fetchMusic({
    String query = '',
    int offset = 0,
    int limit = 20,
  }) async {
    String url =
        'https://api.jamendo.com/v3.0/tracks/?client_id=$_jamendoClientId&format=json&limit=$limit&offset=$offset';

    if (query.isNotEmpty) {
      url += '&namesearch=${Uri.encodeComponent(query)}';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        
        return results.map((e) {
          return AudioModel(
            title: e['name'] ?? 'Unknown Title',
            artist: e['artist_name'] ?? 'Unknown Artist',
            audioUrl: e['audio'] ?? '',
            coverUrl: e['image'] ?? '',
            duration: e['duration'] ?? 0,
          );
        }).toList();
      } else {
        throw Exception('Gagal mengambil musik');
      }
    } catch (e) {
      throw Exception('Error fetchMusic: $e');
    }
  }

  // --- FUNGSI VIDEO (PIXABAY) ---
  Future<List<VideoModel>> fetchVideos({
    String query = '',
    int page = 1,
  }) async {
    String url =
        'https://pixabay.com/api/videos/?key=$_apiKey&per_page=10&page=$page';

    if (query.isNotEmpty) {
      url += '&q=${Uri.encodeComponent(query)}';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List videos = data['hits'] ?? [];

        return videos.map((e) {
          // 1. Ambil URL video
          final videoMap = e['videos'];
          final String videoUrl = videoMap?['medium']?['url'] ?? 
                                 videoMap?['large']?['url'] ?? '';

          // 2. LOGIKA FIX THUMBNAIL (SANGAT AMAN)
          // Terkadang picture_id berupa angka, jadi kita paksa ke String
          final String pictureId = e['picture_id']?.toString() ?? '';
          
          String thumbUrl = '';
          if (pictureId.isNotEmpty) {
            thumbUrl = "https://i.vimeocdn.com/video/${pictureId}_640x360.jpg";
          } else {
            // Jika picture_id kosong, gunakan foto profil user sebagai cadangan
            thumbUrl = e['userImageURL'] ?? '';
          }

          // Debugging: Munculkan di terminal untuk cek apakah URL-nya benar
          print("Generated Thumbnail URL: $thumbUrl");

          return VideoModel(
            title: e['tags'] ?? 'Unknown Video',
            videoUrl: videoUrl,
            thumbnail: thumbUrl, 
            views: e['views'] ?? 0,
          );
        }).toList();
      } else {
        throw Exception('Gagal mengambil video');
      }
    } catch (e) {
      throw Exception('Error fetchVideos: $e');
    }
  }
}