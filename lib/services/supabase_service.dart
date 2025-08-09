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

  /// Validate email format with enhanced rules
  static bool _isValidEmail(String email) {
    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // Additional validation rules
    final parts = email.split('@');
    if (parts.length != 2) return false;

    final localPart = parts[0];
    final domainPart = parts[1];

    // Local part should be at least 2 characters
    if (localPart.length < 2) return false;

    // Domain should have at least one dot and proper structure
    if (!domainPart.contains('.') || domainPart.length < 4) return false;

    // Domain should not start or end with dot or hyphen
    if (domainPart.startsWith('.') ||
        domainPart.endsWith('.') ||
        domainPart.startsWith('-') ||
        domainPart.endsWith('-')) {
      return false;
    }

    return true;
  }

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

  /// Enhanced sign up with role-specific data
  static Future<Map<String, dynamic>> enhancedSignUp({
    required String email,
    required String password,
    required Map<String, dynamic> userMetadata,
    required Map<String, dynamic> roleData,
  }) async {
    try {
      print('🚀 Starting enhanced signup for: $email');
      print('📋 User metadata: $userMetadata');
      print('🎯 Role data: $roleData');

      // Validate email format
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'error':
              'Please enter a valid email address with proper format (e.g., user@example.com)',
        };
      }

      // Sign up the user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );

      print('📧 Auth signup response: ${response.user?.id}');

      if (response.user != null) {
        print('✅ User created in auth, waiting for profile creation...');

        // Wait a moment for the profile to be created by trigger
        await Future.delayed(const Duration(milliseconds: 1000));

        // Create role-specific profile data
        if (roleData.isNotEmpty) {
          print('📝 Creating role-specific profile...');
          try {
            await _client.rpc(
              'create_role_specific_profile',
              params: {'profile_id': response.user!.id, 'role_data': roleData},
            );
            print('✅ Role-specific profile created successfully');
          } catch (rpcError) {
            print('⚠️ Role-specific profile creation failed: $rpcError');
            // Don't fail the entire signup for this
          }
        }

        print('🎉 Enhanced signup completed successfully');
        return {'success': true, 'user_id': response.user!.id};
      }

      print('❌ Auth signup failed - no user returned');
      return {'success': false, 'error': 'Failed to create user'};
    } catch (e) {
      print('💥 Enhanced signup error: $e');

      // Handle specific Supabase auth errors
      String errorMessage = 'Failed to create account. Please try again.';

      if (e.toString().contains('email_address_invalid')) {
        errorMessage =
            'Please enter a valid email address. Use a complete email like "user@example.com"';
      } else if (e.toString().contains('email_address_not_authorized')) {
        errorMessage =
            'This email domain is not authorized. Please use a different email address.';
      } else if (e.toString().contains('password')) {
        errorMessage = 'Password must be at least 6 characters long.';
      } else if (e.toString().contains('email_already_exists') ||
          e.toString().contains('already_registered')) {
        errorMessage =
            'An account with this email already exists. Please try logging in instead.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      }

      return {'success': false, 'error': errorMessage};
    }
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

  /// Refresh user profile (check for approval status changes)
  static Future<UserModel?> refreshUserProfile() async {
    return await getCurrentUserProfile();
  }

  /// Check if user login is allowed based on approval status
  static Future<Map<String, dynamic>> checkLoginPermission(
    String email,
    String password,
  ) async {
    try {
      // First try to sign in
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user profile to check approval status
        final profile = await getCurrentUserProfile();

        if (profile == null) {
          await _client.auth.signOut();
          return {'allowed': false, 'reason': 'profile_not_found'};
        }

        // Check approval status
        switch (profile.approvalStatus) {
          case 'approved':
            return {'allowed': true, 'profile': profile};
          case 'pending_approval':
            await _client.auth.signOut();
            return {'allowed': false, 'reason': 'pending_approval'};
          case 'rejected':
            await _client.auth.signOut();
            return {'allowed': false, 'reason': 'account_rejected'};
          default:
            await _client.auth.signOut();
            return {'allowed': false, 'reason': 'unknown_status'};
        }
      }

      return {'allowed': false, 'reason': 'invalid_credentials'};
    } catch (e) {
      return {'allowed': false, 'reason': 'login_error', 'error': e.toString()};
    }
  }

  // =====================================================
  // USER APPROVAL METHODS (Admin only)
  // =====================================================

  /// Get pending user registrations
  static Future<List<Map<String, dynamic>>> getPendingUsers() async {
    final response = await _client
        .from('profiles')
        .select('''
          *,
          student_profiles(*),
          instructor_profiles(*)
        ''')
        .eq('approval_status', 'pending_approval')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Approve a user
  static Future<bool> approveUser(String userId, String adminId) async {
    try {
      final result = await _client.rpc(
        'approve_user',
        params: {'user_id': userId, 'admin_id': adminId},
      );

      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// Reject a user
  static Future<bool> rejectUser(
    String userId,
    String adminId, {
    String? reason,
  }) async {
    try {
      final result = await _client.rpc(
        'reject_user',
        params: {'user_id': userId, 'admin_id': adminId, 'reason': reason},
      );

      return result == true;
    } catch (e) {
      return false;
    }
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

  /// Get all courses (both approved and pending) - for admin use
  static Future<List<CourseModel>> getAllCourses() async {
    final response = await _client
        .from('courses')
        .select('''
          *,
          profiles!instructor_id(name),
          videos(*),
          quizzes(
            *,
            questions(*)
          ),
          worksheets(*)
        ''')
        .order('created_at', ascending: false);

    return response.map<CourseModel>((json) {
      // Add instructor name to the course data
      json['instructor_name'] = json['profiles']['name'];
      return CourseModel.fromJson(json);
    }).toList();
  }

  /// Get pending courses (not approved) - for admin use
  static Future<List<CourseModel>> getPendingCourses() async {
    final response = await _client
        .from('courses')
        .select('''
          *,
          profiles!instructor_id(name),
          videos(*),
          quizzes(*),
          worksheets(*)
        ''')
        .eq('is_approved', false)
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
    print(
      '🔍 SupabaseService.getCoursesByInstructor() called for: $instructorId',
    );

    try {
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

      print('📊 Database response: ${response.length} courses found');

      final courses = response.map<CourseModel>((json) {
        json['instructor_name'] = json['profiles']['name'];
        return CourseModel.fromJson(json);
      }).toList();

      print('✅ Successfully parsed ${courses.length} courses');
      for (int i = 0; i < courses.length; i++) {
        print('   Course ${i + 1}: ${courses[i].title} (${courses[i].id})');
      }

      return courses;
    } catch (e) {
      print('❌ Error fetching courses by instructor: $e');
      rethrow;
    }
  }

  /// Get enrolled courses for student
  static Future<List<CourseModel>> getEnrolledCourses(String studentId) async {
    print('🔍 Fetching enrolled courses for student: $studentId');

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

    print('📊 Enrolled courses response: ${response.length} enrollments found');

    final courses = response.map<CourseModel>((json) {
      final courseData = json['courses'];
      courseData['instructor_name'] = courseData['profiles']['name'];
      return CourseModel.fromJson(courseData);
    }).toList();

    print('✅ Successfully parsed ${courses.length} enrolled courses');
    for (int i = 0; i < courses.length; i++) {
      print('   Course ${i + 1}: ${courses[i].title} (${courses[i].id})');
    }

    return courses;
  }

  /// Create new course
  static Future<String> createCourse(CourseModel course) async {
    try {
      print('🔄 Creating course: ${course.title}');
      print('📝 Course data: ${course.toJsonForDatabase()}');

      final response = await _client
          .from('courses')
          .insert(course.toJsonForDatabase())
          .select('id')
          .single();

      final courseId = response['id'];
      print('✅ Course created successfully with ID: $courseId');
      return courseId;
    } catch (e) {
      print('❌ Error creating course: $e');
      print('📊 Course data that failed: ${course.toJsonForDatabase()}');
      rethrow;
    }
  }

  /// Get course by ID with instructor name
  static Future<CourseModel> getCourseById(String courseId) async {
    final response = await _client
        .from('courses')
        .select('''
          *,
          profiles!instructor_id(name),
          videos(*),
          quizzes(*),
          worksheets(*)
        ''')
        .eq('id', courseId)
        .single();

    response['instructor_name'] = response['profiles']['name'];
    return CourseModel.fromJson(response);
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

  /// Reject course (admin only)
  static Future<void> rejectCourse(String courseId) async {
    await _client
        .from('courses')
        .update({'is_approved': false})
        .eq('id', courseId);
  }

  /// Delete course (admin only)
  static Future<void> deleteCourse(String courseId) async {
    await _client.from('courses').delete().eq('id', courseId);
  }

  // =====================================================
  // ENROLLMENT METHODS
  // =====================================================

  /// Enroll student in course
  static Future<Map<String, dynamic>> enrollStudent(
    String studentId,
    String courseId,
  ) async {
    try {
      print('🎓 Enrolling student $studentId in course $courseId');

      // First check if the course exists and is approved
      final courseResponse = await _client
          .from('courses')
          .select('id, is_approved')
          .eq('id', courseId)
          .single();

      if (!courseResponse['is_approved']) {
        return {'success': false, 'error': 'course_not_approved'};
      }

      // Check if student is already enrolled
      final existingEnrollment = await _client
          .from('enrollments')
          .select('id')
          .eq('student_id', studentId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existingEnrollment != null) {
        return {'success': false, 'error': 'already_enrolled_in_course'};
      }

      // Try using the RPC function first
      try {
        final response = await _client.rpc(
          'enroll_student',
          params: {'student_uuid': studentId, 'course_uuid': courseId},
        );

        print('📊 RPC Enrollment response: $response');

        // Handle the response properly
        if (response is Map<String, dynamic>) {
          return response;
        } else {
          // If response is not a map, assume success
          return {'success': true, 'enrollment_id': response};
        }
      } catch (rpcError) {
        print('⚠️ RPC function failed, trying direct insertion: $rpcError');

        // Fallback to creating enrollment via a custom function that bypasses RLS
        try {
          // Try a simpler RPC function that might exist
          final enrollmentResponse = await _client.rpc(
            'create_enrollment',
            params: {'p_student_id': studentId, 'p_course_id': courseId},
          );

          print('📊 Custom enrollment response: $enrollmentResponse');

          return {
            'success': true,
            'enrollment_id': enrollmentResponse,
            'method': 'custom_rpc',
          };
        } catch (customRpcError) {
          print('⚠️ Custom RPC also failed: $customRpcError');

          // Last resort: try direct insertion with error handling
          final enrollmentResponse = await _client
              .from('enrollments')
              .insert({
                'student_id': studentId,
                'course_id': courseId,
                'enrolled_at': DateTime.now().toIso8601String(),
                'progress': 0.0,
              })
              .select()
              .single();

          print('📊 Direct enrollment response: $enrollmentResponse');

          return {
            'success': true,
            'enrollment_id': enrollmentResponse['id'],
            'enrollment_data': enrollmentResponse,
            'method': 'direct_insert',
          };
        }
      }
    } catch (e) {
      print('❌ Error enrolling student: $e');

      // Parse specific error messages
      String errorMessage = 'enrollment_failed';
      if (e.toString().contains('already enrolled') ||
          e.toString().contains('duplicate key')) {
        errorMessage = 'already_enrolled_in_course';
      } else if (e.toString().contains('not approved')) {
        errorMessage = 'course_not_approved';
      } else if (e.toString().contains('not found')) {
        errorMessage = 'course_or_student_not_found';
      } else if (e.toString().contains('permission') ||
          e.toString().contains('row-level security policy') ||
          e.toString().contains('42501')) {
        errorMessage = 'enrollment_permission_denied';
      } else if (e.toString().contains('foreign key')) {
        errorMessage = 'course_or_student_not_found';
      }

      return {'success': false, 'error': errorMessage, 'details': e.toString()};
    }
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

  /// Get enrolled students for a specific course
  static Future<List<Map<String, dynamic>>> getEnrolledStudents(
    String courseId,
  ) async {
    print('🔍 Fetching enrolled students for course: $courseId');

    final response = await _client
        .from('enrollments')
        .select('''
          *,
          profiles!student_id(
            id,
            name,
            email,
            avatar_url
          )
        ''')
        .eq('course_id', courseId)
        .order('enrolled_at', ascending: false);

    print(
      '📊 Enrolled students response: ${response.length} enrollments found',
    );

    final students = response.map<Map<String, dynamic>>((json) {
      final profileData = json['profiles'];
      return {
        'enrollment_id': json['id'],
        'student_id': json['student_id'],
        'enrolled_at': json['enrolled_at'],
        'progress': json['progress'] ?? 0.0,
        'is_completed': json['is_completed'] ?? false,
        'completed_at': json['completed_at'],
        'student_name': profileData['name'],
        'student_email': profileData['email'],
        'student_avatar': profileData['avatar_url'],
      };
    }).toList();

    print('✅ Successfully parsed ${students.length} enrolled students');
    return students;
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

  /// Create new video for course
  static Future<String> createVideo(VideoModel video) async {
    print('🎬 SupabaseService.createVideo() called');
    print('📝 Video data to insert:');
    print('   Title: ${video.title}');
    print('   Course ID: ${video.courseId}');
    print('   YouTube URL: ${video.youtubeUrl}');
    print('   YouTube Video ID: ${video.youtubeVideoId}');
    print('   Order Index: ${video.orderIndex}');

    try {
      final videoData = {
        'title': video.title,
        'description': video.description,
        'youtube_url': video.youtubeUrl,
        'youtube_video_id': video.youtubeVideoId,
        'course_id': video.courseId,
        'order_index': video.orderIndex,
        'duration_seconds': video.durationSeconds,
        'thumbnail': video.thumbnail,
      };

      print('📊 Inserting video data: $videoData');

      final response = await _client
          .from('videos')
          .insert(videoData)
          .select('id')
          .single();

      final videoId = response['id'];
      print('✅ Video created successfully with ID: $videoId');
      return videoId;
    } catch (e) {
      print('❌ Error creating video in database: $e');
      print('📊 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Update existing video
  static Future<void> updateVideo(VideoModel video) async {
    await _client
        .from('videos')
        .update({
          'title': video.title,
          'description': video.description,
          'youtube_url': video.youtubeUrl,
          'youtube_video_id': video.youtubeVideoId,
          'order_index': video.orderIndex,
          'duration_seconds': video.durationSeconds,
          'thumbnail': video.thumbnail,
        })
        .eq('id', video.id);
  }

  /// Delete video
  static Future<void> deleteVideo(String videoId) async {
    await _client.from('videos').delete().eq('id', videoId);
  }

  /// Reorder videos in course
  static Future<void> reorderVideos(
    String courseId,
    List<String> videoIds,
  ) async {
    for (int i = 0; i < videoIds.length; i++) {
      await _client
          .from('videos')
          .update({'order_index': i + 1})
          .eq('id', videoIds[i])
          .eq('course_id', courseId);
    }
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

  /// Create new quiz for course
  static Future<String> createQuiz(QuizModel quiz) async {
    print('📝 SupabaseService.createQuiz() called');
    print('📊 Quiz data to insert:');
    print('   Title: ${quiz.title}');
    print('   Course ID: ${quiz.courseId}');
    print('   Time limit: ${quiz.timeLimit} minutes');
    print('   Passing score: ${quiz.passingScore}%');
    print('   Questions count: ${quiz.questions.length}');

    try {
      // First create the quiz
      final quizData = {
        'title': quiz.title,
        'description': quiz.description,
        'course_id': quiz.courseId,
        'time_limit': quiz.timeLimit,
        'passing_score': quiz.passingScore,
        'is_active': quiz.isActive,
      };

      print('📋 Inserting quiz data: $quizData');

      final quizResponse = await _client
          .from('quizzes')
          .insert(quizData)
          .select('id')
          .single();

      final quizId = quizResponse['id'];
      print('✅ Quiz created in database with ID: $quizId');

      // Then create the questions
      if (quiz.questions.isNotEmpty) {
        print('📝 Creating ${quiz.questions.length} questions...');

        final questionsData = quiz.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final questionData = {
            'quiz_id': quizId,
            'question': question.question,
            'options': question.options,
            'correct_answer_index': question.correctAnswerIndex,
            'explanation': question.explanation,
            'points': question.points,
            'order_index': index,
          };

          print('   Question ${index + 1}: ${question.question}');
          print('     Options: ${question.options}');
          print('     Correct answer: ${question.correctAnswerIndex}');

          return questionData;
        }).toList();

        print('📋 Inserting questions data...');
        await _client.from('questions').insert(questionsData);
        print('✅ All questions created successfully');
      } else {
        print('⚠️ No questions to create');
      }

      print('🎉 Quiz creation completed successfully!');
      return quizId;
    } catch (e) {
      print('❌ Error creating quiz in database: $e');
      print('📊 Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('🔍 Postgrest error details: ${e.message}');
        print('🔍 Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }

  /// Update existing quiz
  static Future<void> updateQuiz(QuizModel quiz) async {
    print('📝 SupabaseService.updateQuiz() called');
    print('📊 Quiz update data:');
    print('   Quiz ID: ${quiz.id}');
    print('   Title: ${quiz.title}');
    print('   Questions count: ${quiz.questions.length}');

    try {
      // Update quiz metadata
      final quizData = {
        'title': quiz.title,
        'description': quiz.description,
        'time_limit': quiz.timeLimit,
        'passing_score': quiz.passingScore,
        'is_active': quiz.isActive,
      };

      print('📋 Updating quiz metadata: $quizData');
      await _client.from('quizzes').update(quizData).eq('id', quiz.id);

      print('✅ Quiz metadata updated successfully');

      // Delete existing questions
      print('🗑️ Deleting existing questions for quiz: ${quiz.id}');
      await _client.from('questions').delete().eq('quiz_id', quiz.id);
      print('✅ Existing questions deleted');

      // Insert updated questions
      if (quiz.questions.isNotEmpty) {
        print('📝 Inserting ${quiz.questions.length} updated questions...');

        final questionsData = quiz.questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          final questionData = {
            'quiz_id': quiz.id,
            'question': question.question,
            'options': question.options,
            'correct_answer_index': question.correctAnswerIndex,
            'explanation': question.explanation,
            'points': question.points,
            'order_index': index,
          };

          print('   Question ${index + 1}: ${question.question}');
          return questionData;
        }).toList();

        await _client.from('questions').insert(questionsData);
        print('✅ All updated questions inserted successfully');
      } else {
        print('⚠️ No questions to insert');
      }

      print('🎉 Quiz update completed successfully!');
    } catch (e) {
      print('❌ Error updating quiz in database: $e');
      print('📊 Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('🔍 Postgrest error details: ${e.message}');
        print('🔍 Postgrest error code: ${e.code}');
      }
      rethrow;
    }
  }

  /// Delete quiz and its questions
  static Future<void> deleteQuiz(String quizId) async {
    // Questions will be deleted automatically due to CASCADE constraint
    await _client.from('quizzes').delete().eq('id', quizId);
  }

  /// Get quizzes for course
  static Future<List<QuizModel>> getCourseQuizzes(String courseId) async {
    final response = await _client
        .from('quizzes')
        .select('''
          *,
          questions(*)
        ''')
        .eq('course_id', courseId)
        .order('created_at');

    return response.map<QuizModel>((json) => QuizModel.fromJson(json)).toList();
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

  /// Get quiz submissions for a specific quiz (for instructors)
  static Future<List<QuizSubmissionModel>> getQuizSubmissionsByQuizId(
    String quizId,
  ) async {
    print('📊 SupabaseService.getQuizSubmissionsByQuizId() called');
    print('📊 Quiz ID: $quizId');

    try {
      final response = await _client
          .from('quiz_submissions')
          .select('''
            *,
            profiles!quiz_submissions_student_id_fkey(name, email)
          ''')
          .eq('quiz_id', quizId)
          .order('submitted_at', ascending: false);

      print('✅ Found ${response.length} submissions for quiz');

      return response.map<QuizSubmissionModel>((json) {
        // Add student name from the joined profile data
        if (json['profiles'] != null) {
          json['student_name'] = json['profiles']['name'] ?? 'Unknown Student';
          json['student_email'] = json['profiles']['email'] ?? '';
        }
        return QuizSubmissionModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('❌ Error getting quiz submissions: $e');
      if (e is PostgrestException) {
        print('🔍 Postgrest error details: ${e.message}');
        print('🔍 Postgrest error code: ${e.code}');
      }
      rethrow;
    }
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
  // USER MANAGEMENT METHODS (ADMIN)
  // =====================================================

  /// Get all users for admin management
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  /// Get users by approval status
  static Future<List<UserModel>> getUsersByApprovalStatus(String status) async {
    try {
      final response = await _client
          .from('profiles')
          .select('*')
          .eq('approval_status', status)
          .order('created_at', ascending: false);

      return response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching users by approval status: $e');
      return [];
    }
  }

  /// Get pending approval users
  static Future<List<UserModel>> getPendingApprovalUsers() async {
    return getUsersByApprovalStatus('pending_approval');
  }

  /// Update user approval status
  static Future<bool> updateUserApprovalStatus(
    String userId,
    String status,
  ) async {
    try {
      print('🔄 Updating user approval status: $userId -> $status');

      final updateData = {
        'approval_status': status,
        'approved_at': status == 'approved'
            ? DateTime.now().toIso8601String()
            : null,
      };

      print('📝 Update data: $updateData');

      final result = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select();

      print('📊 Update result: $result');
      print('✅ User approval status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating user approval status: $e');
      print('❌ Error details: ${e.toString()}');
      return false;
    }
  }

  /// Approve user (admin method)
  static Future<bool> approveUserAdmin(String userId) async {
    return updateUserApprovalStatus(userId, 'approved');
  }

  /// Reject user (admin method)
  static Future<bool> rejectUserAdmin(String userId) async {
    return updateUserApprovalStatus(userId, 'rejected');
  }

  /// Update user active status
  static Future<bool> updateUserActiveStatus(
    String userId,
    bool isActive,
  ) async {
    try {
      print('🔄 Updating user active status: $userId -> $isActive');

      await _client
          .from('profiles')
          .update({'is_active': isActive})
          .eq('id', userId);

      print('✅ User active status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating user active status: $e');
      return false;
    }
  }

  /// Delete user profile (admin only)
  static Future<bool> deleteUserProfile(String userId) async {
    try {
      print('🗑️ Deleting user profile: $userId');

      // Note: This only deletes the profile, not the auth user
      // Auth user deletion requires admin API calls
      await _client.from('profiles').delete().eq('id', userId);

      print('✅ User profile deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting user profile: $e');
      return false;
    }
  }

  /// Get user statistics for admin dashboard
  static Future<Map<String, int>> getUserStatistics() async {
    try {
      final allUsers = await _client
          .from('profiles')
          .select('approval_status, is_active, role');

      final stats = <String, int>{
        'total_users': allUsers.length,
        'pending_approvals': 0,
        'approved_users': 0,
        'rejected_users': 0,
        'active_users': 0,
        'inactive_users': 0,
        'students': 0,
        'instructors': 0,
        'admins': 0,
      };

      for (final user in allUsers) {
        // Approval status counts
        switch (user['approval_status']) {
          case 'pending':
            stats['pending_approvals'] = stats['pending_approvals']! + 1;
            break;
          case 'approved':
            stats['approved_users'] = stats['approved_users']! + 1;
            break;
          case 'rejected':
            stats['rejected_users'] = stats['rejected_users']! + 1;
            break;
        }

        // Active status counts
        if (user['is_active'] == true) {
          stats['active_users'] = stats['active_users']! + 1;
        } else {
          stats['inactive_users'] = stats['inactive_users']! + 1;
        }

        // Role counts
        switch (user['role']) {
          case 'student':
            stats['students'] = stats['students']! + 1;
            break;
          case 'instructor':
            stats['instructors'] = stats['instructors']! + 1;
            break;
          case 'admin':
            stats['admins'] = stats['admins']! + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      print('Error fetching user statistics: $e');
      return {};
    }
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
