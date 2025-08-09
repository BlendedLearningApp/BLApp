import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/instructor_controller.dart';
import '../../models/course_model.dart';
import '../../models/video_model.dart';
import '../../models/quiz_model.dart';
import '../../widgets/student/video_player_widget.dart';
import '../../services/supabase_service.dart';

class CourseDetailsView extends StatefulWidget {
  final String courseId;

  const CourseDetailsView({super.key, required this.courseId});

  @override
  State<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<CourseDetailsView>
    with SingleTickerProviderStateMixin {
  final InstructorController controller = Get.find<InstructorController>();
  late TabController _tabController;
  CourseModel? course;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCourseDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCourseDetails() {
    // Find course in the controller's courses list
    course = controller.myCourses.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => controller.myCourses.first, // Fallback to first course
    );

    if (course != null) {
      controller.setCurrentCourse(course!);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (course == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('course_details'.tr),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 250,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  course!.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (course!.thumbnail != null)
                        Positioned.fill(
                          child: Image.network(
                            course!.thumbnail!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: course!.isApproved
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course!.isApproved
                                    ? 'published'.tr
                                    : 'draft'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatChip(
                                  Icons.video_library,
                                  course!.videos.length.toString(),
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  Icons.quiz,
                                  course!.quizzes.length.toString(),
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  Icons.people,
                                  course!.enrolledStudents.toString(),
                                ),
                                if (course!.rating > 0) ...[
                                  const SizedBox(width: 8),
                                  _buildStatChip(
                                    Icons.star,
                                    course!.rating.toStringAsFixed(1),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editCourse();
                        break;
                      case 'publish':
                        _togglePublishStatus();
                        break;
                      case 'delete':
                        _deleteCourse();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          Text('edit_course'.tr),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'publish',
                      child: Row(
                        children: [
                          Icon(
                            course!.isApproved
                                ? Icons.unpublished
                                : Icons.publish,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            course!.isApproved ? 'unpublish'.tr : 'publish'.tr,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'delete_course'.tr,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                tabs: [
                  Tab(text: 'overview'.tr),
                  Tab(text: 'videos'.tr),
                  Tab(text: 'quizzes'.tr),
                  Tab(text: 'students'.tr),
                ],
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildVideosTab(),
                  _buildQuizzesTab(),
                  _buildStudentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'description'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course!.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Course Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'course_information'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('category'.tr, course!.category),
                  _buildInfoRow(
                    'created_date'.tr,
                    _formatDate(course!.createdAt),
                  ),
                  if (course!.updatedAt != null)
                    _buildInfoRow(
                      'updated_date'.tr,
                      _formatDate(course!.updatedAt!),
                    ),
                  _buildInfoRow('course_id'.tr, course!.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    return course!.videos.isEmpty
        ? _buildEmptyState(
            'no_videos_yet'.tr,
            'add_videos_to_course'.tr,
            Icons.video_library,
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: course!.videos.length,
            itemBuilder: (context, index) {
              final video = course!.videos[index];
              return _buildVideoCard(video);
            },
          );
  }

  Widget _buildQuizzesTab() {
    return course!.quizzes.isEmpty
        ? _buildEmptyState(
            'no_quizzes_yet'.tr,
            'add_quizzes_to_course'.tr,
            Icons.quiz,
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: course!.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = course!.quizzes[index];
              return _buildQuizCard(quiz);
            },
          );
  }

  Widget _buildStudentsTab() {
    return course!.enrolledStudents == 0
        ? _buildEmptyState(
            'no_students_enrolled'.tr,
            'promote_course_to_get_students'.tr,
            Icons.people,
          )
        : FutureBuilder<List<Map<String, dynamic>>>(
            future: SupabaseService.getEnrolledStudents(course!.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'error_loading_students'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final students = snapshot.data ?? [];

              if (students.isEmpty) {
                return _buildEmptyState(
                  'no_students_enrolled'.tr,
                  'promote_course_to_get_students'.tr,
                  Icons.people,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _buildStudentCard(student);
                },
              );
            },
          );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_arrow, color: AppTheme.accentColor),
        ),
        title: Text(video.title),
        subtitle: Text(video.description),
        trailing: Text('${video.orderIndex}'),
        onTap: () {
          _playVideo(video);
        },
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.quiz, color: AppTheme.primaryColor),
        ),
        title: Text(quiz.title),
        subtitle: Text(quiz.description),
        trailing: Text('${quiz.questions.length} Q'),
        onTap: () {
          // Navigate to quiz management
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editCourse() {
    Get.snackbar('info'.tr, 'edit_course_coming_soon'.tr);
  }

  void _togglePublishStatus() {
    Get.snackbar('info'.tr, 'publish_toggle_coming_soon'.tr);
  }

  void _deleteCourse() {
    Get.dialog(
      AlertDialog(
        title: Text('delete_course'.tr),
        content: Text('delete_course_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('info'.tr, 'delete_course_coming_soon'.tr);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final enrolledDate = DateTime.parse(student['enrolled_at']);
    final progress = (student['progress'] ?? 0.0).toDouble();
    final isCompleted = student['is_completed'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Student Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              backgroundImage: student['student_avatar'] != null
                  ? NetworkImage(student['student_avatar'])
                  : null,
              child: student['student_avatar'] == null
                  ? Text(
                      (student['student_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['student_name'] ?? 'Unknown Student',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['student_email'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'enrolled_on'.tr + ' ${_formatDate(enrolledDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted
                        ? 'completed'.tr
                        : '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.green : AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo(VideoModel video) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(Get.context!).size.height * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Video Player - Using reliable VideoPlayerWidget
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: VideoPlayerWidget(
                    key: ValueKey('instructor_course_detail_video_${video.id}'),
                    video: video,
                    autoPlay: false,
                    showControls: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
