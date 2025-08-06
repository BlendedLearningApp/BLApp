class WorksheetModel {
  final String id;
  final String title;
  final String? description;
  final String fileType;
  final String fileSize;
  final String? fileUrl;
  final String courseId;
  final String instructorId;
  final DateTime uploadedAt;
  final DateTime? updatedAt;
  final bool isActive;

  WorksheetModel({
    required this.id,
    required this.title,
    this.description,
    required this.fileType,
    required this.fileSize,
    this.fileUrl,
    required this.courseId,
    required this.instructorId,
    required this.uploadedAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory WorksheetModel.fromJson(Map<String, dynamic> json) {
    return WorksheetModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      fileUrl: json['file_url'],
      courseId: json['course_id'],
      instructorId: json['instructor_id'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file_type': fileType,
      'file_size': fileSize,
      'file_url': fileUrl,
      'course_id': courseId,
      'instructor_id': instructorId,
      'uploaded_at': uploadedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  WorksheetModel copyWith({
    String? id,
    String? title,
    String? description,
    String? fileType,
    String? fileSize,
    String? fileUrl,
    String? courseId,
    String? instructorId,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return WorksheetModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      fileUrl: fileUrl ?? this.fileUrl,
      courseId: courseId ?? this.courseId,
      instructorId: instructorId ?? this.instructorId,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'WorksheetModel(id: $id, title: $title, fileType: $fileType, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorksheetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
