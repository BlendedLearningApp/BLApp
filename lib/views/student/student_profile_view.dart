import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/student_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isEditing = false;
  bool _showPasswordSection = false;
  String _selectedLanguage = 'en';
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    // Mock user data - in real app, this would come from controller
    _fullNameController.text = 'Ahmed Mohammed';
    _emailController.text = 'student@example.com';
    _phoneController.text = '+966 50 123 4567';
    _bioController.text = 'Computer Science student passionate about mobile app development.';
    _selectedLanguage = Get.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final studentController = Get.find<StudentController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'save'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),
              const SizedBox(height: 24),
              
              // Personal Information
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              
              // Account Settings
              _buildAccountSettingsSection(),
              const SizedBox(height: 24),
              
              // Password Section
              _buildPasswordSection(),
              const SizedBox(height: 24),
              
              // Statistics Section
              _buildStatisticsSection(),
              const SizedBox(height: 24),
              
              // Action Buttons
              if (_isEditing) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfilePictureSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppTheme.primaryColor,
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
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: _changeProfilePicture,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalInfoSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            
            // Full Name
            TextFormField(
              controller: _fullNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'full_name'.tr,
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please_enter_full_name'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              enabled: false, // Email usually not editable
              decoration: InputDecoration(
                labelText: 'email'.tr,
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'phone_number'.tr,
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bio
            TextFormField(
              controller: _bioController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'bio'.tr,
                prefixIcon: const Icon(Icons.info),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccountSettingsSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'account_settings'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Language Preference
            Row(
              children: [
                Expanded(
                  child: Text(
                    'preferred_language'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇺🇸'),
                          const SizedBox(width: 8),
                          Text('english'.tr),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇸🇦'),
                          const SizedBox(width: 8),
                          Text('arabic'.tr),
                        ],
                      ),
                    ),
                  ],
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  } : null,
                ),
              ],
            ),
            const Divider(),
            
            // Email Notifications
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'email_notifications'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'receive_course_updates'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _emailNotifications,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  } : null,
                  activeColor: AppTheme.accentColor,
                ),
              ],
            ),
            const Divider(),
            
            // Push Notifications
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'push_notifications'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'receive_assignment_reminders'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _pushNotifications,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  } : null,
                  activeColor: AppTheme.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPasswordSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'password_security'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showPasswordSection = !_showPasswordSection;
                    });
                  },
                  child: Text(
                    _showPasswordSection ? 'hide'.tr : 'change_password'.tr,
                  ),
                ),
              ],
            ),
            
            if (_showPasswordSection) ...[
              const SizedBox(height: 16),
              
              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'current_password'.tr,
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (_showPasswordSection && (value == null || value.isEmpty)) {
                    return 'please_enter_current_password'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'new_password'.tr,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (_showPasswordSection && (value == null || value.length < 6)) {
                    return 'password_min_length'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'confirm_password'.tr,
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (_showPasswordSection && value != _newPasswordController.text) {
                    return 'passwords_do_not_match'.tr;
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticsSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'learning_statistics'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'courses_enrolled'.tr,
                    '5',
                    Icons.school,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'completed_courses'.tr,
                    '2',
                    Icons.check_circle,
                    AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'quiz_average'.tr,
                    '85%',
                    Icons.quiz,
                    AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'study_hours'.tr,
                    '42h',
                    Icons.schedule,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.primaryColor),
            ),
            child: Text('cancel'.tr),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('save_changes'.tr),
          ),
        ),
      ],
    );
  }
  
  void _changeProfilePicture() {
    Get.snackbar(
      'profile_picture'.tr,
      'profile_picture_update_coming_soon'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }
  
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Save profile data
      setState(() {
        _isEditing = false;
        _showPasswordSection = false;
      });
      
      // Clear password fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      Get.snackbar(
        'profile_updated'.tr,
        'profile_updated_successfully'.tr,
        backgroundColor: AppTheme.accentColor,
        colorText: Colors.white,
      );
    }
  }
  
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _showPasswordSection = false;
    });
    
    // Reset form data
    _loadUserData();
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }
}
