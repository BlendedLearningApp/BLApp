import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/student_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';
import 'package:blapp/widgets/common/loading_widget.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final studentController = Get.find<StudentController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('progress'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (studentController.isLoading.value) {
          return const LoadingWidget();
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall Progress Card
              _buildOverallProgressCard(studentController),
              const SizedBox(height: 20),
              
              // Course Progress Section
              Text(
                'course_progress'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // Course Progress List
              ...studentController.enrolledCourses.map((course) => 
                _buildCourseProgressCard(course, studentController)
              ).toList(),
              
              const SizedBox(height: 20),
              
              // Achievements Section
              Text(
                'achievements'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildAchievementsSection(studentController),
              
              const SizedBox(height: 20),
              
              // Learning Stats
              Text(
                'learning_stats'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildLearningStats(studentController),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildOverallProgressCard(StudentController controller) {
    final totalCourses = controller.enrolledCourses.length;
    final completedCourses = controller.enrolledCourses
        .where((course) => controller.getCourseProgress(course.id) >= 100)
        .length;
    final overallProgress = totalCourses > 0 
        ? (completedCourses / totalCourses * 100).round() 
        : 0;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'overall_progress'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCourses of $totalCourses courses completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$overallProgress%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCourseProgressCard(course, StudentController controller) {
    final progress = controller.getCourseProgress(course.id);
    final completedQuizzes = controller.getCompletedQuizzes();
    final totalQuizzes = 3; // Mock data
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: course.thumbnail != null
                        ? Image.network(
                            course.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.book, color: AppTheme.primaryColor),
                          )
                        : const Icon(Icons.book, color: AppTheme.primaryColor),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Instructor: ${course.instructorName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${progress.toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '$completedQuizzes/$totalQuizzes quizzes',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 100 ? AppTheme.accentColor : AppTheme.primaryColor,
              ),
              minHeight: 6,
            ),
            if (progress >= 100) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.accentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'completed'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievementsSection(StudentController controller) {
    final achievements = [
      {
        'icon': Icons.school,
        'title': 'First Course Completed',
        'description': 'Completed your first course',
        'earned': controller.enrolledCourses.any((course) => 
            controller.getCourseProgress(course.id) >= 100),
      },
      {
        'icon': Icons.quiz,
        'title': 'Quiz Master',
        'description': 'Passed 5 quizzes',
        'earned': controller.getCompletedQuizzes() >= 5,
      },
      {
        'icon': Icons.local_fire_department,
        'title': 'Learning Streak',
        'description': '7 days of continuous learning',
        'earned': false, // Mock data
      },
      {
        'icon': Icons.star,
        'title': 'Top Performer',
        'description': 'Scored 90%+ in 3 quizzes',
        'earned': false, // Mock data
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isEarned = achievement['earned'] as bool;
        
        return CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEarned 
                        ? AppTheme.accentColor.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    achievement['icon'] as IconData,
                    color: isEarned ? AppTheme.accentColor : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isEarned ? AppTheme.textColor : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isEarned 
                        ? AppTheme.textColor.withValues(alpha: 0.7)
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLearningStats(StudentController controller) {
    final stats = [
      {
        'icon': Icons.timer,
        'title': 'Study Time',
        'value': '24h 30m',
        'subtitle': 'This month',
        'color': AppTheme.primaryColor,
      },
      {
        'icon': Icons.assignment_turned_in,
        'title': 'Quizzes Passed',
        'value': controller.getCompletedQuizzes().toString(),
        'subtitle': 'Total completed',
        'color': AppTheme.accentColor,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Average Score',
        'value': '87%',
        'subtitle': 'Quiz average',
        'color': AppTheme.warningColor,
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Learning Days',
        'value': '15',
        'subtitle': 'This month',
        'color': Colors.purple,
      },
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        
        return CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: stat['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  stat['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textColor.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
