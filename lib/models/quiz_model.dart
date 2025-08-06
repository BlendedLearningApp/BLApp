class QuizModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final List<QuestionModel> questions;
  final int timeLimit; // in minutes
  final int passingScore; // percentage
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.questions = const [],
    this.timeLimit = 30,
    this.passingScore = 70,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['course_id'],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      timeLimit: json['time_limit'] ?? 30,
      passingScore: json['passing_score'] ?? 70,
      createdAt: DateTime.parse(json['created_at']),
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
      'course_id': courseId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'time_limit': timeLimit,
      'passing_score': passingScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    List<QuestionModel>? questions,
    int? timeLimit,
    int? passingScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      questions: questions ?? this.questions,
      timeLimit: timeLimit ?? this.timeLimit,
      passingScore: passingScore ?? this.passingScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final int points;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
    this.points = 1,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correct_answer_index'],
      explanation: json['explanation'] ?? '',
      points: json['points'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'points': points,
    };
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    int? points,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
    );
  }
}

class QuizSubmissionModel {
  final String id;
  final String quizId;
  final String studentId;
  final Map<String, int> answers; // questionId -> selectedAnswerIndex
  final int score;
  final int totalQuestions;
  final DateTime submittedAt;
  final int timeSpentMinutes;
  final bool passed;

  QuizSubmissionModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.answers,
    required this.score,
    required this.totalQuestions,
    required this.submittedAt,
    required this.timeSpentMinutes,
    required this.passed,
  });

  factory QuizSubmissionModel.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionModel(
      id: json['id'],
      quizId: json['quiz_id'],
      studentId: json['student_id'],
      answers: Map<String, int>.from(json['answers']),
      score: json['score'],
      totalQuestions: json['total_questions'],
      submittedAt: DateTime.parse(json['submitted_at']),
      timeSpentMinutes: json['time_spent_minutes'],
      passed: json['passed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'student_id': studentId,
      'answers': answers,
      'score': score,
      'total_questions': totalQuestions,
      'submitted_at': submittedAt.toIso8601String(),
      'time_spent_minutes': timeSpentMinutes,
      'passed': passed,
    };
  }

  double get percentage => (score / totalQuestions) * 100;
}
