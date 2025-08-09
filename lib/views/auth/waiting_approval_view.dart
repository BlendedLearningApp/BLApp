import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class WaitingApprovalView extends GetView<AuthController> {
  const WaitingApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32, // Account for padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.05),

                      // Illustration
                      Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.width * 0.35,
                        constraints: const BoxConstraints(
                          minWidth: 100,
                          maxWidth: 180,
                          minHeight: 100,
                          maxHeight: 180,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.hourglass_empty,
                          size: MediaQuery.of(context).size.width * 0.12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.04),

                      // Title
                      Text(
                        'account_under_review'.tr,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'approval_pending_message'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textColor.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.04),

                      // Information Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildInfoItem(
                                Icons.access_time,
                                'expected_approval_time'.tr,
                                'approval_timeframe'.tr,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                Icons.email_outlined,
                                'notification_method'.tr,
                                'email_notification_info'.tr,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                Icons.support_agent,
                                'need_help'.tr,
                                'support_contact_info'.tr,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Action Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _checkApprovalStatus(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'check_status'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => _contactSupport(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'contact_support'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () => _logout(),
                            child: Text(
                              'logout'.tr,
                              style: TextStyle(
                                color: AppTheme.textColor.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 16,
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
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _checkApprovalStatus() async {
    // Refresh user profile to check approval status
    await controller.refreshUserProfile();

    if (controller.currentUser?.approvalStatus == 'approved') {
      Get.snackbar(
        'success'.tr,
        'account_approved'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Navigate to appropriate dashboard
      controller.navigateToRoleDashboard(controller.currentUser!.role);
    } else if (controller.currentUser?.approvalStatus == 'rejected') {
      Get.snackbar(
        'error'.tr,
        'account_rejected'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'info'.tr,
        'still_pending_approval'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _contactSupport() {
    // Open email client or show contact information
    Get.dialog(
      AlertDialog(
        title: Text('contact_support'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('support_email'.tr + ': support@blapp.com'),
            const SizedBox(height: 8),
            Text('support_phone'.tr + ': +966 11 123 4567'),
            const SizedBox(height: 8),
            Text('support_hours'.tr + ': 9:00 AM - 5:00 PM'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('close'.tr)),
        ],
      ),
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_logout'.tr),
        content: Text('logout_confirmation_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }
}
