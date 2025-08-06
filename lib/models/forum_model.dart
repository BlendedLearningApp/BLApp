class ForumPostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String courseId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ForumReplyModel> replies;
  final int likesCount;
  final bool isLiked;
  final bool isPinned;

  ForumPostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.courseId,
    required this.createdAt,
    this.updatedAt,
    this.replies = const [],
    this.likesCount = 0,
    this.isLiked = false,
    this.isPinned = false,
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    return ForumPostModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      courseId: json['course_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((r) => ForumReplyModel.fromJson(r))
          .toList() ?? [],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isPinned: json['is_pinned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'course_id': courseId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'replies': replies.map((r) => r.toJson()).toList(),
      'likes_count': likesCount,
      'is_liked': isLiked,
      'is_pinned': isPinned,
    };
  }

  ForumPostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? courseId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ForumReplyModel>? replies,
    int? likesCount,
    bool? isLiked,
    bool? isPinned,
  }) {
    return ForumPostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      courseId: courseId ?? this.courseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class ForumReplyModel {
  final String id;
  final String postId;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final bool isLiked;

  ForumReplyModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory ForumReplyModel.fromJson(Map<String, dynamic> json) {
    return ForumReplyModel(
      id: json['id'],
      postId: json['post_id'],
      content: json['content'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }

  ForumReplyModel copyWith({
    String? id,
    String? postId,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return ForumReplyModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
