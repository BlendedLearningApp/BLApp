import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final RxString selectedRole = 'student'.obs;
    final RxBool agreeToTerms = false.obs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Back button
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              
              const SizedBox(height: 20),
              
              // Header
              Text(
                'create_account'.tr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'join_blapp_community'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Signup Form
              Card(
                elevation: 8,
                shadowColor: AppTheme.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Full Name Field
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'full_name'.tr,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Email Field
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'email'.tr,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Role Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_role'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Obx(() => Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text('student'.tr),
                                  subtitle: Text('learn_courses'.tr),
                                  value: 'student',
                                  groupValue: selectedRole.value,
                                  onChanged: (value) => selectedRole.value = value!,
                                  activeColor: AppTheme.primaryColor,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text('instructor'.tr),
                                  subtitle: Text('teach_courses'.tr),
                                  value: 'instructor',
                                  groupValue: selectedRole.value,
                                  onChanged: (value) => selectedRole.value = value!,
                                  activeColor: AppTheme.accentColor,
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password Field
                      Obx(() => TextFormField(
                        controller: passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'password'.tr,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                      )),
                      
                      const SizedBox(height: 20),
                      
                      // Confirm Password Field
                      Obx(() => TextFormField(
                        controller: confirmPasswordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'confirm_password'.tr,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      )),
                      
                      const SizedBox(height: 20),
                      
                      // Terms and Conditions
                      Obx(() => CheckboxListTile(
                        title: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppTheme.textColor),
                            children: [
                              TextSpan(text: 'i_agree_to'.tr),
                              TextSpan(
                                text: ' ${'terms_conditions'.tr}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        value: agreeToTerms.value,
                        onChanged: (value) => agreeToTerms.value = value ?? false,
                        activeColor: AppTheme.primaryColor,
                        controlAffinity: ListTileControlAffinity.leading,
                      )),
                      
                      const SizedBox(height: 30),
                      
                      // Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value || !agreeToTerms.value
                              ? null
                              : () async {
                                  if (_validateForm(
                                    nameController.text,
                                    emailController.text,
                                    passwordController.text,
                                    confirmPasswordController.text,
                                  )) {
                                    final success = await controller.signup(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      role: _getUserRole(selectedRole.value),
                                    );
                                    
                                    if (success) {
                                      Get.snackbar(
                                        'success'.tr,
                                        'account_created_successfully'.tr,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                  ),
                                ),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'already_have_account'.tr,
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.offNamed('/login'),
                    child: Text(
                      'sign_in'.tr,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateForm(String name, String email, String password, String confirmPassword) {
    if (name.isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_name'.tr, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('error'.tr, 'please_enter_valid_email'.tr, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    if (password.isEmpty || password.length < 6) {
      Get.snackbar('error'.tr, 'password_min_length'.tr, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    if (password != confirmPassword) {
      Get.snackbar('error'.tr, 'passwords_dont_match'.tr, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    return true;
  }

  UserRole _getUserRole(String role) {
    switch (role) {
      case 'student':
        return UserRole.student;
      case 'instructor':
        return UserRole.instructor;
      default:
        return UserRole.student;
    }
  }
}
