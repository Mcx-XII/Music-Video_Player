import 'dart:convert';
import 'video_model.dart';

class PlaylistGroup {
  final String name;
  final List<VideoModel> videos;

  PlaylistGroup({required this.name, required this.videos});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'videos': videos.map((x) => x.toMap()).toList(),
    };
  }

  factory PlaylistGroup.fromMap(Map<String, dynamic> map) {
    return PlaylistGroup(
      name: map['name'] ?? '',
      videos: List<VideoModel>.from(
        (map['videos'] as List? ?? []).map((x) => VideoModel.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory PlaylistGroup.fromJson(String source) => PlaylistGroup.fromMap(json.decode(source));
}