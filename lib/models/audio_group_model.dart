import 'dart:convert';
import 'audio_model.dart';

class AudioGroup {
  final String name; // Nama Folder (Misal: "Lagu Galau")
  final List<AudioModel> audios;

  AudioGroup({required this.name, required this.audios});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'audios': audios.map((x) => x.toMap()).toList(),
    };
  }

  factory AudioGroup.fromMap(Map<String, dynamic> map) {
    return AudioGroup(
      name: map['name'] ?? '',
      audios: List<AudioModel>.from(
        (map['audios'] as List? ?? []).map((x) => AudioModel.fromMap(x)),
      ),
    );
  }

  String toJson() => json.encode(toMap());
  factory AudioGroup.fromJson(String source) => AudioGroup.fromMap(json.decode(source));
}