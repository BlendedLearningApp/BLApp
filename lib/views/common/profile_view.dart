import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_button.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = authController.currentUser;

    // Debug: Log user data in profile view
    print('👤 Profile View - User Data Debug:');
    print('   User exists: ${user != null}');
    print('   Name: ${user?.name ?? "NULL"}');
    print('   Email: ${user?.email ?? "NULL"}');
    print('   Phone: ${user?.phoneNumber ?? "NULL"}');
    print('   Date of Birth: ${user?.dateOfBirth ?? "NULL"}');
    print('   Profile Image: ${user?.profileImage ?? "NULL"}');
    print('   Role: ${user?.role ?? "NULL"}');
    print('   Approval Status: ${user?.approvalStatus ?? "NULL"}');

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _bioController = TextEditingController(
      text: '',
    ); // Bio not in UserModel yet
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _initializeControllers(); // Reset changes
                }
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser;

        // Debug: Log current user state in profile view
        print('👤 Profile View Build - Current User State:');
        print('   User exists: ${user != null}');
        print('   User name: ${user?.name ?? "NULL"}');
        print('   User email: ${user?.email ?? "NULL"}');
        print('   User phone: ${user?.phoneNumber ?? "NULL"}');
        print('   Is logged in: ${authController.isLoggedIn}');

        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'user_not_found'.tr,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'please_login_again'.tr,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),

                const SizedBox(height: 24),

                // Profile Information
                _buildProfileInformation(user),

                const SizedBox(height: 24),

                // Role-specific Information
                _buildRoleSpecificInfo(user),

                const SizedBox(height: 24),

                // Account Actions
                _buildAccountActions(),

                if (_isEditing) ...[
                  const SizedBox(height: 24),
                  _buildEditActions(),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return CustomCard(
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _changeProfilePicture,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),

          const SizedBox(height: 4),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getRoleColor(user.role).withOpacity(0.3),
              ),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(user.role),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Join Date
          Text(
            'member_since'.tr + ' ${_formatDate(user.createdAt)}',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInformation(UserModel user) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'personal_information'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),

          const SizedBox(height: 16),

          // Name Field
          _buildFormField(
            label: 'full_name'.tr,
            controller: _nameController,
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'name_required'.tr;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email Field
          _buildFormField(
            label: 'email'.tr,
            controller: _emailController,
            icon: Icons.email,
            enabled: false, // Email should not be editable
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'email_required'.tr;
              }
              if (!GetUtils.isEmail(value)) {
                return 'invalid_email'.tr;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Phone Field
          _buildFormField(
            label: 'phone_number'.tr,
            controller: _phoneController,
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 16),

          // Bio Field
          _buildFormField(
            label: 'bio'.tr,
            controller: _bioController,
            icon: Icons.info,
            maxLines: 3,
            hintText: 'tell_us_about_yourself'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificInfo(UserModel user) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getRoleSpecificTitle(user.role),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),

          const SizedBox(height: 16),

          ..._buildRoleSpecificContent(user),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing && enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.textColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.textColor.withOpacity(0.1)),
        ),
        filled: !(_isEditing && enabled),
        fillColor: (_isEditing && enabled)
            ? null
            : AppTheme.textColor.withOpacity(0.05),
      ),
    );
  }

  Widget _buildAccountActions() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'account_actions'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),

          const SizedBox(height: 16),

          // Change Password
          ListTile(
            leading: const Icon(Icons.lock, color: AppTheme.primaryColor),
            title: Text('change_password'.tr),
            subtitle: Text('update_account_password'.tr),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _changePassword,
          ),

          const Divider(),

          // Notification Settings
          ListTile(
            leading: const Icon(
              Icons.notifications,
              color: AppTheme.primaryColor,
            ),
            title: Text('notification_settings'.tr),
            subtitle: Text('manage_notifications'.tr),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _notificationSettings,
          ),

          const Divider(),

          // Privacy Settings
          ListTile(
            leading: const Icon(
              Icons.privacy_tip,
              color: AppTheme.primaryColor,
            ),
            title: Text('privacy_settings'.tr),
            subtitle: Text('manage_privacy'.tr),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _privacySettings,
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
            subtitle: Text('sign_out_account'.tr),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'cancel'.tr,
            type: ButtonType.outline,
            onPressed: () {
              setState(() {
                _isEditing = false;
                _initializeControllers();
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'save_changes'.tr,
            type: ButtonType.primary,
            isLoading: _isLoading,
            onPressed: _saveProfile,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRoleSpecificContent(UserModel user) {
    switch (user.role) {
      case UserRole.student:
        return [
          _buildInfoRow('enrolled_courses'.tr, '3 courses'),
          _buildInfoRow('completed_quizzes'.tr, '12 quizzes'),
          _buildInfoRow('total_study_time'.tr, '45 hours'),
          _buildInfoRow('certificates_earned'.tr, '2 certificates'),
        ];
      case UserRole.instructor:
        return [
          _buildInfoRow('courses_created'.tr, '5 courses'),
          _buildInfoRow('total_students'.tr, '127 students'),
          _buildInfoRow('average_rating'.tr, '4.8/5.0'),
          _buildInfoRow('teaching_since'.tr, _formatDate(user.createdAt)),
        ];
      case UserRole.admin:
        return [
          _buildInfoRow('total_users'.tr, '1,234 users'),
          _buildInfoRow('active_courses'.tr, '45 courses'),
          _buildInfoRow('pending_approvals'.tr, '8 items'),
          _buildInfoRow('system_uptime'.tr, '99.9%'),
        ];
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppTheme.primaryColor;
      case UserRole.instructor:
        return AppTheme.accentColor;
      case UserRole.admin:
        return AppTheme.secondaryColor;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'student'.tr;
      case UserRole.instructor:
        return 'instructor'.tr;
      case UserRole.admin:
        return 'admin'.tr;
    }
  }

  String _getRoleSpecificTitle(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'learning_progress'.tr;
      case UserRole.instructor:
        return 'teaching_statistics'.tr;
      case UserRole.admin:
        return 'system_overview'.tr;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _changeProfilePicture() {
    Get.snackbar(
      'profile_picture'.tr,
      'feature_coming_soon'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _changePassword() {
    Get.snackbar(
      'change_password'.tr,
      'feature_coming_soon'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _notificationSettings() {
    Get.snackbar(
      'notifications'.tr,
      'feature_coming_soon'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _privacySettings() {
    Get.snackbar(
      'privacy'.tr,
      'feature_coming_soon'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Update user profile (mocked)
    Get.snackbar(
      'profile_updated'.tr,
      'changes_saved_successfully'.tr,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_logout'.tr),
        content: Text('are_you_sure_logout'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          CustomButton(
            text: 'logout'.tr,
            type: ButtonType.primary,
            onPressed: () {
              Get.back();
              authController.logout();
            },
          ),
        ],
      ),
    );
  }
}
