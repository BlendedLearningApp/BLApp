import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../models/video_model.dart';
import '../../models/course_model.dart';
import '../../widgets/admin/video_review_player.dart';

class AdminVideoManagementView extends StatefulWidget {
  const AdminVideoManagementView({super.key});

  @override
  State<AdminVideoManagementView> createState() =>
      _AdminVideoManagementViewState();
}

class _AdminVideoManagementViewState extends State<AdminVideoManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCourseFilter = 'all';
  String _selectedInstructorFilter = 'all';
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('video_management'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'all_videos'.tr),
            Tab(text: 'pending'.tr),
            Tab(text: 'approved'.tr),
            Tab(text: 'rejected'.tr),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Section
          _buildSearchSection(),

          // Videos List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideosList(adminController, 'all'),
                _buildVideosList(adminController, 'pending'),
                _buildVideosList(adminController, 'approved'),
                _buildVideosList(adminController, 'rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'search_videos'.tr,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildVideosList(AdminController controller, String status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final allVideos = _getAllVideos(controller);
      final filteredVideos = _filterVideos(allVideos, status);

      if (filteredVideos.isEmpty) {
        return _buildEmptyState(status);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredVideos.length,
        itemBuilder: (context, index) {
          final videoData = filteredVideos[index];
          return _buildVideoCard(videoData, status);
        },
      );
    });
  }

  List<Map<String, dynamic>> _getAllVideos(AdminController controller) {
    final List<Map<String, dynamic>> allVideos = [];

    for (final course in controller.allCourses) {
      for (final video in course.videos) {
        allVideos.add({
          'video': video,
          'course': course,
          'status': course.isApproved ? 'approved' : 'pending',
        });
      }
    }

    return allVideos;
  }

  List<Map<String, dynamic>> _filterVideos(
    List<Map<String, dynamic>> videos,
    String status,
  ) {
    return videos.where((videoData) {
      final video = videoData['video'] as VideoModel;
      final course = videoData['course'] as CourseModel;
      final videoStatus = videoData['status'] as String;

      // Status filter
      if (status != 'all' && videoStatus != status) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchMatch =
            video.title.toLowerCase().contains(_searchQuery) ||
            video.description.toLowerCase().contains(_searchQuery) ||
            course.title.toLowerCase().contains(_searchQuery);
        if (!searchMatch) return false;
      }

      // Course filter
      if (_selectedCourseFilter != 'all' && course.id != _selectedCourseFilter)
        return false;

      // Instructor filter
      if (_selectedInstructorFilter != 'all' &&
          course.instructorId != _selectedInstructorFilter)
        return false;

      return true;
    }).toList();
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'pending':
        message = 'no_pending_videos'.tr;
        icon = Icons.pending;
        break;
      case 'approved':
        message = 'no_approved_videos'.tr;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        message = 'no_rejected_videos'.tr;
        icon = Icons.cancel;
        break;
      default:
        message = 'no_videos_found'.tr;
        icon = Icons.video_library;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> videoData, String status) {
    final video = videoData['video'] as VideoModel;
    final course = videoData['course'] as CourseModel;
    final videoStatus = videoData['status'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with video thumbnail and status
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                  AppTheme.secondaryColor.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Video thumbnail placeholder
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Content overlay
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildVideoStatusBadge(videoStatus),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video description
                Text(
                  video.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Video stats
                Row(
                  children: [
                    _buildVideoStatItem(
                      Icons.access_time,
                      _formatDuration(video.durationSeconds),
                    ),
                    const SizedBox(width: 16),
                    _buildVideoStatItem(Icons.person, course.instructorName),
                    const SizedBox(width: 16),
                    _buildVideoStatItem(
                      Icons.calendar_today,
                      _formatDate(video.createdAt),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                _buildVideoActionButtons(video, course, videoStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange;
        icon = Icons.schedule;
        text = 'pending'.tr;
        break;
      case 'approved':
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green;
        icon = Icons.check_circle;
        text = 'approved'.tr;
        break;
      case 'rejected':
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red;
        icon = Icons.cancel;
        text = 'rejected'.tr;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey;
        icon = Icons.help;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryColor),
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

  Widget _buildVideoActionButtons(
    VideoModel video,
    CourseModel course,
    String status,
  ) {
    final adminController = Get.find<AdminController>();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _previewVideo(video),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text('preview'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (status == 'pending') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => adminController.approveVideo(video.id),
              icon: const Icon(Icons.check, size: 18),
              label: Text('approve'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => adminController.rejectVideo(video.id),
              icon: const Icon(Icons.close, size: 18),
              label: Text('reject'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmation(video, adminController),
              icon: const Icon(Icons.delete, size: 18),
              label: Text('delete'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _previewVideo(VideoModel video) {
    // Use the new VideoReviewPlayer widget based on official implementation
    Get.dialog(
      VideoReviewPlayer(
        video: video,
        onApprove: () {
          // Refresh the video list after approval
          setState(() {});
        },
        onReject: () {
          // Refresh the video list after rejection
          setState(() {});
        },
      ),
    );
  }

  void _showDeleteConfirmation(VideoModel video, AdminController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text('${'delete_video_confirmation'.tr}: ${video.title}'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteVideo(video.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final adminController = Get.find<AdminController>();

    Get.dialog(
      AlertDialog(
        title: Text('filter_videos'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Course filter
            DropdownButtonFormField<String>(
              value: _selectedCourseFilter,
              decoration: InputDecoration(labelText: 'filter_by_course'.tr),
              items: [
                DropdownMenuItem(value: 'all', child: Text('all_courses'.tr)),
                ...adminController.allCourses.map(
                  (course) => DropdownMenuItem(
                    value: course.id,
                    child: Text(course.title),
                  ),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedCourseFilter = value!),
            ),
            const SizedBox(height: 16),
            // Instructor filter
            DropdownButtonFormField<String>(
              value: _selectedInstructorFilter,
              decoration: InputDecoration(labelText: 'filter_by_instructor'.tr),
              items: [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('all_instructors'.tr),
                ),
                ...adminController.allCourses
                    .map((course) => course.instructorId)
                    .toSet()
                    .map((instructorId) {
                      final course = adminController.allCourses.firstWhere(
                        (c) => c.instructorId == instructorId,
                      );
                      return DropdownMenuItem(
                        value: instructorId,
                        child: Text(course.instructorName),
                      );
                    }),
              ],
              onChanged: (value) =>
                  setState(() => _selectedInstructorFilter = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCourseFilter = 'all';
                _selectedInstructorFilter = 'all';
              });
              Get.back();
            },
            child: Text('clear_filters'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('apply_filters'.tr),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
