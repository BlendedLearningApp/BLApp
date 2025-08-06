import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

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
              
              const SizedBox(height: 40),
              
              // Header
              Text(
                'forgot_password'.tr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'forgot_password_desc'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Forgot Password Form
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
                      // Email Field
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'email'.tr,
                          hintText: 'enter_email_for_reset'.tr,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Send Reset Link Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (emailController.text.isEmpty || 
                                      !GetUtils.isEmail(emailController.text)) {
                                    Get.snackbar(
                                      'error'.tr,
                                      'please_enter_valid_email'.tr,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }
                                  
                                  final success = await controller.sendPasswordResetEmail(
                                    emailController.text,
                                  );
                                  
                                  if (success) {
                                    Get.snackbar(
                                      'success'.tr,
                                      'password_reset_sent'.tr,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    Get.back();
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
                                  'send_reset_link'.tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        )),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Info message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'reset_email_info'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textColor.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'remember_password'.tr,
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'back_to_login'.tr,
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
}
