import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class PixabayService {
  static const String _apiKey = '53760982-441bef9febf220741a37948c6';
  static const String _baseUrl = 'https://pixabay.com/api/videos/';

  Future<List<VideoModel>> fetchVideos({String query = ''}) async {
    // Menambahkan parameter 'q' untuk pencarian jika query tidak kosong
    final String url = query.isEmpty
        ? '$_baseUrl?key=$_apiKey&per_page=20'
        : '$_baseUrl?key=$_apiKey&q=${Uri.encodeComponent(query)}&per_page=20';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List videos = data['hits'];

        return videos.map((e) => VideoModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data dari server');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}