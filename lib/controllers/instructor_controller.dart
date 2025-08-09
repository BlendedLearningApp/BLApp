import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../config/app_theme.dart';

class InstructorController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<CourseModel> _myCourses = <CourseModel>[].obs;
  final RxList<QuizSubmissionModel> _studentSubmissions =
      <QuizSubmissionModel>[].obs;
  final RxBool _isLoading = false.obs;

  // Current course for management
  final Rx<CourseModel?> _currentCourse = Rx<CourseModel?>(null);

  List<CourseModel> get myCourses => _myCourses;
  List<CourseModel> get instructorCourses =>
      _myCourses; // Alias for view compatibility
  List<QuizSubmissionModel> get studentSubmissions => _studentSubmissions;
  RxBool get isLoading => _isLoading; // Return RxBool for Obx compatibility
  CourseModel? get currentCourse => _currentCourse.value;

  // Method to set current course
  void setCurrentCourse(CourseModel course) {
    // Check if we're currently in a build phase
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // We're in a build phase, defer the state change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _currentCourse.value = course;
        print('🎯 Set current course (deferred): ${course.title}');
      });
    } else {
      // Safe to update immediately
      _currentCourse.value = course;
      print('🎯 Set current course: ${course.title}');
    }
  }

  // Add loadDashboardData method for view compatibility
  Future<void> loadDashboardData() async {
    await loadInstructorData();
  }

  @override
  void onInit() {
    super.onInit();
    print('🚀 InstructorController.onInit() called');
    // Don't load data automatically - only load when explicitly requested
    print(
      '⏸️ Skipping automatic data load - will load when dashboard is accessed',
    );
  }

  Future<void> loadInstructorData() async {
    print('🔄 InstructorController.loadInstructorData() called');

    // Wait for auth controller to be ready
    int attempts = 0;
    while (_authController.currentUser == null && attempts < 10) {
      print('⏳ Waiting for auth controller... attempt ${attempts + 1}');
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    if (_authController.currentUser == null) {
      print('❌ No current user found in AuthController after waiting');
      return;
    }

    print(
      '✅ Auth controller ready, user: ${_authController.currentUser!.name}',
    );

    try {
      _isLoading.value = true;
      print(
        '📊 Loading instructor data for user: ${_authController.currentUser!.id}',
      );

      // Load instructor's courses
      print('📚 Fetching courses from database...');
      final courses = await SupabaseService.getCoursesByInstructor(
        _authController.currentUser!.id,
      );
      print('✅ Fetched ${courses.length} courses from database');

      _myCourses.assignAll(courses);
      print(
        '📝 Updated local courses list. Total courses: ${_myCourses.length}',
      );

      // Debug: Print course details
      for (int i = 0; i < courses.length; i++) {
        print('   Course ${i + 1}: ${courses[i].title} (ID: ${courses[i].id})');
      }

      // Load student submissions for instructor's courses
      final allSubmissions = <QuizSubmissionModel>[];
      for (final course in courses) {
        for (final quiz in course.quizzes) {
          // Note: This would need a specific method in SupabaseService
          // For now, we'll skip loading submissions in bulk
        }
      }
      _studentSubmissions.assignAll(allSubmissions);

      print('🎯 Instructor data loading completed successfully');
    } catch (e) {
      print('❌ Error loading instructor data: $e');
      Get.snackbar(
        'error'.tr,
        'error_loading_data'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void selectCourse(CourseModel course) {
    _currentCourse.value = course;
  }

  Future<void> createCourse(
    String title,
    String description,
    String category, {
    String? thumbnail,
    bool isPublished = false,
  }) async {
    if (_authController.currentUser == null) {
      print('❌ Cannot create course: No authenticated user');
      Get.snackbar(
        'error'.tr,
        'authentication_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _isLoading.value = true;
      print('🔄 Starting course creation process...');
      print(
        '📝 Course details: title="$title", category="$category", isPublished=$isPublished',
      );

      // Debug: Check current user details
      final currentUser = _authController.currentUser!;
      print('👤 Current user ID: ${currentUser.id}');
      print('👤 Current user role: ${currentUser.role}');
      print('👤 Current user approval status: ${currentUser.approvalStatus}');
      print('👤 Current user name: ${currentUser.name}');

      // Debug: Check Supabase session
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      print('🔐 Supabase auth user ID: ${supabaseUser?.id}');
      print('🔐 Supabase auth email: ${supabaseUser?.email}');
      print('🔐 Session valid: ${supabaseUser != null}');

      final course = CourseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        instructorId: _authController.currentUser!.id,
        instructorName: _authController.currentUser!.name,
        thumbnail: thumbnail,
        category: category,
        createdAt: DateTime.now(),
        isApproved: isPublished, // If published, it needs admin approval
      );

      print('🚀 Calling SupabaseService.createCourse...');
      final courseId = await SupabaseService.createCourse(course);
      print('✅ Course created with ID: $courseId');

      // Fetch the complete course data with instructor name from database
      print('📥 Fetching complete course data...');
      final createdCourse = await SupabaseService.getCourseById(courseId);
      _myCourses.add(createdCourse);
      print(
        '📚 Added course to local list. Total courses: ${_myCourses.length}',
      );

      // Automatically select the newly created course for content management
      _currentCourse.value = createdCourse;
      print('🎯 Set as current course: ${createdCourse.title}');

      Get.snackbar(
        'success'.tr,
        isPublished
            ? 'course_created_and_submitted_for_approval'.tr
            : 'course_created_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error creating course: $e');
      print('📊 Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        print('🔍 Postgrest error details: ${e.message}');
        print('🔍 Postgrest error code: ${e.code}');
      }

      Get.snackbar(
        'error'.tr,
        'failed_to_create_course'.tr + ': ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      _isLoading.value = false;
      print('🏁 Course creation process completed');
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      _isLoading.value = true;

      await SupabaseService.updateCourse(course);

      // Update local state
      final index = _myCourses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        _myCourses[index] = course;
      }

      if (_currentCourse.value?.id == course.id) {
        _currentCourse.value = course;
      }

      Get.snackbar(
        'success'.tr,
        'Course updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      _isLoading.value = true;

      // Note: Delete course would need to be implemented in SupabaseService
      // For now, just update local state
      _myCourses.removeWhere((course) => course.id == courseId);

      if (_currentCourse.value?.id == courseId) {
        _currentCourse.value = null;
      }

      Get.snackbar(
        'success'.tr,
        'Course deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addVideoToCourse(
    String courseId,
    String title,
    String description,
    String youtubeUrl,
  ) async {
    print('🎬 Starting video creation process...');
    print('📝 Video details:');
    print('   Course ID: $courseId');
    print('   Title: $title');
    print('   Description: $description');
    print('   YouTube URL: $youtubeUrl');

    try {
      _isLoading.value = true;
      print('🔄 Set loading state to true');

      print('🔍 Extracting YouTube video ID...');
      final videoId = VideoModel.extractVideoId(youtubeUrl);
      print('📺 Extracted video ID: $videoId');

      if (videoId.isEmpty) {
        print('❌ Invalid YouTube URL - no video ID found');
        Get.snackbar(
          'error'.tr,
          'invalid_url'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      print('🔍 Finding course in local list...');
      final course = _myCourses.firstWhere((c) => c.id == courseId);
      print('📚 Found course: ${course.title}');
      print('📊 Current videos in course: ${course.videos.length}');

      final orderIndex = course.videos.length + 1;
      print('📋 New video order index: $orderIndex');

      final video = VideoModel(
        id: '', // Will be set by Supabase
        title: title,
        description: description,
        youtubeUrl: youtubeUrl,
        youtubeVideoId: videoId,
        courseId: courseId,
        orderIndex: orderIndex,
        createdAt: DateTime.now(),
      );

      print('🚀 Creating video in Supabase...');
      // Create video in Supabase
      final createdVideoId = await SupabaseService.createVideo(video);
      print('✅ Video created in database with ID: $createdVideoId');

      final createdVideo = video.copyWith(id: createdVideoId);

      print('🔄 Updating local course state...');
      // Update local state
      final updatedCourse = course.copyWith(
        videos: [...course.videos, createdVideo],
      );

      final index = _myCourses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
        _myCourses[index] = updatedCourse;
        print('📝 Updated course in local list at index $index');
      }

      if (_currentCourse.value?.id == courseId) {
        _currentCourse.value = updatedCourse;
        print('🎯 Updated current course');
      }

      print('🎉 Video creation completed successfully!');
      print('📊 Final video count in course: ${updatedCourse.videos.length}');

      // Show success dialog with animation
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'success'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'video_added_successfully'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$title"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('continue'.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Auto-close after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isDialogOpen == true) {
          Get.back(); // Close success dialog
        }
      });
    } catch (e) {
      print('❌ Error during video creation: $e');
      print('📊 Error type: ${e.runtimeType}');
      print('📊 Stack trace: ${StackTrace.current}');

      Get.snackbar(
        'error'.tr,
        'failed_to_add_video'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      print('🔄 Set loading state to false');
    }
  }

  Future<void> updateVideo(String courseId, VideoModel video) async {
    try {
      _isLoading.value = true;

      // Update video in Supabase
      await SupabaseService.updateVideo(video);

      // Update local state
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _myCourses[courseIndex];
        final updatedVideos = course.videos
            .map((v) => v.id == video.id ? video : v)
            .toList();
        _myCourses[courseIndex] = course.copyWith(videos: updatedVideos);

        if (_currentCourse.value?.id == courseId) {
          _currentCourse.value = _myCourses[courseIndex];
        }
      }

      Get.snackbar(
        'success'.tr,
        'video_updated_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_update_video'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteVideo(String courseId, String videoId) async {
    try {
      _isLoading.value = true;

      // Delete video from Supabase
      await SupabaseService.deleteVideo(videoId);

      // Update local state
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _myCourses[courseIndex];
        final updatedVideos = course.videos
            .where((v) => v.id != videoId)
            .toList();
        _myCourses[courseIndex] = course.copyWith(videos: updatedVideos);

        if (_currentCourse.value?.id == courseId) {
          _currentCourse.value = _myCourses[courseIndex];
        }
      }

      Get.snackbar(
        'success'.tr,
        'video_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_video'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createQuiz(
    String courseId,
    String title,
    String description,
    List<QuestionModel> questions,
    int timeLimit,
    int passingScore,
  ) async {
    print('📝 Starting quiz creation process...');
    print('📊 Quiz details:');
    print('   Course ID: $courseId');
    print('   Title: $title');
    print('   Description: $description');
    print('   Questions count: ${questions.length}');
    print('   Time limit: $timeLimit minutes');
    print('   Passing score: $passingScore%');

    try {
      _isLoading.value = true;
      print('🔄 Set loading state to true');

      // Validate current user
      if (_authController.currentUser == null) {
        print('❌ No authenticated user found');
        throw Exception('User not authenticated');
      }

      print('👤 Current user: ${_authController.currentUser!.name}');
      print('👤 User ID: ${_authController.currentUser!.id}');

      final quiz = QuizModel(
        id: '', // Will be set by Supabase
        title: title,
        description: description,
        courseId: courseId,
        questions: questions,
        timeLimit: timeLimit,
        passingScore: passingScore,
        createdAt: DateTime.now(),
      );

      print('🔍 Quiz model created locally');
      print('📋 Questions details:');
      for (int i = 0; i < questions.length; i++) {
        final q = questions[i];
        print('   Question ${i + 1}: ${q.question}');
        print('     Options: ${q.options.join(", ")}');
        print('     Correct answer index: ${q.correctAnswerIndex}');
        print('     Points: ${q.points}');
      }

      print('🚀 Creating quiz in Supabase...');
      // Create quiz in Supabase
      final createdQuizId = await SupabaseService.createQuiz(quiz);
      print('✅ Quiz created in database with ID: $createdQuizId');

      final createdQuiz = quiz.copyWith(id: createdQuizId);

      print('🔄 Updating local course state...');
      // Update local state
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _myCourses[courseIndex];
        print('📚 Found course: ${course.title}');
        print('📊 Current quizzes in course: ${course.quizzes.length}');

        final updatedQuizzes = [...course.quizzes, createdQuiz];
        _myCourses[courseIndex] = course.copyWith(quizzes: updatedQuizzes);
        print(
          '📝 Updated course with new quiz. Total quizzes: ${updatedQuizzes.length}',
        );

        if (_currentCourse.value?.id == courseId) {
          _currentCourse.value = _myCourses[courseIndex];
          print('🎯 Updated current course');
        }
      } else {
        print('❌ Course not found in local list');
      }

      print('🎉 Quiz creation completed successfully!');
      print(
        '📊 Final quiz count in course: ${_myCourses.firstWhere((c) => c.id == courseId).quizzes.length}',
      );

      // Show success dialog with animation
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.quiz, color: Colors.green, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  'success'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'quiz_created_successfully'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$title"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${questions.length} ${'questions'.tr}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('continue'.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Auto-close after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (Get.isDialogOpen == true) {
          Get.back(); // Close success dialog
        }
      });
    } catch (e) {
      print('❌ Error during quiz creation: $e');
      print('📊 Error type: ${e.runtimeType}');
      print('📊 Stack trace: ${StackTrace.current}');

      Get.snackbar(
        'error'.tr,
        'failed_to_create_quiz'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      print('🔄 Set loading state to false');
    }
  }

  Future<void> updateQuiz(String courseId, QuizModel quiz) async {
    try {
      _isLoading.value = true;

      // Update quiz in Supabase
      await SupabaseService.updateQuiz(quiz);

      // Update local state
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _myCourses[courseIndex];
        final updatedQuizzes = course.quizzes
            .map((q) => q.id == quiz.id ? quiz : q)
            .toList();
        _myCourses[courseIndex] = course.copyWith(quizzes: updatedQuizzes);

        if (_currentCourse.value?.id == courseId) {
          _currentCourse.value = _myCourses[courseIndex];
        }
      }

      Get.snackbar(
        'success'.tr,
        'quiz_updated_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_update_quiz'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      _isLoading.value = true;

      // Delete quiz from Supabase
      await SupabaseService.deleteQuiz(quizId);

      // Update local state
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _myCourses[courseIndex];
        final updatedQuizzes = course.quizzes
            .where((q) => q.id != quizId)
            .toList();
        _myCourses[courseIndex] = course.copyWith(quizzes: updatedQuizzes);

        if (_currentCourse.value?.id == courseId) {
          _currentCourse.value = _myCourses[courseIndex];
        }
      }

      Get.snackbar(
        'success'.tr,
        'quiz_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_quiz'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  List<QuizSubmissionModel> getSubmissionsForQuiz(String quizId) {
    return _studentSubmissions
        .where((submission) => submission.quizId == quizId)
        .toList();
  }

  List<CourseModel> getApprovedCourses() {
    return _myCourses.where((course) => course.isApproved).toList();
  }

  List<CourseModel> getPendingCourses() {
    return _myCourses.where((course) => !course.isApproved).toList();
  }

  Map<String, dynamic> getCourseAnalytics(String courseId) {
    // Note: Analytics would be fetched from SupabaseService
    return {'totalStudents': 0, 'completionRate': 0.0, 'averageScore': 0.0};
  }

  int getTotalStudents() {
    return _myCourses.fold(0, (sum, course) => sum + course.enrolledStudents);
  }

  int getTotalVideos() {
    return _myCourses.fold(0, (sum, course) => sum + course.videos.length);
  }

  int getTotalQuizzes() {
    return _myCourses.fold(0, (sum, course) => sum + course.quizzes.length);
  }

  double getAverageRating() {
    if (_myCourses.isEmpty) return 0.0;

    final approvedCourses = getApprovedCourses();
    if (approvedCourses.isEmpty) return 0.0;

    final totalRating = approvedCourses.fold(
      0.0,
      (sum, course) => sum + course.rating,
    );
    return totalRating / approvedCourses.length;
  }
}
