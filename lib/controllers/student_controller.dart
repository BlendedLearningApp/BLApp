import 'package:get/get.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../models/forum_model.dart';
import '../services/dummy_data_service.dart';
import '../controllers/auth_controller.dart';

class StudentController extends GetxController {
  final DummyDataService _dataService = Get.find<DummyDataService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<CourseModel> _enrolledCourses = <CourseModel>[].obs;
  final RxList<QuizSubmissionModel> _quizSubmissions = <QuizSubmissionModel>[].obs;
  final RxList<ForumPostModel> _forumPosts = <ForumPostModel>[].obs;
  final RxBool _isLoading = false.obs;

  // Current course and video for detailed views
  final Rx<CourseModel?> _currentCourse = Rx<CourseModel?>(null);
  final Rx<VideoModel?> _currentVideo = Rx<VideoModel?>(null);
  final Rx<QuizModel?> _currentQuiz = Rx<QuizModel?>(null);

  List<CourseModel> get enrolledCourses => _enrolledCourses;
  List<QuizSubmissionModel> get quizSubmissions => _quizSubmissions;
  List<ForumPostModel> get forumPosts => _forumPosts;
  RxBool get isLoading => _isLoading; // Return RxBool for Obx compatibility

  // Add loadDashboardData method for view compatibility
  Future<void> loadDashboardData() async {
    await loadStudentData();
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
      final courses = _dataService.getEnrolledCourses(_authController.currentUser!.id);
      _enrolledCourses.assignAll(courses);
      
      // Load quiz submissions
      final submissions = _dataService.getStudentSubmissions(_authController.currentUser!.id);
      _quizSubmissions.assignAll(submissions);
      
    } catch (e) {
      print('Error loading student data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void selectCourse(CourseModel course) {
    _currentCourse.value = course;
    loadForumPosts(course.id);
  }

  void selectVideo(VideoModel video) {
    _currentVideo.value = video;
  }

  void selectQuiz(QuizModel quiz) {
    _currentQuiz.value = quiz;
  }

  Future<void> markVideoAsWatched(String videoId) async {
    if (_currentCourse.value == null) return;

    try {
      final video = _currentCourse.value!.videos.firstWhere((v) => v.id == videoId);
      final updatedVideo = video.copyWith(isWatched: true);
      
      _dataService.updateVideo(_currentCourse.value!.id, updatedVideo);
      
      // Update local state
      final updatedVideos = _currentCourse.value!.videos
          .map((v) => v.id == videoId ? updatedVideo : v)
          .toList();
      
      _currentCourse.value = _currentCourse.value!.copyWith(videos: updatedVideos);
      
      Get.snackbar(
        'success'.tr,
        'video_completed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error marking video as watched: $e');
    }
  }

  Future<void> submitQuiz(String quizId, Map<String, int> answers) async {
    if (_authController.currentUser == null || _currentQuiz.value == null) return;

    try {
      _isLoading.value = true;
      
      // Calculate score
      int correctAnswers = 0;
      final quiz = _currentQuiz.value!;
      
      for (final question in quiz.questions) {
        final selectedAnswer = answers[question.id];
        if (selectedAnswer == question.correctAnswerIndex) {
          correctAnswers++;
        }
      }
      
      final percentage = (correctAnswers / quiz.questions.length) * 100;
      final passed = percentage >= quiz.passingScore;
      
      final submission = QuizSubmissionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        quizId: quizId,
        studentId: _authController.currentUser!.id,
        answers: answers,
        score: correctAnswers,
        totalQuestions: quiz.questions.length,
        submittedAt: DateTime.now(),
        timeSpentMinutes: 10, // Mock time spent
        passed: passed,
      );
      
      _dataService.submitQuiz(submission);
      _quizSubmissions.add(submission);
      
      Get.snackbar(
        passed ? 'quiz_passed'.tr : 'quiz_failed'.tr,
        '${'your_score'.tr}: ${percentage.toStringAsFixed(1)}%',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadForumPosts(String courseId) async {
    try {
      final posts = _dataService.getForumPosts(courseId);
      _forumPosts.assignAll(posts);
    } catch (e) {
      print('Error loading forum posts: $e');
    }
  }

  Future<void> createForumPost(String title, String content) async {
    if (_authController.currentUser == null || _currentCourse.value == null) return;

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
      
      _dataService.createForumPost(post);
      _forumPosts.add(post);
      
      Get.snackbar(
        'success'.tr,
        'post_created'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
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
      
      _dataService.addReplyToPost(postId, reply);
      
      // Update local state
      final postIndex = _forumPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _forumPosts[postIndex];
        final updatedReplies = List<ForumReplyModel>.from(post.replies)..add(reply);
        _forumPosts[postIndex] = post.copyWith(replies: updatedReplies);
      }
      
      Get.snackbar(
        'success'.tr,
        'reply_added'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> likePost(String postId) async {
    try {
      _dataService.likePost(postId);
      
      // Update local state
      final postIndex = _forumPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _forumPosts[postIndex];
        _forumPosts[postIndex] = post.copyWith(
          likesCount: post.likesCount + 1,
          isLiked: true,
        );
      }
    } catch (e) {
      print('Error liking post: $e');
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
