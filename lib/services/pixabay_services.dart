import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../models/audio_model.dart';

class PixabayService {
  static const String _apiKey = '53760982-441bef9febf220741a37948c6';
  static const String _jamendoClientId = 'd2b618dd';

  // --- FUNGSI AUDIO (JAMENDO) ---
  Future<List<AudioModel>> fetchMusic({String query = ''}) async {
    String url = 'https://api.jamendo.com/v3.0/tracks/?client_id=$_jamendoClientId&format=json&limit=20';
    
    if (query.isNotEmpty) {
      url += '&namesearch=${Uri.encodeComponent(query)}';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        // Pastikan konversi ke Map<String, dynamic> aman
        return results.map((e) => AudioModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } else {
        throw Exception('Gagal mengambil musik: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetchMusic: $e');
    }
  }

  // --- FUNGSI VIDEO (PIXABAY) ---
  Future<List<VideoModel>> fetchVideos({String query = ''}) async {
    String url = 'https://pixabay.com/api/videos/?key=$_apiKey&per_page=10';
    
    if (query.isNotEmpty) {
      url += '&q=${Uri.encodeComponent(query)}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List videos = data['hits'] ?? [];

      return videos
          .map((e) => VideoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Gagal mengambil video');
    }
  }
}