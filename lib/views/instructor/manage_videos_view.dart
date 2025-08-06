import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_theme.dart';
import '../../controllers/instructor_controller.dart';
import '../../models/video_model.dart';
import '../../models/course_model.dart';
import '../../widgets/instructor/course_selector_widget.dart';
import '../../utils/youtube_utils.dart';

class ManageVideosView extends StatefulWidget {
  const ManageVideosView({super.key});

  @override
  State<ManageVideosView> createState() => _ManageVideosViewState();
}

class _ManageVideosViewState extends State<ManageVideosView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCourseFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorController = Get.find<InstructorController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.video_library,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'video_manager'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'manage_your_videos'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showAddVideoDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
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
              ],
            ),
          ),

          // Course Selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: CourseSelectorWidget(
              title: 'select_course_for_videos'.tr,
              emptyMessage: 'create_course_first_to_add_videos'.tr,
              onCourseSelected: () {
                setState(() {
                  // Refresh the video list when course is selected
                });
              },
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: 'all_videos'.tr),
                Tab(text: 'published'.tr),
                Tab(text: 'drafts'.tr),
              ],
            ),
          ),

          // Video List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoList(instructorController, 'all'),
                _buildVideoList(instructorController, 'published'),
                _buildVideoList(instructorController, 'drafts'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList(InstructorController controller, String filter) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final selectedCourse = controller.currentCourse;

      // If no course is selected, show course selection prompt
      if (selectedCourse == null) {
        return _buildNoCourseSelectedState();
      }

      final List<Map<String, dynamic>> courseVideos = [];

      // Only get videos from the selected course
      for (final video in selectedCourse.videos) {
        courseVideos.add({'video': video, 'course': selectedCourse});
      }

      final filteredVideos = _filterVideos(courseVideos, filter);

      if (filteredVideos.isEmpty) {
        return _buildEmptyState(filter);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredVideos.length,
        itemBuilder: (context, index) {
          final videoData = filteredVideos[index];
          return _buildVideoCard(videoData);
        },
      );
    });
  }

  List<Map<String, dynamic>> _filterVideos(
    List<Map<String, dynamic>> videos,
    String filter,
  ) {
    return videos.where((videoData) {
      final video = videoData['video'] as VideoModel;
      final course = videoData['course'] as CourseModel;

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

      // Status filter (for now, all videos are considered published)
      switch (filter) {
        case 'published':
          return true; // All videos are published for demo
        case 'drafts':
          return false; // No drafts for demo
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildNoCourseSelectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'no_course_selected'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'please_select_course_to_manage_videos'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    IconData icon;

    switch (filter) {
      case 'published':
        message = 'no_published_videos'.tr;
        icon = Icons.video_library;
        break;
      case 'drafts':
        message = 'no_draft_videos'.tr;
        icon = Icons.video_library_outlined;
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddVideoDialog(),
            icon: const Icon(Icons.add),
            label: Text('add_video'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> videoData) {
    final video = videoData['video'] as VideoModel;
    final course = videoData['course'] as CourseModel;

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
          // Video Thumbnail with Play Button
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                // YouTube Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    'https://img.youtube.com/vi/${video.youtubeVideoId}/maxresdefault.jpg',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.video_library,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Play Button Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _playVideo(video),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 32,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Duration Badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(video.durationSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Video Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  video.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editVideo(video),
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text('edit'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewAnalytics(video),
                        icon: const Icon(Icons.analytics, size: 16),
                        label: Text('analytics'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVideoDialog() {
    final instructorController = Get.find<InstructorController>();
    final selectedCourse = instructorController.currentCourse;

    if (selectedCourse == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_course_first'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'info'.tr,
      'add_video_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _playVideo(VideoModel video) {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(Get.context!).size.height * 0.6,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
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
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Video Player
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (!video.hasValidVideoId) {
                      return Center(
                        child: Text(
                          'invalid_video_id'.tr,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final videoId = video.bestVideoId;
                    final embedUrl =
                        'https://www.youtube.com/embed/$videoId?autoplay=0&controls=1&rel=0&showinfo=0&modestbranding=1';

                    final webViewController = WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setUserAgent(
                        'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
                      )
                      ..setNavigationDelegate(
                        NavigationDelegate(
                          onWebResourceError: (WebResourceError error) {
                            Get.snackbar(
                              'error'.tr,
                              'failed_to_load_video'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          onNavigationRequest: (NavigationRequest request) {
                            // Allow YouTube domains
                            if (request.url.contains('youtube.com') ||
                                request.url.contains('youtu.be') ||
                                request.url.contains('googlevideo.com')) {
                              return NavigationDecision.navigate;
                            }
                            return NavigationDecision.prevent;
                          },
                        ),
                      )
                      ..loadRequest(Uri.parse(embedUrl));

                    return WebViewWidget(controller: webViewController);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editVideo(VideoModel video) {
    Get.snackbar(
      'info'.tr,
      'edit_video_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _viewAnalytics(VideoModel video) {
    Get.snackbar(
      'info'.tr,
      'video_analytics_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
