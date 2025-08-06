import 'video_model.dart';
import 'quiz_model.dart';
import 'worksheet_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String? thumbnail;
  final List<VideoModel> videos;
  final List<QuizModel> quizzes;
  final List<WorksheetModel> worksheets;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isApproved;
  final int enrolledStudents;
  final double rating;
  final String category;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    this.thumbnail,
    this.videos = const [],
    this.quizzes = const [],
    this.worksheets = const [],
    required this.createdAt,
    this.updatedAt,
    this.isApproved = false,
    this.enrolledStudents = 0,
    this.rating = 0.0,
    required this.category,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructorId: json['instructor_id'],
      instructorName: json['instructor_name'],
      thumbnail: json['thumbnail'],
      videos: (json['videos'] as List<dynamic>?)
          ?.map((v) => VideoModel.fromJson(v))
          .toList() ?? [],
      quizzes: (json['quizzes'] as List<dynamic>?)
          ?.map((q) => QuizModel.fromJson(q))
          .toList() ?? [],
      worksheets: (json['worksheets'] as List<dynamic>?)
          ?.map((w) => WorksheetModel.fromJson(w))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      isApproved: json['is_approved'] ?? false,
      enrolledStudents: json['enrolled_students'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'thumbnail': thumbnail,
      'videos': videos.map((v) => v.toJson()).toList(),
      'quizzes': quizzes.map((q) => q.toJson()).toList(),
      'worksheets': worksheets.map((w) => w.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_approved': isApproved,
      'enrolled_students': enrolledStudents,
      'rating': rating,
      'category': category,
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? instructorId,
    String? instructorName,
    String? thumbnail,
    List<VideoModel>? videos,
    List<QuizModel>? quizzes,
    List<WorksheetModel>? worksheets,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isApproved,
    int? enrolledStudents,
    double? rating,
    String? category,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      thumbnail: thumbnail ?? this.thumbnail,
      videos: videos ?? this.videos,
      quizzes: quizzes ?? this.quizzes,
      worksheets: worksheets ?? this.worksheets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isApproved: isApproved ?? this.isApproved,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      rating: rating ?? this.rating,
      category: category ?? this.category,
    );
  }
}


