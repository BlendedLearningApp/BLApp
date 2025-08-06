import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/worksheet_model.dart';
import '../models/forum_model.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // =============================================
  // ========
  // AUTHENTICATION METHODS
  // =====================================================

  /// Sign up a new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role.toString().split('.').last},
    );
  }

  /// Sign in user
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out user
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  /// Update user profile
  static Future<void> updateProfile(UserModel user) async {
    await _client.from('profiles').update(user.toJson()).eq('id', user.id);
  }

  // =====================================================
  // COURSE METHODS
  // =====================================================

  /// Get all approved courses
  static Future<List<CourseModel>> getApprovedCourses() async {
    final response = await _client
        .from('courses')
        .select('''
          *,
          profiles!instructor_id(name),
          videos(*),
          quizzes(*),
          worksheets(*)
        ''')
        .eq('is_approved', true)
        .order('created_at', ascending: false);

    return response.map<CourseModel>((json) {
      // Add instructor name to the course data
      json['instructor_name'] = json['profiles']['name'];
      return CourseModel.fromJson(json);
    }).toList();
  }

  /// Get courses by instructor
  static Future<List<CourseModel>> getCoursesByInstructor(
    String instructorId,
  ) async {
    final response = await _client
        .from('courses')
        .select('''
          *,
          profiles!instructor_id(name),
          videos(*),
          quizzes(*),
          worksheets(*)
        ''')
        .eq('instructor_id', instructorId)
        .order('created_at', ascending: false);

    return response.map<CourseModel>((json) {
      json['instructor_name'] = json['profiles']['name'];
      return CourseModel.fromJson(json);
    }).toList();
  }

  /// Get enrolled courses for student
  static Future<List<CourseModel>> getEnrolledCourses(String studentId) async {
    final response = await _client
        .from('enrollments')
        .select('''
          *,
          courses(
            *,
            profiles!instructor_id(name),
            videos(*),
            quizzes(*),
            worksheets(*)
          )
        ''')
        .eq('student_id', studentId)
        .order('enrolled_at', ascending: false);

    return response.map<CourseModel>((json) {
      final courseData = json['courses'];
      courseData['instructor_name'] = courseData['profiles']['name'];
      return CourseModel.fromJson(courseData);
    }).toList();
  }

  /// Create new course
  static Future<String> createCourse(CourseModel course) async {
    final response = await _client
        .from('courses')
        .insert(course.toJson())
        .select('id')
        .single();

    return response['id'];
  }

  /// Update course
  static Future<void> updateCourse(CourseModel course) async {
    await _client.from('courses').update(course.toJson()).eq('id', course.id);
  }

  /// Approve course (admin only)
  static Future<void> approveCourse(String courseId) async {
    await _client
        .from('courses')
        .update({'is_approved': true})
        .eq('id', courseId);
  }

  // =====================================================
  // ENROLLMENT METHODS
  // =====================================================

  /// Enroll student in course
  static Future<Map<String, dynamic>> enrollStudent(
    String studentId,
    String courseId,
  ) async {
    final response = await _client.rpc(
      'enroll_student',
      params: {'student_uuid': studentId, 'course_uuid': courseId},
    );

    return response;
  }

  /// Get enrollment progress
  static Future<double> getCourseProgress(
    String studentId,
    String courseId,
  ) async {
    final response = await _client
        .from('enrollments')
        .select('progress')
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .single();

    return (response['progress'] ?? 0.0).toDouble();
  }

  // =====================================================
  // VIDEO METHODS
  // =====================================================

  /// Get videos for course
  static Future<List<VideoModel>> getCourseVideos(String courseId) async {
    final response = await _client
        .from('videos')
        .select()
        .eq('course_id', courseId)
        .order('order_index');

    return response
        .map<VideoModel>((json) => VideoModel.fromJson(json))
        .toList();
  }

  /// Mark video as watched
  static Future<Map<String, dynamic>> markVideoWatched(
    String videoId,
    String studentId,
    int watchTime,
  ) async {
    final response = await _client.rpc(
      'mark_video_watched',
      params: {
        'video_uuid': videoId,
        'student_uuid': studentId,
        'watch_time': watchTime,
      },
    );

    return response;
  }

  /// Get video progress for student
  static Future<Map<String, bool>> getVideoProgress(
    String studentId,
    String courseId,
  ) async {
    final response = await _client
        .from('video_progress')
        .select('video_id, is_watched')
        .eq('student_id', studentId);

    final Map<String, bool> progress = {};
    for (final item in response) {
      progress[item['video_id']] = item['is_watched'] ?? false;
    }

    return progress;
  }

  // =====================================================
  // QUIZ METHODS
  // =====================================================

  /// Get quiz with questions
  static Future<QuizModel?> getQuizWithQuestions(String quizId) async {
    final response = await _client
        .from('quizzes')
        .select('''
          *,
          questions(*)
        ''')
        .eq('id', quizId)
        .single();

    return QuizModel.fromJson(response);
  }

  /// Submit quiz
  static Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    String studentId,
    Map<String, int> answers,
    int timeSpent,
  ) async {
    final response = await _client.rpc(
      'submit_quiz',
      params: {
        'quiz_uuid': quizId,
        'student_uuid': studentId,
        'answers_json': answers,
        'time_spent': timeSpent,
      },
    );

    return response;
  }

  /// Get quiz submissions for student
  static Future<List<QuizSubmissionModel>> getQuizSubmissions(
    String studentId,
  ) async {
    final response = await _client
        .from('quiz_submissions')
        .select()
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);

    return response
        .map<QuizSubmissionModel>((json) => QuizSubmissionModel.fromJson(json))
        .toList();
  }

  // =====================================================
  // FORUM METHODS
  // =====================================================

  /// Get forum posts for course
  static Future<List<ForumPostModel>> getForumPosts(String courseId) async {
    final response = await _client
        .from('forum_posts')
        .select('''
          *,
          profiles!author_id(name, profile_image),
          forum_replies(
            *,
            profiles!author_id(name, profile_image)
          )
        ''')
        .eq('course_id', courseId)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);

    return response.map<ForumPostModel>((json) {
      // Add author info
      json['author_name'] = json['profiles']['name'];
      json['author_avatar'] = json['profiles']['profile_image'];

      // Process replies
      final replies = (json['forum_replies'] as List).map((reply) {
        reply['author_name'] = reply['profiles']['name'];
        reply['author_avatar'] = reply['profiles']['profile_image'];
        return ForumReplyModel.fromJson(reply);
      }).toList();

      json['replies'] = replies.map((r) => r.toJson()).toList();

      return ForumPostModel.fromJson(json);
    }).toList();
  }

  /// Create forum post
  static Future<String> createForumPost(ForumPostModel post) async {
    final response = await _client
        .from('forum_posts')
        .insert({
          'title': post.title,
          'content': post.content,
          'author_id': post.authorId,
          'course_id': post.courseId,
        })
        .select('id')
        .single();

    return response['id'];
  }

  /// Create forum reply
  static Future<String> createForumReply(ForumReplyModel reply) async {
    final response = await _client
        .from('forum_replies')
        .insert({
          'post_id': reply.postId,
          'content': reply.content,
          'author_id': reply.authorId,
        })
        .select('id')
        .single();

    return response['id'];
  }

  // =====================================================
  // ANALYTICS METHODS
  // =====================================================

  /// Get course analytics
  static Future<Map<String, dynamic>> getCourseAnalytics(
    String courseId,
  ) async {
    final response = await _client.rpc(
      'get_course_analytics',
      params: {'course_uuid': courseId},
    );

    return response;
  }

  /// Get student analytics
  static Future<Map<String, dynamic>> getStudentAnalytics(
    String studentId,
  ) async {
    final response = await _client.rpc(
      'get_student_analytics',
      params: {'student_uuid': studentId},
    );

    return response;
  }

  /// Get instructor analytics
  static Future<Map<String, dynamic>> getInstructorAnalytics(
    String instructorId,
  ) async {
    final response = await _client.rpc(
      'get_instructor_analytics',
      params: {'instructor_uuid': instructorId},
    );

    return response;
  }

  /// Get system analytics
  static Future<Map<String, dynamic>> getSystemAnalytics() async {
    final response = await _client.rpc('get_system_analytics');
    return response;
  }

  // =====================================================
  // STORAGE METHODS
  // =====================================================

  /// Upload file to storage
  static Future<String> uploadFile(
    String filePath,
    List<int> fileBytes,
    String fileName,
  ) async {
    await _client.storage
        .from('storage-bucket')
        .uploadBinary(filePath, Uint8List.fromList(fileBytes));

    return _client.storage.from('storage-bucket').getPublicUrl(filePath);
  }

  /// Delete file from storage
  static Future<void> deleteFile(String filePath) async {
    await _client.storage.from('storage-bucket').remove([filePath]);
  }
}
