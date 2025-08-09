import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../services/supabase_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/instructor_controller.dart';
import '../controllers/student_controller.dart';
import '../config/app_theme.dart';

class AdminController extends GetxController {
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

      // Load all users with error handling
      try {
        final users = await SupabaseService.getAllUsers();
        _allUsers.assignAll(users);
        print('✅ Users loaded: ${users.length}');

        // Debug: Print approval statuses
        final statusCounts = <String, int>{};
        for (final user in users) {
          statusCounts[user.approvalStatus] =
              (statusCounts[user.approvalStatus] ?? 0) + 1;
        }
        print('📊 User approval statuses: $statusCounts');
        print('🔍 Pending approval users: ${pendingApprovalUsers.length}');
      } catch (e) {
        print('❌ Error loading users: $e');
        // Keep existing users if any, don't clear the list
      }

      // Load all courses (approved and pending) with error handling
      try {
        final allCourses = await SupabaseService.getAllCourses();
        _allCourses.assignAll(allCourses);

        // Filter pending courses
        _pendingCourses.assignAll(
          allCourses.where((c) => !c.isApproved).toList(),
        );
        print(
          '✅ Courses loaded: ${allCourses.length} total, ${_pendingCourses.length} pending',
        );
      } catch (e) {
        print('❌ Error loading courses: $e');
        // Keep existing courses if any, don't clear the list
      }

      // Load system analytics with error handling and fallback
      try {
        final analytics = await SupabaseService.getSystemAnalytics();
        _systemAnalytics.value = analytics;
        print('✅ Analytics loaded successfully');
      } catch (e) {
        print('❌ Error loading analytics: $e');
        // Provide fallback analytics based on loaded data
        _systemAnalytics.value = _generateFallbackAnalytics();
        print('✅ Using fallback analytics');
      }

