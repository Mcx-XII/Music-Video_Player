import 'dart:convert';

class AudioModel {
  final String title;
  final String artist;
  final String audioUrl;
  final int duration;
  final String coverUrl;

  AudioModel({
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.duration,
    required this.coverUrl,
  });

  // Untuk simpan ke HP
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'duration': duration,
      'coverUrl': coverUrl,
    };
  }

  // Untuk ambil dari HP atau API
  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      title: map['title'] ?? map['name'] ?? 'Unknown',
      artist: map['artist'] ?? map['artist_name'] ?? 'Unknown',
      audioUrl: map['audioUrl'] ?? map['audio'] ?? '',
      duration: map['duration'] ?? 0,
      coverUrl: map['coverUrl'] ?? map['image'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory AudioModel.fromJson(String source) => AudioModel.fromMap(json.decode(source));
}