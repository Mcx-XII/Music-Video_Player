enum HistoryType { video, audio }

class HistoryItem {
  final HistoryType type;
  final String title;
  final String url;
  final String thumbnail; // online only
  final String? assetId;  // LOCAL MEDIA
  final DateTime playedAt;

  HistoryItem({
    required this.type,
    required this.title,
    required this.url,
    required this.thumbnail,
    this.assetId,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'url': url,
        'thumbnail': thumbnail,
        'assetId': assetId,
        'playedAt': playedAt.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      type: HistoryType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      title: json['title'],
      url: json['url'],
      thumbnail: json['thumbnail'],
      assetId: json['assetId'],
      playedAt: DateTime.parse(json['playedAt']),
    );
  }
}
