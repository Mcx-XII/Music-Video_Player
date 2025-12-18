import 'dart:convert';

class VideoModel {
  final String title;
  final String videoUrl;
  final String thumbnail;
  final int views;

  VideoModel({
    required this.title,
    required this.videoUrl,
    required this.thumbnail,
    required this.views,
  });

  // 1. Fungsi mengubah Objek ke Map (Persiapan jadi teks)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'views': views,
    };
  }

  // 2. Fungsi mengubah Map kembali ke Objek
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      title: map['title'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      views: map['views'] ?? 0,
    );
  }

  // 3. Fungsi mengubah Objek langsung jadi String JSON (Teks panjang)
  String toJson() => json.encode(toMap());

  // 4. Fungsi mengubah String JSON kembali ke Objek
  factory VideoModel.fromJson(String source) => VideoModel.fromMap(json.decode(source));
}