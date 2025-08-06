import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../widgets/bottom_navigation/admin_bottom_nav.dart';
import 'user_management_view.dart';
import 'content_management_view.dart';
import 'analytics_view.dart';
import 'system_settings_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final AdminController controller = Get.find<AdminController>();
  final NavigationController navController = Get.find<NavigationController>();

  @override
  void initState() {
    super.initState();
    // Set dashboard as active tab when entering
    navController.setAdminIndex(0);
  }

  void _onNavTap(int index) {
    navController.navigateAdmin(index);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Obx(() {
          switch (navController.adminCurrentIndex) {
            case 0:
              return Text('dashboard'.tr);
            case 1:
              return Text('users'.tr);
            case 2:
              return Text('approvals'.tr);
            case 3:
              return Text('analytics'.tr);
            case 4:
              return Text('settings'.tr);
            default:
              return Text('dashboard'.tr);
          }
        }),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,

        actions: [
          // Language Swap Button
          PopupMenuButton<String>(
            onSelected: (String languageCode) {
              final locale = Locale(languageCode);
              Get.updateLocale(locale);
              Get.snackbar(
                'language_changed'.tr,
                'language_changed_message'.tr,
                backgroundColor: AppTheme.accentColor,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'en',
                child: Row(
                  children: [
                    const Text('🇺🇸'),
                    const SizedBox(width: 8),
                    Text('english'.tr),
                    if (Get.locale?.languageCode == 'en')
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'ar',
                child: Row(
                  children: [
                    const Text('🇸🇦'),
                    const SizedBox(width: 8),
                    Text('arabic'.tr),
                    if (Get.locale?.languageCode == 'ar')
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.language),
            tooltip: 'change_language'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                // TODO: Navigate to admin profile or show profile dialog
                Get.snackbar(
                  'info'.tr,
                  'admin_profile_coming_soon'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else if (value == 'logout') {
                authController.logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Text('profile'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text('logout'.tr),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Obx(
          () => IndexedStack(
            index: navController.adminCurrentIndex,
            children: [
              // Dashboard
              RefreshIndicator(
                onRefresh: controller.loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome section
                      _buildWelcomeSection(authController),

                      const SizedBox(height: 24),

                      // System overview stats
                      _buildSystemOverview(),

                      const SizedBox(height: 24),

                      // Quick actions
                      _buildQuickActions(),

                      const SizedBox(height: 24),

                      // Pending approvals
                      _buildPendingApprovalsSection(),

                      const SizedBox(height: 24),

                      // Recent activities
                      _buildRecentActivitiesSection(),
                    ],
                  ),
                ),
              ),
              // User Management
              const UserManagementView(),
              // Content Management
              const ContentManagementView(),
              // Analytics
              const AnalyticsView(),
              // System Settings
              const SystemSettingsView(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => AdminBottomNavigation(
          currentIndex: navController.adminCurrentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AuthController authController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'welcome'.tr}, ${authController.currentUser?.name ?? 'Admin'}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'admin_control_panel'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'system_overview'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'total_users'.tr,
                value: controller.allUsers.length.toString(),
                icon: Icons.people,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'total_courses'.tr,
                value: controller.allCourses.length.toString(),
                icon: Icons.book,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'pending_approvals'.tr,
                value: controller.pendingCourses.length.toString(),
                icon: Icons.pending_actions,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'active_sessions'.tr,
                value: _getActiveSessions().toString(),
                icon: Icons.online_prediction,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _getActiveSessions() {
    // Mock active sessions calculation
    return controller.allUsers.where((user) => user.isActive).length;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
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
              color: AppTheme.textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'user_management'.tr,
                icon: Icons.manage_accounts,
                color: AppTheme.primaryColor,
                onTap: () => navController.navigateAdmin(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'content_management'.tr,
                icon: Icons.library_books,
                color: AppTheme.accentColor,
                onTap: () => navController.navigateAdmin(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'analytics'.tr,
                icon: Icons.analytics,
                color: AppTheme.secondaryColor,
                onTap: () => navController.navigateAdmin(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'system_settings'.tr,
                icon: Icons.settings,
                color: AppTheme.primaryColor,
                onTap: () => navController.navigateAdmin(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'pending_approvals'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            TextButton(
              onPressed: () => navController.navigateAdmin(2),
              child: Text('view_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: controller.pendingCourses.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: AppTheme.accentColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'no_pending_approvals'.tr,
                          style: TextStyle(
                            color: AppTheme.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: controller.pendingCourses.take(3).map((course) {
                      return Column(
                        children: [
                          _buildPendingApprovalItem(course),
                          if (course != controller.pendingCourses.take(3).last)
                            const Divider(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingApprovalItem(course) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.pending_actions,
            color: AppTheme.secondaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              Text(
                '${'by'.tr} ${course.instructorName}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: AppTheme.accentColor),
              onPressed: () => controller.approveCourse(course.id),
              tooltip: 'approve'.tr,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => controller.rejectCourse(course.id),
              tooltip: 'reject'.tr,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_activities'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _getRecentActivities().map((activity) {
                return Column(
                  children: [
                    _buildActivityItem(activity),
                    if (activity != _getRecentActivities().last)
                      const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    // Mock recent activities
    return [
      {
        'type': 'user_registered',
        'message': '${'new_user_registered'.tr}: John Doe',
        'time': '2_hours_ago'.tr,
        'icon': Icons.person_add,
        'color': AppTheme.accentColor,
      },
      {
        'type': 'course_submitted',
        'message': '${'course_submitted_for_approval'.tr}: Flutter Basics',
        'time': '4_hours_ago'.tr,
        'icon': Icons.book,
        'color': AppTheme.secondaryColor,
      },
      {
        'type': 'user_login',
        'message': '${'admin_login'.tr}: System Administrator',
        'time': '6_hours_ago'.tr,
        'icon': Icons.login,
        'color': AppTheme.primaryColor,
      },
    ];
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activity['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(activity['icon'], color: activity['color'], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['message'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textColor,
                ),
              ),
              Text(
                activity['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
