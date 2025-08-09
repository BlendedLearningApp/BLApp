import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/course_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/custom_button.dart';

class CoursePreviewView extends StatefulWidget {
  const CoursePreviewView({super.key});

  @override
  State<CoursePreviewView> createState() => _CoursePreviewViewState();
}

class _CoursePreviewViewState extends State<CoursePreviewView> {
  late final StudentController controller;
  late final AuthController authController;

  final RxBool _isLoading = false.obs;
  final RxBool _isEnrolling = false.obs;
  final Rx<CourseModel?> _course = Rx<CourseModel?>(null);
  final RxBool _isEnrolled = false.obs;

  @override
  void initState() {
    super.initState();

    // Initialize controllers safely
    try {
      controller = Get.find<StudentController>();
      authController = Get.find<AuthController>();
    } catch (e) {
      print('❌ Error initializing controllers: $e');
      // Navigate back if controllers are not available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return;
    }

    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    final courseId = Get.arguments as String?;
    if (courseId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
      return;
    }

    try {
      _isLoading.value = true;

      // Load course details from database (works for both enrolled and unenrolled courses)
      final course = await SupabaseService.getCourseById(courseId);
      _course.value = course;

      // Load enrolled courses to check enrollment status
      await controller.loadStudentData();

      // Check if already enrolled
      _isEnrolled.value = controller.enrolledCourses.any(
        (c) => c.id == courseId,
      );

      print(
        '🔍 Course ${course.title} enrollment status: ${_isEnrolled.value}',
      );
      print('📚 Total enrolled courses: ${controller.enrolledCourses.length}');

      // If already enrolled, redirect to course detail view
      if (_isEnrolled.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed('/student/course/$courseId');
        });
      }
    } catch (e) {
      print('❌ Error loading course: $e');
      _showErrorWithRetry(
        'error_loading_course'.tr,
        () => _loadCourseDetails(),
        showBackButton: true,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void _showErrorWithRetry(
    String message,
    VoidCallback retryAction, {
    bool showBackButton = false,
  }) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          retryAction();
        },
        child: Text(
          'retry'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Show back button option if needed
    if (showBackButton) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.snackbar(
          'navigation'.tr,
          'tap_back_to_return'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // Close snackbar
              Get.back(); // Go back to previous screen
            },
            child: Text(
              'go_back'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      });
    }
  }

  Future<void> _showEnrollmentConfirmation() async {
    // Check if course data is available
    if (_course.value == null) {
      print('❌ Course data not available for enrollment');
      _showEnrollmentErrorDialog('course_data_not_available'.tr);
      return;
    }

    final course = _course.value!;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_enrollment'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('enrollment_confirmation_message'.tr),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by_instructor'.tr.replaceAll(
                      '{instructor}',
                      course.instructorName,
                    ),
                    style: TextStyle(
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text('${course.videos.length} ${'videos'.tr}'),
                      const SizedBox(width: 16),
                      Icon(Icons.quiz, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text('${course.quizzes.length} ${'quizzes'.tr}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('enroll_now'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _enrollInCourse();
    }
  }

  Future<void> _enrollInCourse() async {
    if (_course.value == null || authController.currentUser == null) return;

    try {
      _isEnrolling.value = true;

      final result = await SupabaseService.enrollStudent(
        authController.currentUser!.id,
        _course.value!.id,
      );

      print('🎓 Enrollment result: $result'); // Debug log

      if (result['success'] == true) {
        _isEnrolled.value = true;

        // Refresh enrolled courses
        await controller.loadStudentData();

        // Show success dialog with next steps
        await _showEnrollmentSuccessDialog();

        // Navigate to course detail view after frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed('/student/course/${_course.value!.id}');
        });
      } else {
        final errorKey = result['error'] ?? 'enrollment_failed';
        print('❌ Enrollment failed: $errorKey'); // Debug log
        _showEnrollmentErrorDialog(errorKey.toString().tr);
      }
    } catch (e) {
      print('❌ Enrollment exception: $e'); // Debug log
      _showEnrollmentErrorDialog('enrollment_failed'.tr);
    } finally {
      _isEnrolling.value = false;
    }
  }

  Future<void> _showEnrollmentSuccessDialog() async {
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'enrollment_successful'.tr,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('enrollment_success_message'.tr),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'next_steps'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• ${'start_watching_videos'.tr}'),
                  Text('• ${'take_quizzes'.tr}'),
                  Text('• ${'track_your_progress'.tr}'),
                  Text('• ${'join_discussions'.tr}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: Text('start_learning'.tr),
          ),
        ],
      ),
    );
  }

  void _showEnrollmentErrorDialog(String errorMessage) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppTheme.errorColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'enrollment_failed'.tr,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage),
            const SizedBox(height: 16),
            Text(
              'enrollment_error_help'.tr,
              style: TextStyle(
                color: AppTheme.textColor.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEnrollmentConfirmation(); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('try_again'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_course.value == null) {
          return Center(
            child: Text(
              'course_not_found'.tr,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCourseHeader(),
                    const SizedBox(height: 24),
                    _buildCourseStats(),
                    const SizedBox(height: 24),
                    _buildCourseDescription(),
                    const SizedBox(height: 24),
                    _buildCourseContent(),
                    const SizedBox(height: 24),
                    _buildInstructorInfo(),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() => _buildEnrollButton()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: _course.value?.thumbnail != null
            ? Image.network(_course.value!.thumbnail!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.school, size: 80, color: Colors.white),
                ),
              ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _course.value!.category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _course.value!.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: AppTheme.textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              _course.value!.instructorName,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            label: 'students'.tr,
            value: '${_course.value!.enrolledStudents}',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.video_library,
            label: 'videos'.tr,
            value: '${_course.value!.videos.length}',
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz,
            label: 'quizzes'.tr,
            value: '${_course.value!.quizzes.length}',
            color: AppTheme.secondaryColor,
          ),
        ),
        if (_course.value!.rating > 0) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star,
              label: 'rating'.tr,
              value: _course.value!.rating.toStringAsFixed(1),
              color: AppTheme.warningColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'course_description'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _course.value!.description,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textColor.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'course_content'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),

        // Videos Section
        if (_course.value!.videos.isNotEmpty) ...[
          _buildContentSection(
            title: 'videos'.tr,
            icon: Icons.play_circle_outline,
            count: _course.value!.videos.length,
            items: _course.value!.videos
                .take(3)
                .map((video) => video.title)
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Quizzes Section
        if (_course.value!.quizzes.isNotEmpty) ...[
          _buildContentSection(
            title: 'quizzes'.tr,
            icon: Icons.quiz,
            count: _course.value!.quizzes.length,
            items: _course.value!.quizzes
                .take(3)
                .map((quiz) => quiz.title)
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildContentSection({
    required String title,
    required IconData icon,
    required int count,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '$title ($count)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (count > 3) ...[
            const SizedBox(height: 8),
            Text(
              'and_more_items'.tr.replaceAll('{count}', '${count - 3}'),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              _course.value!.instructorName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'instructor'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _course.value!.instructorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollButton() {
    if (_isEnrolled.value) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomButton(
          text: 'go_to_course'.tr,
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offNamed('/student/course/${_course.value!.id}');
            });
          },
          type: ButtonType.secondary,
          icon: Icons.arrow_forward,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomButton(
        text: 'enroll_now'.tr,
        onPressed: _course.value != null ? _showEnrollmentConfirmation : null,
        isLoading: _isEnrolling.value,
        icon: Icons.school,
      ),
    );
  }
}
