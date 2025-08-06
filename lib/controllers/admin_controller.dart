import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../services/dummy_data_service.dart';
import '../controllers/auth_controller.dart';

class AdminController extends GetxController {
  final DummyDataService _dataService = Get.find<DummyDataService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserModel> _allUsers = <UserModel>[].obs;
  final RxList<CourseModel> _allCourses = <CourseModel>[].obs;
  final RxList<CourseModel> _pendingCourses = <CourseModel>[].obs;
  final RxBool _isLoading = false.obs;
  final Rx<Map<String, dynamic>> _systemAnalytics = Rx<Map<String, dynamic>>(
    {},
  );

  List<UserModel> get allUsers => _allUsers;
  List<CourseModel> get allCourses => _allCourses;
  List<CourseModel> get pendingCourses => _pendingCourses;
  RxBool get isLoading => _isLoading; // Return RxBool for Obx compatibility
  Map<String, dynamic> get systemAnalytics => _systemAnalytics.value;

  // Add loadDashboardData method for view compatibility
  Future<void> loadDashboardData() async {
    await loadAdminData();
  }

  @override
  void onInit() {
    super.onInit();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    try {
      _isLoading.value = true;

      // Load all users
      final users = _dataService.getAllUsers();
      _allUsers.assignAll(users);

      // Load all courses
      final courses = _dataService.getAllCourses();
      _allCourses.assignAll(courses);

      // Load pending courses
      final pending = _dataService.getPendingCourses();
      _pendingCourses.assignAll(pending);

      // Load system analytics
      final analytics = _dataService.getSystemAnalytics();
      _systemAnalytics.value = analytics;
    } catch (e) {
      print('Error loading admin data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // User Management Methods
  Future<void> createUser(String email, String name, UserRole role) async {
    try {
      _isLoading.value = true;

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
      );

      _dataService.createUser(user);
      _allUsers.add(user);

      // Update analytics
      await _updateAnalytics();

      Get.snackbar(
        'success'.tr,
        'user_created_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      _isLoading.value = true;

      _dataService.updateUser(user);

      // Update local state
      final index = _allUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _allUsers[index] = user;
      }

      Get.snackbar(
        'success'.tr,
        'user_updated_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleUserStatus(String userId) async {
    try {
      final user = _allUsers.firstWhere((u) => u.id == userId);
      final updatedUser = user.copyWith(isActive: !user.isActive);

      await updateUser(updatedUser);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'user_not_found'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _isLoading.value = true;

      _dataService.deleteUser(userId);
      _allUsers.removeWhere((user) => user.id == userId);

      // Update analytics
      await _updateAnalytics();

      Get.snackbar(
        'success'.tr,
        'user_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  // Course Management Methods
  Future<void> approveCourse(String courseId) async {
    try {
      _isLoading.value = true;

      _dataService.approveCourse(courseId);

      // Update local state
      final courseIndex = _allCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _allCourses[courseIndex];
        final approvedCourse = course.copyWith(isApproved: true);
        _allCourses[courseIndex] = approvedCourse;
      }

      // Remove from pending courses
      _pendingCourses.removeWhere((course) => course.id == courseId);

      // Update analytics
      await _updateAnalytics();

      Get.snackbar(
        'success'.tr,
        'course_approved_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> rejectCourse(String courseId) async {
    try {
      _isLoading.value = true;

      _dataService.deleteCourse(courseId);

      // Update local state
      _allCourses.removeWhere((course) => course.id == courseId);
      _pendingCourses.removeWhere((course) => course.id == courseId);

      // Update analytics
      await _updateAnalytics();

      Get.snackbar(
        'success'.tr,
        'course_rejected_and_deleted'.tr,
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

      // Update local state
      _allCourses.removeWhere((course) => course.id == courseId);
      _pendingCourses.removeWhere((course) => course.id == courseId);

      // Update analytics
      await _updateAnalytics();

      Get.snackbar(
        'success'.tr,
        'course_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  // Analytics Methods
  Future<void> _updateAnalytics() async {
    try {
      final analytics = _dataService.getSystemAnalytics();
      _systemAnalytics.value = analytics;
    } catch (e) {
      print('Error updating analytics: $e');
    }
  }

  Future<void> refreshAnalytics() async {
    await _updateAnalytics();
  }

  // Video Management Methods
  Future<void> approveVideo(String videoId) async {
    try {
      _isLoading.value = true;

      // TODO: Implement video approval logic
      // For now, just show success message
      Get.snackbar(
        'success'.tr,
        'video_approved_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> rejectVideo(String videoId) async {
    try {
      _isLoading.value = true;

      // TODO: Implement video rejection logic
      // For now, just show success message
      Get.snackbar(
        'success'.tr,
        'video_rejected_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteVideo(String videoId) async {
    try {
      _isLoading.value = true;

      // TODO: Implement video deletion logic
      // For now, just show success message
      Get.snackbar(
        'success'.tr,
        'video_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  // Quiz Management Methods
  Future<void> approveQuiz(String quizId) async {
    try {
      _isLoading.value = true;

      // TODO: Implement quiz approval logic
      // For now, just show success message
      Get.snackbar(
        'success'.tr,
        'quiz_approved_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> rejectQuiz(String quizId) async {
    try {
      _isLoading.value = true;

      // TODO: Implement quiz rejection logic
      // For now, just show success message
      Get.snackbar(
        'success'.tr,
        'quiz_rejected_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      _isLoading.value = true;

      // TODO: Implement quiz deletion logic
      // For now, just show success message
      Get.snackbar(
        'success'.tr,
        'quiz_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  // Filter Methods
  List<UserModel> getUsersByRole(UserRole role) {
    return _allUsers.where((user) => user.role == role).toList();
  }

  List<UserModel> getActiveUsers() {
    return _allUsers.where((user) => user.isActive).toList();
  }

  List<UserModel> getInactiveUsers() {
    return _allUsers.where((user) => !user.isActive).toList();
  }

  List<CourseModel> getApprovedCourses() {
    return _allCourses.where((course) => course.isApproved).toList();
  }

  List<CourseModel> getCoursesByCategory(String category) {
    return _allCourses.where((course) => course.category == category).toList();
  }

  // Search Methods
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _allUsers;

    final lowercaseQuery = query.toLowerCase();
    return _allUsers
        .where(
          (user) =>
              user.name.toLowerCase().contains(lowercaseQuery) ||
              user.email.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  List<CourseModel> searchCourses(String query) {
    if (query.isEmpty) return _allCourses;

    final lowercaseQuery = query.toLowerCase();
    return _allCourses
        .where(
          (course) =>
              course.title.toLowerCase().contains(lowercaseQuery) ||
              course.description.toLowerCase().contains(lowercaseQuery) ||
              course.instructorName.toLowerCase().contains(lowercaseQuery) ||
              course.category.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Statistics Getters
  int get totalUsers => _systemAnalytics.value['total_users'] ?? 0;
  int get totalStudents => _systemAnalytics.value['total_students'] ?? 0;
  int get totalInstructors => _systemAnalytics.value['total_instructors'] ?? 0;
  int get totalAdmins => _systemAnalytics.value['total_admins'] ?? 0;
  int get totalCourses => _systemAnalytics.value['total_courses'] ?? 0;
  int get approvedCoursesCount =>
      _systemAnalytics.value['approved_courses'] ?? 0;
  int get pendingCoursesCount => _systemAnalytics.value['pending_courses'] ?? 0;
  int get totalQuizSubmissions =>
      _systemAnalytics.value['total_quiz_submissions'] ?? 0;
  int get totalForumPosts => _systemAnalytics.value['total_forum_posts'] ?? 0;

  // Growth calculations (mock data for demonstration)
  double get userGrowthRate => 12.5; // Mock 12.5% growth
  double get courseGrowthRate => 8.3; // Mock 8.3% growth
  double get engagementRate => 67.2; // Mock 67.2% engagement

  List<Map<String, dynamic>> getRecentActivity() {
    // Mock recent activity data
    return [
      {
        'type': 'user_registered',
        'message': '${'new_student_registered'.tr}: Ahmed Al-Rashid',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'icon': 'person_add',
      },
      {
        'type': 'course_submitted',
        'message':
            '${'course_submitted_for_approval'.tr}: Data Science with Python',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': 'school',
      },
      {
        'type': 'quiz_completed',
        'message': 'new_quiz_submissions_received'.tr,
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'icon': 'quiz',
      },
      {
        'type': 'course_approved',
        'message': '${'course_approved'.tr}: Flutter Development Fundamentals',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'icon': 'check_circle',
      },
    ];
  }

  List<Map<String, dynamic>> getPopularCourses() {
    final approvedCourses = getApprovedCourses();
    approvedCourses.sort(
      (a, b) => b.enrolledStudents.compareTo(a.enrolledStudents),
    );

    return approvedCourses
        .take(5)
        .map(
          (course) => {
            'title': course.title,
            'instructor': course.instructorName,
            'students': course.enrolledStudents,
            'rating': course.rating,
          },
        )
        .toList();
  }
}
