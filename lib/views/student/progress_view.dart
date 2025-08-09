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

              // Quick Stats Row
              _buildQuickStatsRow(studentController),
              const SizedBox(height: 20),

              // Weekly Progress Chart
              _buildWeeklyProgressChart(studentController),
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
              ...studentController.enrolledCourses
                  .map(
                    (course) =>
                        _buildCourseProgressCard(course, studentController),
                  )
                  .toList(),

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
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
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
                                const Icon(
                                  Icons.book,
                                  color: AppTheme.primaryColor,
                                ),
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
        'earned': controller.enrolledCourses.any(
          (course) => controller.getCourseProgress(course.id) >= 100,
        ),
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

  Widget _buildQuickStatsRow(StudentController controller) {
    final totalVideos = controller.enrolledCourses
        .expand((course) => course.videos)
        .length;
    final watchedVideos = controller.enrolledCourses
        .expand((course) => course.videos)
        .where((video) => controller.isVideoWatched(video.id))
        .length;

    final totalQuizzes = controller.enrolledCourses
        .expand((course) => course.quizzes)
        .length;
    final completedQuizzes = controller.getCompletedQuizzes();

    final totalTimeSpent = _calculateTotalTimeSpent(controller);
    final averageScore = _calculateAverageQuizScore(controller);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.play_circle_outline,
            title: 'videos_watched'.tr,
            value: '$watchedVideos/$totalVideos',
            color: AppTheme.primaryColor,
            progress: totalVideos > 0 ? watchedVideos / totalVideos : 0.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz,
            title: 'quizzes_completed'.tr,
            value: '$completedQuizzes/$totalQuizzes',
            color: AppTheme.accentColor,
            progress: totalQuizzes > 0 ? completedQuizzes / totalQuizzes : 0.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            title: 'time_spent'.tr,
            value: _formatTimeSpent(totalTimeSpent),
            color: AppTheme.secondaryColor,
            showProgress: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            title: 'avg_score'.tr,
            value: '${averageScore.toStringAsFixed(1)}%',
            color: AppTheme.warningColor,
            showProgress: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    double? progress,
    bool showProgress = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showProgress && progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressChart(StudentController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'weekly_progress'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'last_7_days'.tr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Simple progress chart representation
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final dayProgress = _getDayProgress(index, controller);
                final dayName = _getDayName(index);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: (dayProgress * 80).clamp(4.0, 80.0),
                      decoration: BoxDecoration(
                        color: dayProgress > 0
                            ? AppTheme.primaryColor.withValues(alpha: 0.8)
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Progress summary
          Row(
            children: [
              Expanded(
                child: _buildProgressSummaryItem(
                  'videos_this_week'.tr,
                  '${_getWeeklyVideoCount(controller)}',
                  Icons.play_circle_outline,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressSummaryItem(
                  'quizzes_this_week'.tr,
                  '${_getWeeklyQuizCount(controller)}',
                  Icons.quiz,
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations
  int _calculateTotalTimeSpent(StudentController controller) {
    // This would typically come from stored time tracking data
    // For now, estimate based on completed videos
    int totalMinutes = 0;
    for (final course in controller.enrolledCourses) {
      for (final video in course.videos) {
        if (controller.isVideoWatched(video.id)) {
          totalMinutes += (video.durationSeconds / 60).round();
        }
      }
    }
    return totalMinutes;
  }

  double _calculateAverageQuizScore(StudentController controller) {
    final submissions = controller.quizSubmissions;
    if (submissions.isEmpty) return 0.0;

    final totalScore = submissions.fold<double>(
      0.0,
      (sum, submission) => sum + submission.score,
    );
    return totalScore / submissions.length;
  }

  String _formatTimeSpent(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '${hours}h ${remainingMinutes}m'
          : '${hours}h';
    }
  }

  double _getDayProgress(int dayIndex, StudentController controller) {
    // This would typically come from stored daily progress data
    // For now, return mock data
    final mockProgress = [0.8, 0.6, 0.9, 0.4, 0.7, 0.3, 0.5];
    return dayIndex < mockProgress.length ? mockProgress[dayIndex] : 0.0;
  }

  String _getDayName(int dayIndex) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1;
    final targetDay = (today - 6 + dayIndex) % 7;
    return days[targetDay];
  }

  int _getWeeklyVideoCount(StudentController controller) {
    // This would typically come from stored weekly activity data
    return 12; // Mock data
  }

  int _getWeeklyQuizCount(StudentController controller) {
    // This would typically come from stored weekly activity data
    return 5; // Mock data
  }
}
