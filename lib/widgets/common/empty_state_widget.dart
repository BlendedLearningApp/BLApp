import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onActionPressed,
    this.iconSize = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppTheme.textColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                type: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined empty states for common scenarios
class EmptyStates {
  static Widget noCourses({VoidCallback? onCreateCourse}) {
    return EmptyStateWidget(
      icon: Icons.school_outlined,
      title: 'no_courses_yet'.tr,
      description: 'start_learning_journey'.tr,
      actionText: onCreateCourse != null ? 'browse_courses'.tr : null,
      onActionPressed: onCreateCourse,
    );
  }

  static Widget noQuizzes({VoidCallback? onCreateQuiz}) {
    return EmptyStateWidget(
      icon: Icons.quiz_outlined,
      title: 'no_quizzes_available'.tr,
      description: 'quizzes_will_appear_here'.tr,
      actionText: onCreateQuiz != null ? 'create_quiz'.tr : null,
      onActionPressed: onCreateQuiz,
    );
  }

  static Widget noVideos({VoidCallback? onAddVideo}) {
    return EmptyStateWidget(
      icon: Icons.video_library_outlined,
      title: 'no_videos_yet'.tr,
      description: 'videos_will_appear_here'.tr,
      actionText: onAddVideo != null ? 'add_video'.tr : null,
      onActionPressed: onAddVideo,
    );
  }

  static Widget noForumPosts({VoidCallback? onCreatePost}) {
    return EmptyStateWidget(
      icon: Icons.forum_outlined,
      title: 'no_discussions_yet'.tr,
      description: 'start_conversation'.tr,
      actionText: onCreatePost != null ? 'create_post'.tr : null,
      onActionPressed: onCreatePost,
    );
  }

  static Widget noStudents() {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'no_students_enrolled'.tr,
      description: 'students_will_appear_here'.tr,
    );
  }
}
