import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isPasswordHidden = true.obs;

  UserModel? get currentUser => _currentUser.value;
  RxBool get isLoading => _isLoading; // Return RxBool for Obx compatibility
  bool get isLoggedIn => _isLoggedIn.value;
  RxBool get isPasswordHidden => _isPasswordHidden;

  @override
  void onInit() {
    super.onInit();
    print('🔄 AuthController.onInit() called');

    // Don't force logout during navigation - only check auth state
    _checkAuthState();
    _listenToAuthChanges();
  }

  void togglePasswordVisibility() {
    _isPasswordHidden.value = !_isPasswordHidden.value;
  }

  void _checkAuthState() async {
    print('🔍 AuthController._checkAuthState() called');
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      print('✅ Supabase user found: ${user.id} (${user.email})');
      try {
        print('📥 Fetching user profile from database...');
        final profile = await SupabaseService.getCurrentUserProfile();
        if (profile != null) {
          print('✅ User profile loaded: ${profile.name} (${profile.role})');
          _currentUser.value = profile;
          _isLoggedIn.value = true;

          // DON'T auto-navigate - user should login manually each time
          print('✅ User session restored but not auto-navigating');
        } else {
          print('❌ User profile not found in database');
          // Sign out if profile not found
          await SupabaseService.signOut();
        }
      } catch (e) {
        print('❌ Error loading user profile: $e');
        // Sign out on error
        await SupabaseService.signOut();
      }
    } else {
      print('❌ No Supabase user found - user needs to login');
    }
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        try {
          final profile = await SupabaseService.getCurrentUserProfile();
          if (profile != null) {
            _currentUser.value = profile;
            _isLoggedIn.value = true;
          }
        } catch (e) {
          print('Error loading user profile after sign in: $e');
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser.value = null;
        _isLoggedIn.value = false;
      }
    });
  }

  // Enhanced login method with approval status checking
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;

      final result = await SupabaseService.checkLoginPermission(
        email,
        password,
      );

      if (result['allowed'] == true) {
        final profile = result['profile'] as UserModel;
        _currentUser.value = profile;
        _isLoggedIn.value = true;

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', profile.id);

        // Log detailed user information
        print('✅ Login successful! User details:');
        print('   👤 ID: ${profile.id}');
        print('   📧 Email: ${profile.email}');
        print('   🏷️ Name: ${profile.name}');
        print('   👔 Role: ${profile.role}');
        print('   ✅ Approval Status: ${profile.approvalStatus}');
        print('   📱 Phone: ${profile.phoneNumber ?? "Not provided"}');
        print('   🎂 Date of Birth: ${profile.dateOfBirth ?? "Not provided"}');
        print(
          '   🖼️ Profile Image: ${profile.profileImage ?? "Not provided"}',
        );

        Get.snackbar(
          'success'.tr,
          'login_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );

        _navigateToRoleDashboard(profile.role);
        return true;
      } else {
        // Handle different rejection reasons
        String errorMessage;
        switch (result['reason']) {
          case 'pending_approval':
            errorMessage = 'account_pending_approval'.tr;
            // Navigate to waiting screen
            Get.offAllNamed('/waiting-approval');
            return false;
          case 'account_rejected':
            errorMessage = 'account_rejected_login'.tr;
            break;
          case 'invalid_credentials':
            errorMessage = 'invalid_credentials'.tr;
            break;
          default:
            errorMessage = 'login_error'.tr;
        }

        Get.snackbar(
          'error'.tr,
          errorMessage,
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

  // Public method for external navigation
  void navigateToRoleDashboard(UserRole role) {
    _navigateToRoleDashboard(role);
  }

  // Refresh user profile to check for approval status changes
  Future<void> refreshUserProfile() async {
    try {
      final profile = await SupabaseService.refreshUserProfile();
      if (profile != null) {
        _currentUser.value = profile;
      }
    } catch (e) {
      // Handle error silently or show a message
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;

      await SupabaseService.signOut();

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
      Get.snackbar(
        'error'.tr,
        'logout_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      _isLoading.value = true;

      await SupabaseService.updateProfile(updatedUser);
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

  // Enhanced signup method with role-specific data
  Future<bool> enhancedSignup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String phoneNumber,
    required DateTime? dateOfBirth,
    required Map<String, dynamic> roleData,
  }) async {
    try {
      _isLoading.value = true;

      // Prepare user metadata
      final userMetadata = {
        'name': name,
        'role': role.toString().split('.').last,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth?.toIso8601String(),
      };

      final response = await SupabaseService.enhancedSignUp(
        email: email,
        password: password,
        userMetadata: userMetadata,
        roleData: roleData,
      );

      if (response['success'] == true) {
        // For pending approval accounts, we don't need to set login state
        // The user will be redirected to waiting approval screen
        Get.snackbar(
          'success'.tr,
          'account_created_pending_approval'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Log the successful creation for debugging
        print('✅ Account created successfully for: $email');
        print('📋 User ID: ${response['user_id']}');
        print('🔄 Status: Pending approval');

        return true;
      } else {
        // Log the error for debugging
        print('❌ Signup failed: ${response['error']}');

        Get.snackbar(
          'error'.tr,
          response['error'] ?? 'signup_error'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
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

  // Original signup method (kept for backward compatibility)
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return enhancedSignup(
      name: name,
      email: email,
      password: password,
      role: role,
      phoneNumber: '',
      dateOfBirth: null,
      roleData: {},
    );
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading.value = true;

      await Supabase.instance.client.auth.resetPasswordForEmail(email);

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