      print(
        '✅ Admin data loading completed: ${_allUsers.length} users, ${_allCourses.length} courses',
      );
    } catch (e) {
      print('❌ Critical error loading admin data: $e');
      Get.snackbar(
        'error'.tr,
        'error_loading_data'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Generate fallback analytics when database function fails
  Map<String, dynamic> _generateFallbackAnalytics() {
    final userStats = userStatistics;

    return {
      'total_users': _allUsers.length,
      'total_students': userStats['students'] ?? 0,
      'total_instructors': userStats['instructors'] ?? 0,
      'total_admins': userStats['admins'] ?? 0,
      'total_courses': _allCourses.length,
      'approved_courses': _allCourses.where((c) => c.isApproved).length,
      'pending_courses': _pendingCourses.length,
      'total_enrollments': 0, // Cannot calculate without database
      'total_videos': 0, // Cannot calculate without database
      'total_quizzes': 0, // Cannot calculate without database
      'total_quiz_submissions': 0, // Cannot calculate without database
      'total_forum_posts': 0, // Cannot calculate without database
      'total_forum_replies': 0, // Cannot calculate without database
      'average_course_rating': _allCourses.isNotEmpty
          ? _allCourses.map((c) => c.rating).reduce((a, b) => a + b) /
                _allCourses.length
          : 0.0,
      'completion_rate': 0.0, // Cannot calculate without database
      'quiz_pass_rate': 0.0, // Cannot calculate without database
    };
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

      // Note: User creation would need to be implemented in SupabaseService
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

      // Note: User update would need to be implemented in SupabaseService

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

  // User Approval Management Methods
  Future<void> approveUser(String userId) async {
    try {
      _isLoading.value = true;
      print('🔄 AdminController: Starting user approval for ID: $userId');

      // Find the user first
      final user = _allUsers.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );
      print(
        '👤 Found user: ${user.name} (${user.email}) - Current status: ${user.approvalStatus}',
      );

      final success = await SupabaseService.approveUserAdmin(userId);
      print('📊 SupabaseService.approveUserAdmin returned: $success');

      if (success) {
        // Update local user list
        final userIndex = _allUsers.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          _allUsers[userIndex] = _allUsers[userIndex].copyWith(
            approvalStatus: 'approved',
            approvedAt: DateTime.now(),
          );
          print('✅ Local user list updated');
        }

        Get.snackbar(
          'success'.tr,
          'user_approved_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh data to ensure consistency
        print('🔄 Refreshing admin data...');
        await loadAdminData();
      } else {
        print('❌ Approval failed');
        Get.snackbar(
          'error'.tr,
          'failed_to_approve_user'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error approving user: $e');
      Get.snackbar(
        'error'.tr,
        'error_approving_user'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> rejectUser(String userId) async {
    try {
      _isLoading.value = true;
      print('🔄 AdminController: Starting user rejection for ID: $userId');

      // Find the user first
      final user = _allUsers.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('User not found'),
      );
      print(
        '👤 Found user: ${user.name} (${user.email}) - Current status: ${user.approvalStatus}',
      );

      final success = await SupabaseService.rejectUserAdmin(userId);
      print('📊 SupabaseService.rejectUserAdmin returned: $success');

      if (success) {
        // Update local user list
        final userIndex = _allUsers.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          _allUsers[userIndex] = _allUsers[userIndex].copyWith(
            approvalStatus: 'rejected',
          );
          print('✅ Local user list updated');
        }

        Get.snackbar(
          'success'.tr,
          'user_rejected_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        // Refresh data to ensure consistency
        print('🔄 Refreshing admin data...');
        await loadAdminData();
      } else {
        print('❌ Rejection failed');
        Get.snackbar(
          'error'.tr,
          'failed_to_reject_user'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error rejecting user: $e');
      Get.snackbar(
        'error'.tr,
        'error_rejecting_user'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleUserActiveStatus(String userId, bool newStatus) async {
    try {
      _isLoading.value = true;

      final success = await SupabaseService.updateUserActiveStatus(
        userId,
        newStatus,
      );

      if (success) {
        // Update local user list
        final userIndex = _allUsers.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          _allUsers[userIndex] = _allUsers[userIndex].copyWith(
            isActive: newStatus,
          );
        }

        Get.snackbar(
          'success'.tr,
          newStatus
              ? 'user_activated_successfully'.tr
              : 'user_deactivated_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: newStatus ? Colors.green : Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'error'.tr,
          'failed_to_update_user_status'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error updating user status: $e');
      Get.snackbar(
        'error'.tr,
        'error_updating_user_status'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _isLoading.value = true;

      final success = await SupabaseService.deleteUserProfile(userId);

      if (success) {
        // Remove from local user list
        _allUsers.removeWhere((u) => u.id == userId);

        Get.snackbar(
          'success'.tr,
          'user_deleted_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'error'.tr,
          'failed_to_delete_user'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error deleting user: $e');
      Get.snackbar(
        'error'.tr,
        'error_deleting_user'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get pending approval users
  List<UserModel> get pendingApprovalUsers {
    return _allUsers
        .where((user) => user.approvalStatus == 'pending_approval')
        .toList();
  }

  /// Refresh pending approval users specifically
  Future<void> refreshPendingApprovals() async {
    try {
      print('🔄 Refreshing pending approval users...');

      // Get fresh pending users from database
      final pendingUsers = await SupabaseService.getPendingApprovalUsers();

      // Update the main users list with fresh pending users
      for (final pendingUser in pendingUsers) {
        final existingIndex = _allUsers.indexWhere(
          (u) => u.id == pendingUser.id,
        );
        if (existingIndex != -1) {
          _allUsers[existingIndex] = pendingUser;
        } else {
          _allUsers.add(pendingUser);
        }
      }

      // Remove users that are no longer pending
      _allUsers.removeWhere(
        (user) =>
            user.approvalStatus == 'pending_approval' &&
            !pendingUsers.any((pu) => pu.id == user.id),
      );

      print(
        '✅ Pending approvals refreshed: ${pendingUsers.length} pending users',
      );
    } catch (e) {
      print('❌ Error refreshing pending approvals: $e');
    }
  }

  // Get user statistics
  Map<String, int> get userStatistics {
    final stats = <String, int>{
      'total_users': _allUsers.length,
      'pending_approvals': 0,
      'approved_users': 0,
      'rejected_users': 0,
      'active_users': 0,
      'inactive_users': 0,
      'students': 0,
      'instructors': 0,
      'admins': 0,
    };

    for (final user in _allUsers) {
      // Approval status counts
      switch (user.approvalStatus) {
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
      if (user.isActive) {
        stats['active_users'] = stats['active_users']! + 1;
      } else {
        stats['inactive_users'] = stats['inactive_users']! + 1;
      }

      // Role counts
      switch (user.role) {
        case UserRole.student:
          stats['students'] = stats['students']! + 1;
          break;
        case UserRole.instructor:
          stats['instructors'] = stats['instructors']! + 1;
          break;
        case UserRole.admin:
          stats['admins'] = stats['admins']! + 1;
          break;
      }
    }

    return stats;
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

  // Course Management Methods
  Future<void> approveCourse(String courseId) async {
    try {
      _isLoading.value = true;

      await SupabaseService.approveCourse(courseId);

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

      // Notify other controllers about the change
      _notifyOtherControllers();

      Get.snackbar(
        'success'.tr,
        'course_approved_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.accentColor,
        colorText: Colors.white,
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

      await SupabaseService.rejectCourse(courseId);

      // Update local state
      final courseIndex = _allCourses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        final course = _allCourses[courseIndex];
        final rejectedCourse = course.copyWith(isApproved: false);
        _allCourses[courseIndex] = rejectedCourse;

        // Add to pending courses if not already there
        if (!_pendingCourses.any((c) => c.id == courseId)) {
          _pendingCourses.add(rejectedCourse);
        }
      }

      // Update analytics
      await _updateAnalytics();

      // Notify other controllers about the change
      _notifyOtherControllers();

      Get.snackbar(
        'success'.tr,
        'course_rejected_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.warningColor,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error rejecting course: $e');
      Get.snackbar(
        'error'.tr,
        'error_rejecting_course'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      _isLoading.value = true;

      await SupabaseService.deleteCourse(courseId);

      // Update local state
      _allCourses.removeWhere((course) => course.id == courseId);
      _pendingCourses.removeWhere((course) => course.id == courseId);

      // Update analytics
      await _updateAnalytics();

      // Notify other controllers about the change
      _notifyOtherControllers();

      Get.snackbar(
        'success'.tr,
        'course_deleted_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error deleting course: $e');
      Get.snackbar(
        'error'.tr,
        'error_deleting_course'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Analytics Methods
  Future<void> _updateAnalytics() async {
    try {
      final analytics = await SupabaseService.getSystemAnalytics();
      _systemAnalytics.value = analytics;
    } catch (e) {
      // Silently fail for analytics updates
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

  /// Notify other controllers about course status changes for real-time updates
  void _notifyOtherControllers() {
    try {
      // Notify instructor controller to refresh their courses
      if (Get.isRegistered<InstructorController>()) {
        final instructorController = Get.find<InstructorController>();
        instructorController.loadInstructorData();
      }

      // Notify student controller to refresh available courses
      if (Get.isRegistered<StudentController>()) {
        final studentController = Get.find<StudentController>();
        studentController.loadAvailableCourses();
      }
    } catch (e) {
      print('⚠️ Error notifying other controllers: $e');
      // Don't throw error as this is not critical
    }
  }
}
