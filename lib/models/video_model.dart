class VideoModel {
  final String title;
  final String thumbnail;
  final String videoUrl;
  final int views;

  VideoModel({
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    required this.views,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      title: json['tags'] ?? 'No Title',
      thumbnail: json['videos']['tiny']['thumbnail'],
      videoUrl: json['videos']['medium']['url'],
      views: json['views'],
    );
  }
}
