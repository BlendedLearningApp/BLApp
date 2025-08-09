import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

class EnhancedSignupView extends GetView<AuthController> {
  const EnhancedSignupView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the selected role from arguments
    final UserRole selectedRole =
        Get.arguments?['selectedRole'] ?? UserRole.student;

    return SignupFormView(selectedRole: selectedRole);
  }
}

class SignupFormView extends StatefulWidget {
  final UserRole selectedRole;

  const SignupFormView({super.key, required this.selectedRole});

  @override
  State<SignupFormView> createState() => _SignupFormViewState();
}

class _SignupFormViewState extends State<SignupFormView> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Common fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  // Student-specific fields
  final _studentIdController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _majorController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  // Instructor-specific fields
  final _instructorIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _specializationController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _researchInterestsController = TextEditingController();
  final _officeLocationController = TextEditingController();
  final _officeHoursController = TextEditingController();

  String _selectedEducationLevel = 'bachelor';
  String _selectedCountry = 'Saudi Arabia';
  DateTime? _selectedDateOfBirth;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _studentIdController.dispose();
    _academicYearController.dispose();
    _majorController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _instructorIdController.dispose();
    _departmentController.dispose();
    _qualificationsController.dispose();
    _yearsExperienceController.dispose();
    _specializationController.dispose();
    _linkedinController.dispose();
    _researchInterestsController.dispose();
    _officeLocationController.dispose();
    _officeHoursController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('create_account'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildBasicInfoStep(),
            _buildRoleSpecificStep(),
            _buildReviewStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color: index <= step
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(0),
          const SizedBox(height: 32),

          // Header
          Text(
            'basic_information'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'enter_basic_details'.tr,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Role indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  widget.selectedRole == UserRole.student
                      ? Icons.school
                      : Icons.person_outline,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  '${'registering_as'.tr}: ${widget.selectedRole == UserRole.student ? 'student'.tr : 'instructor'.tr}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Form fields
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'full_name'.tr,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_name'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'email'.tr,
              hintText: 'example: user@gmail.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_email'.tr;
              }

              // Enhanced email validation
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );

              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email address (e.g., user@example.com)';
              }

              // Check for minimum length requirements
              final parts = value.split('@');
              if (parts.length != 2 ||
                  parts[0].length < 2 ||
                  parts[1].length < 4) {
                return 'Email format is too short. Please use a complete email address.';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'phone_number'.tr,
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_phone'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'date_of_birth'.tr,
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onTap: _selectDateOfBirth,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_select_date_of_birth'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'password'.tr,
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_password'.tr;
              }
              if (value.length < 6) {
                return 'password_min_length'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

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
              if (value == null || value.isEmpty) {
                return 'please_confirm_password'.tr;
              }
              if (value != _passwordController.text) {
                return 'passwords_do_not_match'.tr;
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Next button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'next'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSpecificStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(1),
          const SizedBox(height: 32),

          // Header
          Text(
            widget.selectedRole == UserRole.student
                ? 'student_information'.tr
                : 'instructor_information'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.selectedRole == UserRole.student
                ? 'enter_student_details'.tr
                : 'enter_instructor_details'.tr,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Role-specific fields
          if (widget.selectedRole == UserRole.student)
            ..._buildStudentFields()
          else
            ..._buildInstructorFields(),

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'previous'.tr,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'next'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStudentFields() {
    return [
      TextFormField(
        controller: _studentIdController,
        decoration: InputDecoration(
          labelText: 'student_id'.tr,
          prefixIcon: const Icon(Icons.badge_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_student_id'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _academicYearController,
        decoration: InputDecoration(
          labelText: 'academic_year'.tr,
          prefixIcon: const Icon(Icons.school_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: 'e.g., 2023-2024',
        ),
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _majorController,
        decoration: InputDecoration(
          labelText: 'major'.tr,
          prefixIcon: const Icon(Icons.book_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _emergencyContactNameController,
        decoration: InputDecoration(
          labelText: 'emergency_contact_name'.tr,
          prefixIcon: const Icon(Icons.contact_emergency_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_emergency_contact'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _emergencyContactPhoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'emergency_contact_phone'.tr,
          prefixIcon: const Icon(Icons.phone_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_emergency_phone'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _addressController,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: 'address'.tr,
          prefixIcon: const Icon(Icons.location_on_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _cityController,
        decoration: InputDecoration(
          labelText: 'city'.tr,
          prefixIcon: const Icon(Icons.location_city_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ];
  }

  List<Widget> _buildInstructorFields() {
    return [
      TextFormField(
        controller: _instructorIdController,
        decoration: InputDecoration(
          labelText: 'instructor_id'.tr,
          prefixIcon: const Icon(Icons.badge_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_instructor_id'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _departmentController,
        decoration: InputDecoration(
          labelText: 'department'.tr,
          prefixIcon: const Icon(Icons.business_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_department'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _qualificationsController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'qualifications'.tr,
          prefixIcon: const Icon(Icons.school_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: 'list_your_qualifications'.tr,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_qualifications'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      DropdownButtonFormField<String>(
        value: _selectedEducationLevel,
        decoration: InputDecoration(
          labelText: 'education_level'.tr,
          prefixIcon: const Icon(Icons.school_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: [
          DropdownMenuItem(
            value: 'bachelor',
            child: Text('bachelor_degree'.tr),
          ),
          DropdownMenuItem(value: 'master', child: Text('master_degree'.tr)),
          DropdownMenuItem(value: 'phd', child: Text('phd_degree'.tr)),
          DropdownMenuItem(value: 'other', child: Text('other'.tr)),
        ],
        onChanged: (value) {
          setState(() {
            _selectedEducationLevel = value!;
          });
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _yearsExperienceController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'years_of_experience'.tr,
          prefixIcon: const Icon(Icons.work_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_enter_experience'.tr;
          }
          return null;
        },
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _specializationController,
        decoration: InputDecoration(
          labelText: 'specialization'.tr,
          prefixIcon: const Icon(Icons.star_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _linkedinController,
        decoration: InputDecoration(
          labelText: 'linkedin_profile'.tr,
          prefixIcon: const Icon(Icons.link_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: 'https://linkedin.com/in/yourprofile',
        ),
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _researchInterestsController,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: 'research_interests'.tr,
          prefixIcon: const Icon(Icons.science_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _officeLocationController,
        decoration: InputDecoration(
          labelText: 'office_location'.tr,
          prefixIcon: const Icon(Icons.location_on_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 16),

      TextFormField(
        controller: _officeHoursController,
        decoration: InputDecoration(
          labelText: 'office_hours'.tr,
          prefixIcon: const Icon(Icons.access_time_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintText: 'e.g., Mon-Wed 10:00-12:00',
        ),
      ),
    ];
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(2),
          const SizedBox(height: 32),

          // Header
          Text(
            'review_information'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'review_before_submit'.tr,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Review information
          _buildReviewSection(),

          const SizedBox(height: 32),

          // Terms and conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
                  child: Text(
                    'agree_to_terms'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'previous'.tr,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GetX<AuthController>(
                  builder: (controller) => ElevatedButton(
                    onPressed: _agreeToTerms && !controller.isLoading.value
                        ? _submitForm
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'create_account'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewItem('full_name'.tr, _nameController.text),
            _buildReviewItem('email'.tr, _emailController.text),
            _buildReviewItem('phone_number'.tr, _phoneController.text),
            _buildReviewItem('date_of_birth'.tr, _dobController.text),
            _buildReviewItem(
              'role'.tr,
              widget.selectedRole == UserRole.student
                  ? 'student'.tr
                  : 'instructor'.tr,
            ),

            if (widget.selectedRole == UserRole.student) ...[
              _buildReviewItem('student_id'.tr, _studentIdController.text),
              _buildReviewItem(
                'academic_year'.tr,
                _academicYearController.text,
              ),
              _buildReviewItem('major'.tr, _majorController.text),
              _buildReviewItem(
                'emergency_contact_name'.tr,
                _emergencyContactNameController.text,
              ),
            ] else ...[
              _buildReviewItem(
                'instructor_id'.tr,
                _instructorIdController.text,
              ),
              _buildReviewItem('department'.tr, _departmentController.text),
              _buildReviewItem('education_level'.tr, _selectedEducationLevel),
              _buildReviewItem(
                'years_of_experience'.tr,
                _yearsExperienceController.text,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textColor),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 1) {
      if (_validateRoleSpecificFields()) {
        setState(() {
          _currentStep = 2;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateRoleSpecificFields() {
    if (widget.selectedRole == UserRole.student) {
      if (_studentIdController.text.isEmpty) {
        Get.snackbar('error'.tr, 'please_enter_student_id'.tr);
        return false;
      }
      if (_emergencyContactNameController.text.isEmpty) {
        Get.snackbar('error'.tr, 'please_enter_emergency_contact'.tr);
        return false;
      }
      if (_emergencyContactPhoneController.text.isEmpty) {
        Get.snackbar('error'.tr, 'please_enter_emergency_phone'.tr);
        return false;
      }
    } else {
      if (_instructorIdController.text.isEmpty) {
        Get.snackbar('error'.tr, 'please_enter_instructor_id'.tr);
        return false;
      }
      if (_departmentController.text.isEmpty) {
        Get.snackbar('error'.tr, 'please_enter_department'.tr);
        return false;
      }
      if (_qualificationsController.text.isEmpty) {
        Get.snackbar('error'.tr, 'please_enter_qualifications'.tr);
        return false;
      }
      if (_yearsExperienceController.text.isEmpty) {
        Get.snackbar('error'.tr, 'please_enter_experience'.tr);
        return false;
      }
    }
    return true;
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 4380),
      ), // 12 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitForm() async {
    final authController = Get.find<AuthController>();

    // Prepare role-specific data
    Map<String, dynamic> roleData = {};

    if (widget.selectedRole == UserRole.student) {
      roleData = {
        'student_id': _studentIdController.text,
        'academic_year': _academicYearController.text,
        'major': _majorController.text,
        'emergency_contact_name': _emergencyContactNameController.text,
        'emergency_contact_phone': _emergencyContactPhoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'country': _selectedCountry,
      };
    } else {
      roleData = {
        'instructor_id': _instructorIdController.text,
        'department': _departmentController.text,
        'qualifications': _qualificationsController.text,
        'years_of_experience': _yearsExperienceController.text,
        'specialization': _specializationController.text,
        'education_level': _selectedEducationLevel,
        'linkedin_profile': _linkedinController.text,
        'research_interests': _researchInterestsController.text,
        'office_location': _officeLocationController.text,
        'office_hours': _officeHoursController.text,
      };
    }

    final success = await authController.enhancedSignup(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: widget.selectedRole,
      phoneNumber: _phoneController.text,
      dateOfBirth: _selectedDateOfBirth,
      roleData: roleData,
    );

    if (success) {
      // Navigate to waiting for approval screen
      Get.offAllNamed(AppRoutes.waitingApproval);
    }
  }
}
