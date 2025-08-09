import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/course_model.dart';
import '../../models/video_model.dart';
import '../../models/quiz_model.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/student/video_player_widget.dart';
import '../../routes/app_routes.dart';
import '../../services/supabase_service.dart';

class CourseDetailView extends StatefulWidget {
  const CourseDetailView({super.key});

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  final StudentController controller = Get.find<StudentController>();
  CourseModel? currentCourse;
  int selectedVideoIndex = 0;

  // Video progress tracking
  Map<String, double> videoProgress = {};
  Map<String, bool> videoCompleted = {};

  // Worksheet tracking
  Map<String, bool> worksheetDownloaded = {};
  Map<String, bool> worksheetCompleted = {};

  // Quiz tracking
  Map<String, bool> quizCompleted = {};
  Map<String, int> quizScores = {};

  // Loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to prevent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourseData();
    });
  }

  Future<void> _loadCourseData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final courseId = Get.arguments as String?;

      if (courseId == null) {
        // No course ID provided, use first enrolled course if available
        await controller.loadStudentData();

        if (controller.enrolledCourses.isNotEmpty) {
          setState(() {
            currentCourse = controller.enrolledCourses.first;
            isLoading = false;
          });

          // Debug: Log course and video information
          print('🎓 Course loaded: ${currentCourse?.title}');
          print('🎥 Videos count: ${currentCourse?.videos.length ?? 0}');
          if (currentCourse?.videos.isNotEmpty == true) {
            print('🎥 First video: ${currentCourse!.videos.first.title}');
            print(
              '🎥 First video URL: ${currentCourse!.videos.first.youtubeUrl}',
            );
            print(
              '🎥 First video ID: ${currentCourse!.videos.first.youtubeVideoId}',
            );
          }

          // Set initial video index if course has videos
          if (currentCourse?.videos.isNotEmpty == true) {
            selectedVideoIndex = 0;
          }
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Ensure enrolled courses are loaded
        await controller.loadStudentData();
        print(
          '📚 Total enrolled courses: ${controller.enrolledCourses.length}',
        );
        print('🔍 Looking for course ID: $courseId');

        // Try to find the course in enrolled courses
        try {
          final course = controller.enrolledCourses.firstWhere(
            (c) => c.id == courseId,
          );
          setState(() {
            currentCourse = course;
            isLoading = false;
          });

          // Debug: Log course and video information
          print('🎓 Course loaded by ID: ${currentCourse?.title}');
          print('🎥 Videos count: ${currentCourse?.videos.length ?? 0}');
          if (currentCourse?.videos.isNotEmpty == true) {
            print('🎥 First video: ${currentCourse!.videos.first.title}');
            print(
              '🎥 First video URL: ${currentCourse!.videos.first.youtubeUrl}',
            );
            print(
              '🎥 First video ID: ${currentCourse!.videos.first.youtubeVideoId}',
            );
          }

          // Set initial video index if course has videos
          if (currentCourse?.videos.isNotEmpty == true) {
            selectedVideoIndex = 0;
          }
        } catch (e) {
          // Course not found in enrolled courses, try fetching from database
          print(
            '⚠️ Course $courseId not found in enrolled courses, trying database...',
          );

          try {
            final course = await SupabaseService.getCourseById(courseId);
            setState(() {
              currentCourse = course;
              isLoading = false;
            });

            // Debug: Log course and video information
            print('🎓 Course loaded from database: ${currentCourse?.title}');
            print('🎥 Videos count: ${currentCourse?.videos.length ?? 0}');
            if (currentCourse?.videos.isNotEmpty == true) {
              print('🎥 First video: ${currentCourse!.videos.first.title}');
              print(
                '🎥 First video URL: ${currentCourse!.videos.first.youtubeUrl}',
              );
              print(
                '🎥 First video ID: ${currentCourse!.videos.first.youtubeVideoId}',
              );
            }

            // Set initial video index if course has videos
            if (currentCourse?.videos.isNotEmpty == true) {
              selectedVideoIndex = 0;
            }
          } catch (dbError) {
            print('❌ Failed to load course from database: $dbError');
            Get.offNamed('/student/course-preview', arguments: courseId);
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Error loading course data: $e');
    }
  }

  void _selectVideo(int index) {
    if (currentCourse != null && index < currentCourse!.videos.length) {
      print('🎥 Selecting video $index: ${currentCourse!.videos[index].title}');
      setState(() {
        selectedVideoIndex = index;
      });
      print(
        '✅ Video selection updated. New selectedVideoIndex: $selectedVideoIndex',
      );
    } else {
      print(
        '❌ Cannot select video $index. Course: ${currentCourse != null}, Videos count: ${currentCourse?.videos.length ?? 0}',
      );
    }
  }

  // Simplified video state tracking for WebView
  void _markVideoAsWatched(VideoModel video) {
    setState(() {
      videoCompleted[video.id] = true;
      videoProgress[video.id] = 1.0;
    });
    _showVideoCompletedDialog(video);
  }

  void _showVideoCompletedDialog(VideoModel video) {
    Get.snackbar(
      'video_completed'.tr,
      'video_completed_message'.tr.replaceAll('{title}', video.title),
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(VideoModel video, int index) {
    final isSelected = index == selectedVideoIndex;
    final isCompleted = videoCompleted[video.id] ?? false;
    final watchProgress = videoProgress[video.id] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.accentColor
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : isSelected
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: isCompleted ? Colors.white : AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                if (!isCompleted && watchProgress > 0) ...[
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            title: Text(
              video.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppTheme.textColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(video.durationSeconds),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'completed'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else if (watchProgress > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${(watchProgress * 100).toInt()}% ${'watched'.tr}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: isSelected
                ? Icon(
                    Icons.play_circle_filled,
                    color: AppTheme.primaryColor,
                    size: 24,
                  )
                : Icon(Icons.play_circle_outline, color: Colors.grey, size: 20),
            onTap: () {
              _selectVideo(index);
              // Provide haptic feedback
              HapticFeedback.lightImpact();
            },
          ),

          // Progress bar for partially watched videos
          if (!isCompleted && watchProgress > 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: LinearProgressIndicator(
                value: watchProgress,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.warningColor,
                ),
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizItem(QuizModel quiz) {
    final isCompleted = quizCompleted[quiz.id] ?? false;
    final score = quizScores[quiz.id];

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
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
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted ? Icons.quiz : Icons.quiz_outlined,
                      color: isCompleted ? Colors.green : AppTheme.accentColor,
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
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (quiz.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            quiz.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCompleted && score != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: score >= quiz.passingScore
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$score%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Quiz metadata - Responsive layout
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.timeLimit} ${'minutes'.tr}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.questions.length} ${'questions'.tr}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.percent, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${'passing_score'.tr}: ${quiz.passingScore}%',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.play_circle_outline,
                    size: 16,
                    color: isCompleted ? Colors.green : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCompleted ? 'completed'.tr : 'start_quiz'.tr,
                    style: TextStyle(
                      color: isCompleted ? Colors.green : AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isCompleted) ...[
                    const Spacer(),
                    Text(
                      'retake_quiz'.tr,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceItem(worksheet) {
    final isDownloaded = worksheetDownloaded[worksheet.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDownloaded ? Icons.check_circle : Icons.description,
            color: isDownloaded ? AppTheme.accentColor : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          worksheet.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${worksheet.fileType?.toUpperCase() ?? 'PDF'} • ${worksheet.fileSize ?? 'Unknown size'} • ${worksheet.description ?? 'No description'}',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          isDownloaded ? Icons.open_in_new : Icons.download,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        onTap: () {
          _downloadResource(worksheet);
        },
      ),
    );
  }

  double _calculateProgress() {
    if (currentCourse!.videos.isEmpty) return 0.0;
    final completedVideos = currentCourse!.videos
        .where((video) => videoCompleted[video.id] ?? false)
        .length;
    return completedVideos / currentCourse!.videos.length;
  }

  Widget _buildProgressOverview() {
    final totalVideos = currentCourse!.videos.length;
    final completedVideos = currentCourse!.videos
        .where((video) => videoCompleted[video.id] ?? false)
        .length;

    final totalQuizzes = currentCourse!.quizzes.length;
    final completedQuizzes = currentCourse!.quizzes
        .where((quiz) => quizCompleted[quiz.id] ?? false)
        .length;

    final totalWorksheets = currentCourse!.worksheets.length;
    final completedWorksheets = currentCourse!.worksheets
        .where((worksheet) => worksheetCompleted[worksheet.id] ?? false)
        .length;

    final overallProgress = _calculateOverallProgress();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'overall_progress'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            Text(
              '${(overallProgress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: overallProgress,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 6,
        ),
        const SizedBox(height: 16),

        // Progress Breakdown
        Row(
          children: [
            Expanded(
              child: _buildProgressItem(
                icon: Icons.play_circle_outline,
                label: 'videos'.tr,
                completed: completedVideos,
                total: totalVideos,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressItem(
                icon: Icons.quiz,
                label: 'quizzes'.tr,
                completed: completedQuizzes,
                total: totalQuizzes,
              ),
            ),
            if (totalWorksheets > 0) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.description,
                  label: 'resources'.tr,
                  completed: completedWorksheets,
                  total: totalWorksheets,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required int completed,
    required int total,
  }) {
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 4),
          Text(
            '$completed/$total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOverallProgress() {
    final totalItems =
        currentCourse!.videos.length +
        currentCourse!.quizzes.length +
        currentCourse!.worksheets.length;

    if (totalItems == 0) return 0.0;

    final completedItems =
        currentCourse!.videos
            .where((video) => videoCompleted[video.id] ?? false)
            .length +
        currentCourse!.quizzes
            .where((quiz) => quizCompleted[quiz.id] ?? false)
            .length +
        currentCourse!.worksheets
            .where((worksheet) => worksheetCompleted[worksheet.id] ?? false)
            .length;

    return completedItems / totalItems;
  }

  void _downloadResource(worksheet) {
    setState(() {
      worksheetDownloaded[worksheet.id] = true;
    });
    Get.snackbar(
      'success'.tr,
      'resource_downloaded'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _seekToPosition(double progress) {
    // WebView doesn't support programmatic seeking
    // This is a limitation of the WebView approach
    Get.snackbar(
      'info'.tr,
      'seek_not_supported'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _playNextVideo() {
    if (selectedVideoIndex < currentCourse!.videos.length - 1) {
      _selectVideo(selectedVideoIndex + 1);
    }
  }

  void _playPreviousVideo() {
    if (selectedVideoIndex > 0) {
      _selectVideo(selectedVideoIndex - 1);
    }
  }

  @override
  void dispose() {
    // WebView controller doesn't need explicit disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('course_detail'.tr),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentCourse == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('course_detail'.tr),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            'no_course_selected'.tr,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(currentCourse!.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use responsive layout based on screen width
          if (constraints.maxWidth < 800) {
            // Mobile layout - single column
            return _buildMobileLayout();
          } else {
            // Desktop layout - two columns
            return Row(
              children: [
                // Left Sidebar - Course Content
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Course Header with Progress
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.accentColor,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentCourse!.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${'by'.tr} ${currentCourse!.instructorName}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Enhanced Progress Section
                              _buildProgressOverview(),
                            ],
                          ),
                        ),

                        // Course Content List
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Videos Section
                              if (currentCourse!.videos.isNotEmpty) ...[
                                _buildSectionHeader(
                                  'course_videos'.tr,
                                  Icons.play_circle_outline,
                                ),
                                const SizedBox(height: 8),
                                ...currentCourse!.videos.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final video = entry.value;
                                  return _buildVideoItem(video, index);
                                }).toList(),
                                const SizedBox(height: 24),
                              ],

                              // Quizzes Section
                              if (currentCourse!.quizzes.isNotEmpty) ...[
                                _buildSectionHeader(
                                  'course_quizzes'.tr,
                                  Icons.quiz,
                                ),
                                const SizedBox(height: 8),
                                ...currentCourse!.quizzes
                                    .map((quiz) => _buildQuizItem(quiz))
                                    .toList(),
                                const SizedBox(height: 24),
                              ],

                              // Worksheets Section
                              if (currentCourse!.worksheets.isNotEmpty) ...[
                                _buildSectionHeader(
                                  'course_resources'.tr,
                                  Icons.description,
                                ),
                                const SizedBox(height: 8),
                                ...currentCourse!.worksheets
                                    .map(
                                      (worksheet) =>
                                          _buildResourceItem(worksheet),
                                    )
                                    .toList(),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Video Player Section
                        // Debug: Check video player condition
                        Builder(
                          builder: (context) {
                            print('🔍 VideoPlayer condition check:');
                            print(
                              '   currentCourse != null: ${currentCourse != null}',
                            );
                            print(
                              '   videos.isNotEmpty: ${currentCourse?.videos.isNotEmpty}',
                            );
                            print(
                              '   videos.length: ${currentCourse?.videos.length}',
                            );
                            print('   selectedVideoIndex: $selectedVideoIndex');
                            print(
                              '   condition result: ${currentCourse!.videos.isNotEmpty && selectedVideoIndex < currentCourse!.videos.length}',
                            );
                            return const SizedBox.shrink();
                          },
                        ),
                        if (currentCourse!.videos.isNotEmpty &&
                            selectedVideoIndex <
                                currentCourse!.videos.length) ...[
                          Container(
                            height: 250,
                            padding: const EdgeInsets.all(16),
                            child: VideoPlayerWidget(
                              key: ValueKey(
                                'video_${currentCourse!.videos[selectedVideoIndex].id}',
                              ),
                              video: currentCourse!.videos[selectedVideoIndex],
                              onVideoCompleted: () {
                                // Mark video as completed
                                setState(() {
                                  videoCompleted[currentCourse!
                                          .videos[selectedVideoIndex]
                                          .id] =
                                      true;
                                });
                              },
                              onProgressUpdate: (watchTime) {
                                // Update video progress
                                // This could be used to track watch time
                              },
                            ),
                          ),

                          // Video Controls and Info
                          Container(
                            color: Colors.black87,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Video Title and Status
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentCourse!
                                                .videos[selectedVideoIndex]
                                                .title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'video_duration_placeholder'.tr,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (videoCompleted[currentCourse!
                                            .videos[selectedVideoIndex]
                                            .id] ==
                                        true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'completed'.tr,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Video Navigation Controls
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: selectedVideoIndex > 0
                                          ? _playPreviousVideo
                                          : null,
                                      icon: Icon(
                                        Icons.skip_previous,
                                        color: selectedVideoIndex > 0
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // WebView doesn't support programmatic play/pause
                                        Get.snackbar(
                                          'info'.tr,
                                          'use_video_controls'.tr,
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.play_circle_filled,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed:
                                          selectedVideoIndex <
                                              currentCourse!.videos.length - 1
                                          ? _playNextVideo
                                          : null,
                                      icon: Icon(
                                        Icons.skip_next,
                                        color:
                                            selectedVideoIndex <
                                                currentCourse!.videos.length - 1
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Course Info Section
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Course Title and Instructor
                                Text(
                                  currentCourse!.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'by ${currentCourse!.instructorName}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Course Description
                                Text(
                                  'description'.tr,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentCourse!.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textColor.withValues(
                                      alpha: 0.8,
                                    ),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Videos List
                                if (currentCourse!.videos.isNotEmpty)
                                  Column(
                                    children: [
                                      Text(
                                        'course_videos'.tr,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: currentCourse!.videos.length,
                                        itemBuilder: (context, index) {
                                          final video =
                                              currentCourse!.videos[index];
                                          final isSelected =
                                              index == selectedVideoIndex;
                                          final isCompleted =
                                              videoCompleted[video.id] == true;
                                          final progress =
                                              videoProgress[video.id] ?? 0.0;

                                          return CustomCard(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            backgroundColor: isSelected
                                                ? AppTheme.primaryColor
                                                      .withValues(alpha: 0.1)
                                                : Colors.white,
                                            onTap: () {
                                              _selectVideo(index);
                                              HapticFeedback.lightImpact();
                                            },
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          width: 60,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: AppTheme
                                                                .primaryColor
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            isSelected
                                                                ? Icons
                                                                      .play_circle_filled
                                                                : Icons
                                                                      .play_circle_outline,
                                                            color: AppTheme
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                        if (isCompleted)
                                                          Positioned(
                                                            top: -2,
                                                            right: -2,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    2,
                                                                  ),
                                                              decoration: const BoxDecoration(
                                                                color: AppTheme
                                                                    .accentColor,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: const Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size: 12,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  video.title,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        isSelected
                                                                        ? AppTheme
                                                                              .primaryColor
                                                                        : AppTheme
                                                                              .textColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              if (isCompleted)
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            2,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: AppTheme
                                                                        .accentColor
                                                                        .withValues(
                                                                          alpha:
                                                                              0.1,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  child: Text(
                                                                    'completed'
                                                                        .tr,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: AppTheme
                                                                          .accentColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            '${_formatDuration(video.durationSeconds)} • ${video.description}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme
                                                                  .textColor
                                                                  .withValues(
                                                                    alpha: 0.6,
                                                                  ),
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // Progress Bar
                                                if (progress > 0)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '${'progress'.tr}: ${(progress * 100).toInt()}%',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: AppTheme
                                                                    .textColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.7,
                                                                    ),
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            if (progress > 0 &&
                                                                !isCompleted)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  _selectVideo(
                                                                    index,
                                                                  );
                                                                  HapticFeedback.lightImpact();
                                                                },
                                                                child: Text(
                                                                  'resume'.tr,
                                                                  style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: AppTheme
                                                                        .primaryColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        LinearProgressIndicator(
                                                          value: progress,
                                                          backgroundColor:
                                                              Colors.grey
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(
                                                                isCompleted
                                                                    ? AppTheme
                                                                          .accentColor
                                                                    : AppTheme
                                                                          .primaryColor,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 24),

                                // Worksheets Section
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'worksheets'.tr,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: _showWorksheetUploadDialog,
                                      icon: const Icon(Icons.add, size: 16),
                                      label: Text('add_worksheet'.tr),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (currentCourse!.worksheets.isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: currentCourse!.worksheets.length,
                                    itemBuilder: (context, index) {
                                      final worksheet =
                                          currentCourse!.worksheets[index];
                                      final isDownloaded =
                                          worksheetDownloaded[worksheet.id] ??
                                          false;
                                      final isCompleted =
                                          worksheetCompleted[worksheet.id] ??
                                          false;

                                      return CustomCard(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: _buildEnhancedWorksheetItem(
                                          worksheet,
                                          isDownloaded,
                                          isCompleted,
                                        ),
                                      );
                                    },
                                  )
                                else
                                  CustomCard(
                                    child: EmptyStateWidget(
                                      icon: Icons.description_outlined,
                                      title: 'no_worksheets_available'.tr,
                                      description:
                                          'worksheets_will_be_added_by_instructor'
                                              .tr,
                                    ),
                                  ),

                                const SizedBox(height: 24),

                                // Quizzes Section
                                if (currentCourse!.quizzes.isNotEmpty)
                                  Column(
                                    children: [
                                      Text(
                                        'quizzes'.tr,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            currentCourse!.quizzes.length,
                                        itemBuilder: (context, index) {
                                          final quiz =
                                              currentCourse!.quizzes[index];
                                          return CustomCard(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.accentColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.quiz,
                                                    color: AppTheme.accentColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        quiz.title,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppTheme
                                                              .textColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${quiz.questions.length} questions • ${quiz.timeLimit} min',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppTheme
                                                              .textColor
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                CustomButton(
                                                  text: 'take_quiz'.tr,
                                                  type: ButtonType.primary,
                                                  onPressed: () {
                                                    Get.toNamed(
                                                      '/student/quiz',
                                                      arguments: quiz.id,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Course Header with Progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentCourse!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${'by'.tr} ${currentCourse!.instructorName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressOverview(),
              ],
            ),
          ),

          // Course Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Title and Instructor
                Text(
                  currentCourse!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${'by'.tr} ${currentCourse!.instructorName}',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Course Description
                Text(
                  currentCourse!.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Video Player Section (Mobile)
                // Debug: Check mobile video player condition
                Builder(
                  builder: (context) {
                    print('🔍 Mobile VideoPlayer condition check:');
                    print('   currentCourse != null: ${currentCourse != null}');
                    print(
                      '   videos.isNotEmpty: ${currentCourse?.videos.isNotEmpty}',
                    );
                    print('   videos.length: ${currentCourse?.videos.length}');
                    print('   selectedVideoIndex: $selectedVideoIndex');
                    print(
                      '   condition result: ${currentCourse!.videos.isNotEmpty && selectedVideoIndex < currentCourse!.videos.length}',
                    );
                    return const SizedBox.shrink();
                  },
                ),
                if (currentCourse!.videos.isNotEmpty &&
                    selectedVideoIndex < currentCourse!.videos.length) ...[
                  Container(
                    height: 250,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: VideoPlayerWidget(
                      key: ValueKey(
                        'video_${currentCourse!.videos[selectedVideoIndex].id}',
                      ),
                      video: currentCourse!.videos[selectedVideoIndex],
                      onVideoCompleted: () {
                        // Mark video as completed
                        setState(() {
                          videoCompleted[currentCourse!
                                  .videos[selectedVideoIndex]
                                  .id] =
                              true;
                        });
                      },
                      onProgressUpdate: (watchTime) {
                        // Update video progress
                        // This could be used to track watch time
                      },
                    ),
                  ),
                ],

                // Videos Section
                if (currentCourse!.videos.isNotEmpty) ...[
                  Text(
                    'course_videos'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...currentCourse!.videos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final video = entry.value;
                    return _buildVideoItem(video, index);
                  }),
                  const SizedBox(height: 24),
                ],

                // Quizzes Section
                if (currentCourse!.quizzes.isNotEmpty) ...[
                  Text(
                    'quizzes'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...currentCourse!.quizzes.map((quiz) => _buildQuizItem(quiz)),
                  const SizedBox(height: 24),
                ],

                // Worksheets Section
                if (currentCourse!.worksheets.isNotEmpty) ...[
                  Text(
                    'course_resources'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...currentCourse!.worksheets.map(
                    (worksheet) => _buildResourceItem(worksheet),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedWorksheetItem(
    dynamic worksheet,
    bool isDownloaded,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getWorksheetIcon(worksheet.fileType ?? 'pdf'),
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            worksheet.title ?? 'Untitled Worksheet',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'completed'.tr,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${worksheet.fileType?.toUpperCase() ?? 'PDF'} • ${worksheet.fileSize ?? 'Unknown size'} • ${worksheet.description ?? 'No description'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (worksheet.uploadedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${'uploaded_on'.tr}: ${_formatDate(worksheet.uploadedAt)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadWorksheet(worksheet),
                  icon: Icon(
                    isDownloaded ? Icons.download_done : Icons.download,
                    size: 16,
                  ),
                  label: Text(isDownloaded ? 'downloaded'.tr : 'download'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDownloaded
                        ? AppTheme.accentColor
                        : AppTheme.primaryColor,
                    side: BorderSide(
                      color: isDownloaded
                          ? AppTheme.accentColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewWorksheet(worksheet),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text('view'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _toggleWorksheetCompletion(worksheet),
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: isCompleted ? AppTheme.accentColor : Colors.grey,
                ),
                tooltip: isCompleted
                    ? 'mark_incomplete'.tr
                    : 'mark_complete'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWorksheetIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'unknown'.tr;
    return '${date.day}/${date.month}/${date.year}';
  }

  void _downloadWorksheet(dynamic worksheet) {
    setState(() {
      worksheetDownloaded[worksheet.id] = true;
    });

    Get.snackbar(
      'download_started'.tr,
      'downloading_worksheet'.tr.replaceAll(
        '{title}',
        worksheet.title ?? 'worksheet',
      ),
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      icon: const Icon(Icons.download, color: Colors.white),
      duration: const Duration(seconds: 2),
    );

    // Simulate download completion after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Get.snackbar(
        'download_complete'.tr,
        'worksheet_downloaded_successfully'.tr,
        backgroundColor: AppTheme.accentColor,
        colorText: Colors.white,
        icon: const Icon(Icons.download_done, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    });
  }

  void _viewWorksheet(dynamic worksheet) {
    Get.snackbar(
      'opening_worksheet'.tr,
      'opening_worksheet_viewer'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      icon: const Icon(Icons.visibility, color: Colors.white),
      duration: const Duration(seconds: 2),
    );

    // TODO: Implement actual worksheet viewer
    // This would typically open a PDF viewer or document viewer
  }

  void _toggleWorksheetCompletion(dynamic worksheet) {
    setState(() {
      worksheetCompleted[worksheet.id] =
          !(worksheetCompleted[worksheet.id] ?? false);
    });

    final isCompleted = worksheetCompleted[worksheet.id] ?? false;
    Get.snackbar(
      isCompleted ? 'worksheet_completed'.tr : 'worksheet_marked_incomplete'.tr,
      isCompleted
          ? 'worksheet_marked_as_completed'.tr
          : 'worksheet_marked_as_incomplete'.tr,
      backgroundColor: isCompleted ? AppTheme.accentColor : Colors.orange,
      colorText: Colors.white,
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.remove_circle,
        color: Colors.white,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  void _showWorksheetUploadDialog() {
    Get.snackbar(
      'feature_coming_soon'.tr,
      'worksheet_upload_instructor_only'.tr,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}
