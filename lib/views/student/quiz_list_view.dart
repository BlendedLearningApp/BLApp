import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/quiz_model.dart';
import '../../routes/app_routes.dart';

class QuizListView extends StatelessWidget {
  const QuizListView({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentController controller = Get.find<StudentController>();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'available_quizzes'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuizzesList(controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuizzesList(StudentController controller) {
    final allQuizzes = <QuizModel>[];
    
    // Collect all quizzes from enrolled courses
    for (final course in controller.enrolledCourses) {
      allQuizzes.addAll(course.quizzes);
    }

    if (allQuizzes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: allQuizzes.map((quiz) => _buildQuizCard(quiz, controller)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: AppTheme.textColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'no_quizzes_available'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'quizzes_will_appear_here'.tr,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz, StudentController controller) {
    // Find the course this quiz belongs to
    final course = controller.enrolledCourses.firstWhere(
      (c) => c.id == quiz.courseId,
      orElse: () => controller.enrolledCourses.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to quiz view with quiz ID
          Get.toNamed(AppRoutes.quiz, arguments: quiz.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                quiz.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuizInfo(Icons.help_outline, '${quiz.questions.length} ${'questions'.tr}'),
                  const SizedBox(width: 16),
                  _buildQuizInfo(Icons.timer_outlined, '${quiz.timeLimit} ${'minutes'.tr}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.quiz, arguments: quiz.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('take_quiz'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textColor.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
