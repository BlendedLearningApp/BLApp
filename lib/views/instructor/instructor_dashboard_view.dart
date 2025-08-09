import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/instructor_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../widgets/bottom_navigation/instructor_bottom_nav.dart';
import 'instructor_courses_view.dart';
import 'manage_videos_view.dart';
import 'instructor_quiz_manager_view.dart';
import 'student_submissions_view.dart';
import 'instructor_profile_view.dart';

class InstructorDashboardView extends StatefulWidget {
  const InstructorDashboardView({super.key});

  @override
  State<InstructorDashboardView> createState() =>
      _InstructorDashboardViewState();
}

class _InstructorDashboardViewState extends State<InstructorDashboardView> {
  final InstructorController controller = Get.find<InstructorController>();
  final NavigationController navController = Get.find<NavigationController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Set dashboard as active tab when entering
    navController.setInstructorIndex(0);

    // Load data when dashboard is displayed with better retry mechanism
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _waitForAuthAndLoadData();
    });
  }

  Future<void> _waitForAuthAndLoadData() async {
    final authController = Get.find<AuthController>();
    print('📱 InstructorDashboard - Starting auth wait process');

    // Wait up to 5 seconds for authentication to complete
    int attempts = 0;
    const maxAttempts = 10; // 5 seconds total

    while (attempts < maxAttempts) {
      print('📱 Attempt ${attempts + 1}/$maxAttempts:');
      print('   Is logged in: ${authController.isLoggedIn}');
      print('   Current user: ${authController.currentUser?.name ?? "NULL"}');

      if (authController.isLoggedIn && authController.currentUser != null) {
        print('📱 ✅ Authentication successful, loading instructor data');
        await controller.loadInstructorData();
        return;
      }

      attempts++;
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('📱 ❌ Authentication timeout after ${maxAttempts * 500}ms');
    print(
      '📱 Final state: logged in = ${authController.isLoggedIn}, user = ${authController.currentUser?.name ?? "NULL"}',
    );
  }

  void _onNavTap(int index) {
    navController.navigateInstructor(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Obx(() {
          switch (navController.instructorCurrentIndex) {
            case 0:
              return Text('dashboard'.tr);
            case 1:
              return Text('my_courses'.tr);
            case 2:
              return Text('videos'.tr);
            case 3:
              return Text('quizzes'.tr);
            case 4:
              return Text('submissions'.tr);
            case 5:
              return Text('profile'.tr);
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
                Get.toNamed('/instructor/profile');
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

        return IndexedStack(
          index: navController.instructorCurrentIndex,
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

                    // Quick stats
                    _buildQuickStats(),

                    const SizedBox(height: 24),

                    // Quick actions
                    _buildQuickActions(),

                    const SizedBox(height: 24),

                    // My courses section
                    _buildMyCoursesSection(),

                    const SizedBox(height: 24),

                    // Recent submissions
                    _buildRecentSubmissionsSection(),
                  ],
                ),
              ),
            ),
            // My Courses
            const InstructorCoursesView(),
            // Videos
            const ManageVideosView(),
            // Quizzes
            const InstructorQuizManagerView(),
            // Submissions
            const StudentSubmissionsView(),
            // Profile
            const InstructorProfileView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => InstructorBottomNavigation(
          currentIndex: navController.instructorCurrentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AuthController authController) {
    // Debug: Check current user data
    final currentUser = authController.currentUser;
    print('🏠 Dashboard Welcome Section Debug:');
    print('   User exists: ${currentUser != null}');
    print('   User name: ${currentUser?.name ?? "NULL"}');
    print('   User email: ${currentUser?.email ?? "NULL"}');
    print('   User role: ${currentUser?.role ?? "NULL"}');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor,
            AppTheme.accentColor.withValues(alpha: 0.8),
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
                  '${'welcome'.tr}, ${currentUser?.name ?? 'User'}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ready_to_teach'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, size: 32, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'my_courses'.tr,
            value: controller.instructorCourses.length.toString(),
            icon: Icons.book,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'submissions'.tr,
            value: controller.studentSubmissions.length.toString(),
            icon: Icons.assignment_turned_in,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'students'.tr,
            value: _getTotalStudents().toString(),
            icon: Icons.people,
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  int _getTotalStudents() {
    int totalStudents = 0;
    for (var course in controller.instructorCourses) {
      totalStudents += course.enrolledStudents;
    }
    return totalStudents;
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
            color: color.withValues(alpha: 0.1),
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
              color: AppTheme.textColor.withValues(alpha: 0.6),
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
                title: 'create_course'.tr,
                icon: Icons.add_circle,
                color: AppTheme.primaryColor,
                onTap: () => Get.toNamed('/instructor/create-course'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'manage_videos'.tr,
                icon: Icons.video_library,
                color: AppTheme.accentColor,
                onTap: () => Get.toNamed('/instructor/manage-videos'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'quiz_manager'.tr,
                icon: Icons.quiz,
                color: AppTheme.secondaryColor,
                onTap: () {
                  print(
                    '🎯 Quiz Manager card clicked - navigating to Quizzes tab',
                  );
                  final navController = Get.find<NavigationController>();
                  navController.navigateInstructor(
                    3,
                  ); // Navigate to Quizzes tab (index 3)
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'view_submissions'.tr,
                icon: Icons.assignment,
                color: AppTheme.primaryColor,
                onTap: () => Get.toNamed('/instructor/submissions'),
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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

  Widget _buildMyCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'my_courses'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/instructor/courses'),
              child: Text('view_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.instructorCourses.take(5).length,
            itemBuilder: (context, index) {
              final course = controller.instructorCourses[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => Get.toNamed('/instructor/course/${course.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              size: 40,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${course.enrolledStudents} ${'students'.tr}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textColor.withValues(
                                    alpha: 0.6,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSubmissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_submissions'.tr,
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
              children: controller.studentSubmissions.take(3).map((submission) {
                return Column(
                  children: [
                    _buildSubmissionItem(submission),
                    if (submission !=
                        controller.studentSubmissions.take(3).last)
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

  Widget _buildSubmissionItem(submission) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.assignment_turned_in,
            color: AppTheme.accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                submission.quizTitle ?? 'Quiz Submission',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              Text(
                'Score: ${submission.score}/${submission.totalQuestions}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Text(
          '${submission.score}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: submission.score >= 70
                ? AppTheme.accentColor
                : Colors.orange,
          ),
        ),
      ],
    );
  }
}
