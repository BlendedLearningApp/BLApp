import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../models/course_model.dart';
import 'custom_card.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progress;
  final bool showEnrollButton;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.showProgress = false,
    this.progress,
    this.showEnrollButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course thumbnail
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            child: (course.thumbnail?.isNotEmpty ?? false)
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      course.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderThumbnail(),
                    ),
                  )
                : _buildPlaceholderThumbnail(),
          ),
          
          // Course content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course title
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Instructor name
                Text(
                  course.instructorName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withOpacity(0.6),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Course category
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Course stats
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppTheme.textColor.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.enrolledStudents} ${'students'.tr}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                
                // Progress bar (if showing progress)
                if (showProgress && progress != null) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress! * 100).toInt()}% ${'completed'.tr}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
                
                // Enroll button (if showing)
                if (showEnrollButton) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('enroll_now'.tr),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.3),
            AppTheme.accentColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.school,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}
