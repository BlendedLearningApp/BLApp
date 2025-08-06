import '../utils/youtube_utils.dart';

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final String youtubeVideoId;
  final String courseId;
  final int orderIndex;
  final int durationSeconds;
  final String? thumbnail;
  final DateTime createdAt;
  final bool isWatched;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    required this.courseId,
    required this.orderIndex,
    this.durationSeconds = 0,
    this.thumbnail,
    required this.createdAt,
    this.isWatched = false,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      youtubeVideoId: json['youtube_video_id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      orderIndex: json['order_index'] is int
          ? json['order_index']
          : int.tryParse(json['order_index']?.toString() ?? '0') ?? 0,
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds']
          : int.tryParse(json['duration_seconds']?.toString() ?? '0') ?? 0,
      thumbnail: json['thumbnail']?.toString(),
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isWatched:
          json['is_watched'] == true ||
          json['is_watched']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'youtube_url': youtubeUrl,
      'youtube_video_id': youtubeVideoId,
      'course_id': courseId,
      'order_index': orderIndex,
      'duration_seconds': durationSeconds,
      'thumbnail': thumbnail,
      'created_at': createdAt.toIso8601String(),
      'is_watched': isWatched,
    };
  }

  // Extract YouTube video ID from URL using the utility class
  static String extractVideoId(String url) {
    return YouTubeUtils.extractVideoIdFromUrl(url) ?? '';
  }

  // Get the best available video ID (prioritize extracted from URL)
  String get bestVideoId {
    return YouTubeUtils.getBestVideoId(youtubeUrl, youtubeVideoId) ?? '';
  }

  // Validate if the video has a valid YouTube ID
  bool get hasValidVideoId {
    return YouTubeUtils.isValidVideoId(bestVideoId);
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? youtubeUrl,
    String? youtubeVideoId,
    String? courseId,
    int? orderIndex,
    int? durationSeconds,
    String? thumbnail,
    DateTime? createdAt,
    bool? isWatched,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      courseId: courseId ?? this.courseId,
      orderIndex: orderIndex ?? this.orderIndex,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
      isWatched: isWatched ?? this.isWatched,
    );
  }
}
