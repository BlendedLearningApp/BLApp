import 'package:get/get.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/quiz_model.dart';
import '../services/dummy_data_service.dart';
import '../controllers/auth_controller.dart';

class InstructorController extends GetxController {
  final DummyDataService _dataService = Get.find<DummyDataService>();
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

  // Add loadDashboardData method for view compatibility
  Future<void> loadDashboardData() async {
    await loadInstructorData();
  }

  @override
  void onInit() {
    super.onInit();
    loadInstructorData();
  }

  Future<void> loadInstructorData() async {
    if (_authController.currentUser == null) return;

    try {
      _isLoading.value = true;

      // Load instructor's courses
      final courses = _dataService.getCoursesByInstructor(
        _authController.currentUser!.id,
      );
      _myCourses.assignAll(courses);

      // Load student submissions for instructor's courses
      final allSubmissions = <QuizSubmissionModel>[];
      for (final course in courses) {
        for (final quiz in course.quizzes) {
          final submissions = _dataService.getQuizSubmissions(quiz.id);
          allSubmissions.addAll(submissions);
        }
      }
      _studentSubmissions.assignAll(allSubmissions);
    } catch (e) {
      print('Error loading instructor data: $e');
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
    if (_authController.currentUser == null) return;

    try {
      _isLoading.value = true;

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

      _dataService.createCourse(course);
      _myCourses.add(course);

      // Automatically select the newly created course for content management
      _currentCourse.value = course;

      Get.snackbar(
        'success'.tr,
        isPublished
            ? 'course_created_and_submitted_for_approval'.tr
            : 'course_created_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_create_course'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateCourse(CourseModel course) async {
    try {
      _isLoading.value = true;

      _dataService.updateCourse(course);

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

      _dataService.deleteCourse(courseId);
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
    try {
      _isLoading.value = true;

      final videoId = VideoModel.extractVideoId(youtubeUrl);
      if (videoId.isEmpty) {
        Get.snackbar(
          'error'.tr,
          'invalid_url'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final course = _myCourses.firstWhere((c) => c.id == courseId);
      final orderIndex = course.videos.length + 1;

      final video = VideoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        youtubeUrl: youtubeUrl,
        youtubeVideoId: videoId,
        courseId: courseId,
        orderIndex: orderIndex,
        createdAt: DateTime.now(),
      );

      _dataService.addVideoToCourse(courseId, video);

      // Update local state
      final updatedCourse = course.copyWith(videos: [...course.videos, video]);

      final index = _myCourses.indexWhere((c) => c.id == courseId);
      if (index != -1) {
        _myCourses[index] = updatedCourse;
      }

      if (_currentCourse.value?.id == courseId) {
        _currentCourse.value = updatedCourse;
      }

      Get.snackbar(
        'success'.tr,
        'Video added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateVideo(String courseId, VideoModel video) async {
    try {
      _dataService.updateVideo(courseId, video);

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
        'Video updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteVideo(String courseId, String videoId) async {
    try {
      _dataService.deleteVideo(courseId, videoId);

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
        'Video deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
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
    try {
      _isLoading.value = true;

      final quiz = QuizModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        courseId: courseId,
        questions: questions,
        timeLimit: timeLimit,
        passingScore: passingScore,
        createdAt: DateTime.now(),
      );

      _dataService.addQuizToCourse(courseId, quiz);

      // Update local state
      final courseIndex = _myCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _myCourses[courseIndex];
        final updatedQuizzes = [...course.quizzes, quiz];
        _myCourses[courseIndex] = course.copyWith(quizzes: updatedQuizzes);

        if (_currentCourse.value?.id == courseId) {
          _currentCourse.value = _myCourses[courseIndex];
        }
      }

      Get.snackbar(
        'success'.tr,
        'Quiz created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateQuiz(String courseId, QuizModel quiz) async {
    try {
      _dataService.updateQuiz(courseId, quiz);

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
        'Quiz updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      _dataService.deleteQuiz(courseId, quizId);

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

      // Remove related submissions
      _studentSubmissions.removeWhere(
        (submission) => submission.quizId == quizId,
      );

      Get.snackbar(
        'success'.tr,
        'Quiz deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
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
    return _dataService.getCourseAnalytics(courseId);
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
