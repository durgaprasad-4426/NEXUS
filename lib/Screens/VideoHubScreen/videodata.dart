
class VideoData {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String views;
  final String likes;
  final List<String> tags;

  VideoData({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.views,
    required this.likes,
    required this.tags,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'],
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      duration: json['contentDetails']['duration'], // ISO8601 string
      views: json['statistics']['viewCount'],
      likes: json['statistics']['likeCount'] ?? "0",
      tags: (json['snippet']['tags'] != null)
          ? List<String>.from(json['snippet']['tags']).take(2).toList()
          : [],
    );
  }
}
