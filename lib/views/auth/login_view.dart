import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo and title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'BLApp',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'welcome_back'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Login form
              Card(
                elevation: 8,
                shadowColor: AppTheme.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'sign_in'.tr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Email field
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
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password field
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
                      )),
                      
                      const SizedBox(height: 30),
                      
                      // Login button
                      Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.login(
                                  emailController.text,
                                  passwordController.text,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                'sign_in'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )),
                      const SizedBox(height: 16),
                      
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed('/forgot-password'),
                          child: Text(
                            'forgot_password'.tr,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Demo accounts section
              Card(
                elevation: 4,
                shadowColor: AppTheme.accentColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'demo_accounts'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Student demo
                      _buildDemoAccountButton(
                        role: 'student'.tr,
                        email: 'student@blapp.com',
                        password: 'student123',
                        icon: Icons.school,
                        color: AppTheme.primaryColor,
                        onTap: () {
                          emailController.text = 'student@blapp.com';
                          passwordController.text = 'student123';
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Instructor demo
                      _buildDemoAccountButton(
                        role: 'instructor'.tr,
                        email: 'instructor@blapp.com',
                        password: 'instructor123',
                        icon: Icons.person_outline,
                        color: AppTheme.accentColor,
                        onTap: () {
                          emailController.text = 'instructor@blapp.com';
                          passwordController.text = 'instructor123';
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Admin demo
                      _buildDemoAccountButton(
                        role: 'admin'.tr,
                        email: 'admin@blapp.com',
                        password: 'admin123',
                        icon: Icons.admin_panel_settings,
                        color: AppTheme.secondaryColor,
                        onTap: () {
                          emailController.text = 'admin@blapp.com';
                          passwordController.text = 'admin123';
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Don't have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'dont_have_account'.tr,
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/signup'),
                    child: Text(
                      'create_account'.tr,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccountButton({
    required String role,
    required String email,
    required String password,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
