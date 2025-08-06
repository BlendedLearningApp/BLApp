import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/instructor_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/course_model.dart';
import '../../widgets/common/custom_card.dart';

class CourseSelectorWidget extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final VoidCallback? onCourseSelected;

  const CourseSelectorWidget({
    super.key,
    required this.title,
    required this.emptyMessage,
    this.onCourseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final instructorController = Get.find<InstructorController>();

    return Obx(() {
      final courses = instructorController.instructorCourses;
      final selectedCourse = instructorController.currentCourse;

      if (courses.isEmpty) {
        return _buildEmptyState();
      }

      return CustomCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CourseModel>(
                  value: selectedCourse,
                  hint: Text(
                    'select_course'.tr,
                    style: TextStyle(
                      color: AppTheme.textColor.withValues(alpha: 0.6),
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primaryColor,
                  ),
                  items: courses.map((course) {
                    return DropdownMenuItem<CourseModel>(
                      value: course,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            course.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (CourseModel? course) {
                    if (course != null) {
                      instructorController.selectCourse(course);
                      onCourseSelected?.call();
                    }
                  },
                ),
              ),
            ),
            if (selectedCourse != null) ...[
              const SizedBox(height: 12),
              _buildSelectedCourseInfo(selectedCourse),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSelectedCourseInfo(CourseModel course) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            course.description,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(
                Icons.video_library,
                '${course.videos.length} ${'videos'.tr}',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.quiz,
                '${course.quizzes.length} ${'quizzes'.tr}',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.description,
                '${course.worksheets.length} ${'worksheets'.tr}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.accentColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 48,
            color: AppTheme.textColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'no_courses_available'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to course creation
              final navController = Get.find<NavigationController>();
              navController.navigateInstructor(
                1,
              ); // Navigate to create course tab
            },
            icon: const Icon(Icons.add),
            label: Text('create_first_course'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
