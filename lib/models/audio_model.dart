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

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      // API dari jamendo
      title: json['name'] ?? 'Unknown Title',
      artist: json['artist_name'] ?? 'Unknown Artist',
      audioUrl: json['audio'] ?? '',
      duration: json['duration'] ?? 0,
      coverUrl: json['image'] ?? 'https://via.placeholder.com/150/201E43/FFFFFF?text=Music',
    );
  }
}