import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/user_model.dart';
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

                      // User approval stats
                      _buildUserApprovalStats(controller),

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
    // Calculate active sessions based on real user data
    // Users who have logged in within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    return controller.allUsers.where((user) {
      // Check if user has recent activity (you can enhance this based on your user model)
      return user.isActive && user.createdAt.isAfter(yesterday);
    }).length;
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
    final pendingUsers = controller.pendingApprovalUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'pending_user_approvals'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                final navController = Get.find<NavigationController>();
                navController.setAdminIndex(1); // User management tab
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text('view_all'.tr),
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
            child: pendingUsers.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: AppTheme.accentColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'no_pending_user_approvals'.tr,
                          style: TextStyle(
                            color: AppTheme.textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: pendingUsers.take(3).map((user) {
                      return Column(
                        children: [
                          _buildPendingUserApprovalItem(user),
                          if (user != pendingUsers.take(3).last)
                            const Divider(height: 24),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingUserApprovalItem(user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.2),
            child: user.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      user.profileImage!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        _getRoleIcon(user.role),
                        color: _getRoleColor(user.role),
                        size: 20,
                      ),
                    ),
                  )
                : Icon(
                    _getRoleIcon(user.role),
                    color: _getRoleColor(user.role),
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _getRoleColor(user.role),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(user.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: 70,
                height: 28,
                child: ElevatedButton(
                  onPressed: () => _approveUserFromDashboard(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'approve'.tr,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                height: 28,
                child: ElevatedButton(
                  onPressed: () => _rejectUserFromDashboard(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'reject'.tr,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
    List<Map<String, dynamic>> activities = [];
    final now = DateTime.now();

    // Add recent user registrations
    final recentUsers = controller.allUsers
        .where((user) => now.difference(user.createdAt).inDays <= 7)
        .take(3)
        .toList();

    for (final user in recentUsers) {
      activities.add({
        'type': 'user_registered',
        'message': '${'new_user_registered'.tr}: ${user.name}',
        'time': _formatTimeAgo(user.createdAt),
        'icon': Icons.person_add,
        'color': AppTheme.accentColor,
      });
    }

    // Add recent course submissions (pending courses)
    final recentCourses = controller.pendingCourses
        .where((course) => now.difference(course.createdAt).inDays <= 7)
        .take(3)
        .toList();

    for (final course in recentCourses) {
      activities.add({
        'type': 'course_submitted',
        'message': '${'course_submitted_for_approval'.tr}: ${course.title}',
        'time': _formatTimeAgo(course.createdAt),
        'icon': Icons.book,
        'color': AppTheme.secondaryColor,
      });
    }

    // Add approved courses
    final recentApprovedCourses = controller.allCourses
        .where(
          (course) =>
              course.isApproved && now.difference(course.createdAt).inDays <= 7,
        )
        .take(2)
        .toList();

    for (final course in recentApprovedCourses) {
      activities.add({
        'type': 'course_approved',
        'message': '${'course_approved'.tr}: ${course.title}',
        'time': _formatTimeAgo(course.createdAt),
        'icon': Icons.check_circle,
        'color': Colors.green,
      });
    }

    // Sort by most recent first and limit to 5 activities
    activities.sort((a, b) => b['time'].compareTo(a['time']));

    // If no recent activities, show a default message
    if (activities.isEmpty) {
      activities.add({
        'type': 'system',
        'message': 'no_recent_activities'.tr,
        'time': 'now'.tr,
        'icon': Icons.info_outline,
        'color': AppTheme.textColor.withValues(alpha: 0.6),
      });
    }

    return activities.take(5).toList();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${'days_ago'.tr}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${'hours_ago'.tr}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${'minutes_ago'.tr}';
    } else {
      return 'just_now'.tr;
    }
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

  Widget _buildUserApprovalStats(AdminController controller) {
    final stats = controller.userStatistics;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'user_management'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to user management
                    final navController = Get.find<NavigationController>();
                    navController.setAdminIndex(1); // User management tab
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text('view_all'.tr),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                final childAspectRatio = constraints.maxWidth > 600 ? 1.8 : 2.2;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildUserStatCard(
                      'pending_approvals'.tr,
                      '${stats['pending_approvals'] ?? 0}',
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                    _buildUserStatCard(
                      'approved_users'.tr,
                      '${stats['approved_users'] ?? 0}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildUserStatCard(
                      'total_students'.tr,
                      '${stats['students'] ?? 0}',
                      Icons.school,
                      AppTheme.primaryColor,
                    ),
                    _buildUserStatCard(
                      'total_instructors'.tr,
                      '${stats['instructors'] ?? 0}',
                      Icons.person_outline,
                      AppTheme.secondaryColor,
                    ),
                  ],
                );
              },
            ),

            // Quick action for pending approvals
            if ((stats['pending_approvals'] ?? 0) > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${stats['pending_approvals']} users waiting for approval',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final navController = Get.find<NavigationController>();
                        navController.setAdminIndex(1);
                      },
                      child: Text(
                        'review_now'.tr,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 150;

        return Container(
          padding: EdgeInsets.all(isSmall ? 12 : 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: Icon(icon, color: color, size: isSmall ? 18 : 22),
              ),
              SizedBox(height: isSmall ? 2 : 4),
              Flexible(
                flex: 2,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isSmall ? 1 : 2),
              Flexible(
                flex: 3,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 9 : 10,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods for user management
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppTheme.primaryColor;
      case UserRole.instructor:
        return AppTheme.secondaryColor;
      case UserRole.admin:
        return Colors.purple;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.instructor:
        return Icons.person_outline;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // User approval actions from dashboard
  void _approveUserFromDashboard(user) {
    Get.dialog(
      AlertDialog(
        title: Text('approve_user'.tr),
        content: Text('Are you sure you want to approve ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.approveUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('approve'.tr),
          ),
        ],
      ),
    );
  }

  void _rejectUserFromDashboard(user) {
    Get.dialog(
      AlertDialog(
        title: Text('reject_user'.tr),
        content: Text('Are you sure you want to reject ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectUser(user.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('reject'.tr),
          ),
        ],
      ),
    );
  }
}
