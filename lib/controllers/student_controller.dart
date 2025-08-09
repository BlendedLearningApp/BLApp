import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/forum_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';

class StudentController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final RxList<CourseModel> _enrolledCourses = <CourseModel>[].obs;
  final RxList<CourseModel> _availableCourses = <CourseModel>[].obs;
  final RxList<QuizSubmissionModel> _quizSubmissions =
      <QuizSubmissionModel>[].obs;
  final RxList<ForumPostModel> _forumPosts = <ForumPostModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxMap<String, double> _courseProgress = <String, double>{}.obs;
  final RxMap<String, bool> _videoProgress = <String, bool>{}.obs;

  // Current course and video for detailed views
  final Rx<CourseModel?> _currentCourse = Rx<CourseModel?>(null);
  final Rx<VideoModel?> _currentVideo = Rx<VideoModel?>(null);
  final Rx<QuizModel?> _currentQuiz = Rx<QuizModel?>(null);

  List<CourseModel> get enrolledCourses => _enrolledCourses;
  List<CourseModel> get availableCourses => _availableCourses;
  List<QuizSubmissionModel> get quizSubmissions => _quizSubmissions;
  List<ForumPostModel> get forumPosts => _forumPosts;
  RxBool get isLoading => _isLoading; // Return RxBool for Obx compatibility
  Map<String, double> get courseProgress => _courseProgress;
  Map<String, bool> get videoProgress => _videoProgress;

  // Add loadDashboardData method for view compatibility
  Future<void> loadDashboardData() async {
    await loadStudentData();
  }

  /// Load available courses for discovery
  Future<void> loadAvailableCourses() async {
    try {
      _isLoading.value = true;
      final courses = await SupabaseService.getApprovedCourses();

      // Filter out already enrolled courses
      final enrolledCourseIds = _enrolledCourses.map((c) => c.id).toSet();
      final availableCourses = courses
          .where((course) => !enrolledCourseIds.contains(course.id))
          .toList();

      _availableCourses.assignAll(availableCourses);
    } catch (e) {
      print('Error loading available courses: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update course progress
  void updateCourseProgress(String courseId, double progress) {
    _courseProgress[courseId] = progress;
  }

  /// Get video watch status
  bool isVideoWatched(String videoId) {
    return _videoProgress[videoId] ?? false;
  }

  CourseModel? get currentCourse => _currentCourse.value;
  VideoModel? get currentVideo => _currentVideo.value;
  QuizModel? get currentQuiz => _currentQuiz.value;

  @override
  void onInit() {
    super.onInit();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    if (_authController.currentUser == null) return;

    try {
      _isLoading.value = true;

      // Load enrolled courses
      final courses = await SupabaseService.getEnrolledCourses(
        _authController.currentUser!.id,
      );
      _enrolledCourses.assignAll(courses);

      // Load quiz submissions
      final submissions = await SupabaseService.getQuizSubmissions(
        _authController.currentUser!.id,
      );
      _quizSubmissions.assignAll(submissions);
    } catch (e) {
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
    // Check if we're currently in a build phase
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // We're in a build phase, defer the state change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _currentCourse.value = course;
        loadForumPosts(course.id);
        _loadVideoProgress(course.id);
      });
    } else {
      // Safe to update immediately
      _currentCourse.value = course;
      loadForumPosts(course.id);
      _loadVideoProgress(course.id);
    }
  }

  Future<void> _loadVideoProgress(String courseId) async {
    if (_authController.currentUser == null) return;

    try {
      final progress = await SupabaseService.getVideoProgress(
        _authController.currentUser!.id,
        courseId,
      );

      // Update video progress in current course
      if (_currentCourse.value != null) {
        final updatedVideos = _currentCourse.value!.videos.map((video) {
          final isWatched = progress[video.id] ?? false;
          return video.copyWith(isWatched: isWatched);
        }).toList();

        _currentCourse.value = _currentCourse.value!.copyWith(
          videos: updatedVideos,
        );
      }
    } catch (e) {
      // Silently fail for video progress loading
    }
  }

  void selectVideo(VideoModel video) {
    _currentVideo.value = video;
  }

  void selectQuiz(QuizModel quiz) {
    _currentQuiz.value = quiz;
  }

  Future<void> markVideoAsWatched(String videoId) async {
    if (_currentCourse.value == null || _authController.currentUser == null)
      return;

    try {
      final video = _currentCourse.value!.videos.firstWhere(
        (v) => v.id == videoId,
      );

      // Mark video as watched in Supabase
      await SupabaseService.markVideoWatched(
        videoId,
        _authController.currentUser!.id,
        video.durationSeconds,
      );

      // Update local state
      final updatedVideo = video.copyWith(isWatched: true);
      final updatedVideos = _currentCourse.value!.videos
          .map((v) => v.id == videoId ? updatedVideo : v)
          .toList();

      _currentCourse.value = _currentCourse.value!.copyWith(
        videos: updatedVideos,
      );

      Get.snackbar(
        'success'.tr,
        'video_completed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_updating_progress'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> submitQuiz(String quizId, Map<String, int> answers) async {
    if (_authController.currentUser == null || _currentQuiz.value == null)
      return;

    try {
      _isLoading.value = true;

      // Submit quiz using Supabase
      final result = await SupabaseService.submitQuiz(
        quizId,
        _authController.currentUser!.id,
        answers,
        10, // Mock time spent
      );

      if (result['success'] == true) {
        // Create local submission model for UI
        final submission = QuizSubmissionModel(
          id: result['submission_id'],
          quizId: quizId,
          studentId: _authController.currentUser!.id,
          answers: answers,
          score: result['score'],
          totalQuestions: result['total_questions'],
          submittedAt: DateTime.now(),
          timeSpentMinutes: 10,
          passed: result['passed'],
        );

        _quizSubmissions.add(submission);

        Get.snackbar(
          result['passed'] ? 'quiz_passed'.tr : 'quiz_failed'.tr,
          '${'your_score'.tr}: ${result['percentage'].toStringAsFixed(1)}%',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'error'.tr,
          'quiz_submission_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'quiz_submission_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadForumPosts(String courseId) async {
    try {
      final posts = await SupabaseService.getForumPosts(courseId);
      _forumPosts.assignAll(posts);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_loading_forum'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> createForumPost(String title, String content) async {
    if (_authController.currentUser == null || _currentCourse.value == null) {
      return;
    }

    try {
      final post = ForumPostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        authorId: _authController.currentUser!.id,
        authorName: _authController.currentUser!.name,
        courseId: _currentCourse.value!.id,
        createdAt: DateTime.now(),
      );

      final postId = await SupabaseService.createForumPost(post);
      final updatedPost = post.copyWith(id: postId);
      _forumPosts.add(updatedPost);

      Get.snackbar(
        'success'.tr,
        'post_created'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> replyToPost(String postId, String content) async {
    if (_authController.currentUser == null) return;

    try {
      final reply = ForumReplyModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: postId,
        content: content,
        authorId: _authController.currentUser!.id,
        authorName: _authController.currentUser!.name,
        createdAt: DateTime.now(),
      );

      final replyId = await SupabaseService.createForumReply(reply);
      final updatedReply = reply.copyWith(id: replyId);

      // Update local state
      final postIndex = _forumPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _forumPosts[postIndex];
        final updatedReplies = List<ForumReplyModel>.from(post.replies)
          ..add(updatedReply);
        _forumPosts[postIndex] = post.copyWith(replies: updatedReplies);
      }

      Get.snackbar(
        'success'.tr,
        'reply_added'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> likePost(String postId) async {
    try {
      // Note: Supabase forum likes would be implemented here
      // For now, just update local state
      final postIndex = _forumPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _forumPosts[postIndex];
        _forumPosts[postIndex] = post.copyWith(
          likesCount: post.likesCount + 1,
          isLiked: true,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_liking_post'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  double getCourseProgress(String courseId) {
    final course = _enrolledCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => CourseModel(
        id: '',
        title: '',
        description: '',
        instructorId: '',
        instructorName: '',
        createdAt: DateTime.now(),
        category: '',
      ),
    );

    if (course.id.isEmpty || course.videos.isEmpty) return 0.0;

    final watchedVideos = course.videos.where((v) => v.isWatched).length;
    return (watchedVideos / course.videos.length) * 100;
  }

  int getCompletedQuizzes() {
    return _quizSubmissions.where((s) => s.passed).length;
  }

  double getAverageScore() {
    if (_quizSubmissions.isEmpty) return 0.0;

    final totalPercentage = _quizSubmissions
        .map((s) => s.percentage)
        .reduce((a, b) => a + b);

    return totalPercentage / _quizSubmissions.length;
  }

  List<CourseModel> getRecentCourses() {
    return _enrolledCourses.take(3).toList();
  }

  List<QuizSubmissionModel> getRecentQuizResults() {
    final sortedSubmissions = List<QuizSubmissionModel>.from(_quizSubmissions)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return sortedSubmissions.take(5).toList();
  }
}
