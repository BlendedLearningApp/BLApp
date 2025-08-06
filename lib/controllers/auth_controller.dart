import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/dummy_data_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final DummyDataService _dataService = Get.find<DummyDataService>();

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isPasswordHidden = true.obs;

  UserModel? get currentUser => _currentUser.value;
  RxBool get isLoading => _isLoading; // Return RxBool for Obx compatibility
  bool get isLoggedIn => _isLoggedIn.value;
  RxBool get isPasswordHidden => _isPasswordHidden;

  void togglePasswordVisibility() {
    _isPasswordHidden.value = !_isPasswordHidden.value;
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final user = _dataService.authenticateUser(email, password);

      if (user != null) {
        _currentUser.value = user;
        _isLoggedIn.value = true;

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);

        Get.snackbar(
          'success'.tr,
          'login_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );

        _navigateToRoleDashboard(user.role);
        return true;
      } else {
        Get.snackbar(
          'error'.tr,
          'login_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'login_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void _navigateToRoleDashboard(UserRole role) {
    switch (role) {
      case UserRole.student:
        Get.offAllNamed(AppRoutes.studentDashboard);
        break;
      case UserRole.instructor:
        Get.offAllNamed(AppRoutes.instructorDashboard);
        break;
      case UserRole.admin:
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Clear saved login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');

      _currentUser.value = null;
      _isLoggedIn.value = false;

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'success'.tr,
        'logout'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      _isLoading.value = true;

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _dataService.updateUser(updatedUser);
      _currentUser.value = updatedUser;

      // Update saved user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', updatedUser.id);

      Get.snackbar(
        'success'.tr,
        'profile_updated'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('error'.tr, 'error'.tr, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  bool hasRole(UserRole role) {
    return currentUser?.role == role;
  }

  bool isStudent() => hasRole(UserRole.student);
  bool isInstructor() => hasRole(UserRole.instructor);
  bool isAdmin() => hasRole(UserRole.admin);

  String get userRoleString {
    switch (currentUser?.role) {
      case UserRole.student:
        return 'Student';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.admin:
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  // Signup method
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      _isLoading.value = true;

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already exists
      if (_dataService.getUserByEmail(email) != null) {
        Get.snackbar(
          'error'.tr,
          'email_already_exists'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Add user to data service
      _dataService.createUser(newUser);

      // Auto-login the new user
      _currentUser.value = newUser;
      _isLoggedIn.value = true;

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', newUser.id);

      Get.snackbar(
        'success'.tr,
        'account_created_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      _navigateToRoleDashboard(role);
      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'signup_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Send password reset email (mocked)
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading.value = true;

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user exists
      final user = _dataService.getUserByEmail(email);
      if (user == null) {
        Get.snackbar(
          'error'.tr,
          'email_not_found'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // In a real app, this would send an actual email
      // For demo purposes, we'll just show a success message
      Get.snackbar(
        'success'.tr,
        'password_reset_sent'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'reset_email_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
