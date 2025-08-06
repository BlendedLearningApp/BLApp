import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/instructor_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';
import 'package:blapp/widgets/common/empty_state_widget.dart';

class VideoManagementView extends StatefulWidget {
  const VideoManagementView({super.key});

  @override
  State<VideoManagementView> createState() => _VideoManagementViewState();
}

class _VideoManagementViewState extends State<VideoManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

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
      appBar: AppBar(
        title: Text('video_management'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => instructorController.loadInstructorData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'my_videos'.tr),
            Tab(text: 'upload_video'.tr),
            Tab(text: 'analytics'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyVideosTab(),
          _buildUploadVideoTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }
  
  Widget _buildMyVideosTab() {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.withValues(alpha: 0.05),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_videos'.tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'all_videos'.tr),
                    _buildFilterChip('published', 'published'.tr),
                    _buildFilterChip('draft', 'draft'.tr),
                    _buildFilterChip('processing', 'processing'.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Videos List
        Expanded(
          child: _buildVideosList(),
        ),
      ],
    );
  }
  
  Widget _buildUploadVideoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Area
          CustomCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'drag_drop_video'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'supported_formats'.tr,
                    style: TextStyle(
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _selectVideoFile(),
                    icon: const Icon(Icons.folder_open),
                    label: Text('select_file'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Video Details Form
          Text(
            'video_details'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildVideoDetailsForm(),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'total_views'.tr,
                  '12,345',
                  Icons.play_arrow,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'watch_time'.tr,
                  '1,234h',
                  Icons.access_time,
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'avg_duration'.tr,
                  '15:30',
                  Icons.timer,
                  AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'engagement_rate'.tr,
                  '78%',
                  Icons.thumb_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Top Performing Videos
          Text(
            'top_videos'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildTopVideosList(),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildVideosList() {
    final videos = _getFilteredVideos();
    
    if (videos.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.video_library,
        title: 'no_videos_found'.tr,
        description: 'upload_first_video'.tr,
        actionText: 'upload_video'.tr,
        onActionPressed: () => _tabController.animateTo(1),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(video);
      },
    );
  }
  
  Widget _buildVideoCard(Map<String, dynamic> video) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 120,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                image: video['thumbnail'] != null
                    ? DecorationImage(
                        image: NetworkImage(video['thumbnail']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: video['thumbnail'] == null
                  ? const Icon(
                      Icons.play_circle_outline,
                      size: 32,
                      color: Colors.grey,
                    )
                  : Stack(
                      children: [
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video['duration'] ?? '00:00',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 16),
            // Video Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] ?? 'untitled_video'.tr,
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
                    video['course'] ?? 'no_course'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(video['status'] ?? 'draft'),
                      const Spacer(),
                      Text(
                        '${video['views'] ?? 0} ${'views'.tr}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              onSelected: (action) => _handleVideoAction(action, video),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 16),
                      const SizedBox(width: 8),
                      Text('edit'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'analytics',
                  child: Row(
                    children: [
                      const Icon(Icons.analytics, size: 16),
                      const SizedBox(width: 8),
                      Text('analytics'.tr),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('delete'.tr, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'published':
        color = AppTheme.accentColor;
        text = 'published'.tr;
        break;
      case 'processing':
        color = AppTheme.warningColor;
        text = 'processing'.tr;
        break;
      case 'draft':
      default:
        color = Colors.grey;
        text = 'draft'.tr;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildVideoDetailsForm() {
    return Column(
      children: [
        // Title
        TextField(
          decoration: InputDecoration(
            labelText: 'video_title'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Description
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'video_description'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Course Selection
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'select_course'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'flutter',
              child: Text('Flutter Development'),
            ),
            DropdownMenuItem(
              value: 'ui_ux',
              child: Text('UI/UX Design'),
            ),
          ],
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        // Upload Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _uploadVideo(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('upload_video'.tr),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopVideosList() {
    final topVideos = [
      {
        'title': 'Flutter Widgets Explained',
        'views': 5420,
        'duration': '12:45',
        'engagement': '85%',
      },
      {
        'title': 'State Management with GetX',
        'views': 3890,
        'duration': '18:30',
        'engagement': '78%',
      },
      {
        'title': 'Building Responsive UIs',
        'views': 2156,
        'duration': '15:20',
        'engagement': '72%',
      },
    ];
    
    return CustomCard(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topVideos.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final video = topVideos[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              video['title'] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${video['views']} views • ${video['duration']}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withValues(alpha: 0.7),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                video['engagement'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  List<Map<String, dynamic>> _getFilteredVideos() {
    final allVideos = [
      {
        'title': 'Flutter Widgets Explained',
        'course': 'Flutter Development',
        'status': 'published',
        'views': 5420,
        'duration': '12:45',
        'thumbnail': null,
      },
      {
        'title': 'State Management with GetX',
        'course': 'Flutter Development',
        'status': 'published',
        'views': 3890,
        'duration': '18:30',
        'thumbnail': null,
      },
      {
        'title': 'Building Responsive UIs',
        'course': 'UI/UX Design',
        'status': 'processing',
        'views': 0,
        'duration': '15:20',
        'thumbnail': null,
      },
      {
        'title': 'Advanced Animations',
        'course': 'Flutter Development',
        'status': 'draft',
        'views': 0,
        'duration': '22:15',
        'thumbnail': null,
      },
    ];
    
    var filtered = allVideos.where((video) {
      if (_selectedFilter != 'all' && video['status'] != _selectedFilter) {
        return false;
      }
      
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final title = (video['title'] as String).toLowerCase();
        final course = (video['course'] as String).toLowerCase();
        return title.contains(query) || course.contains(query);
      }
      
      return true;
    }).toList();
    
    return filtered;
  }
  
  void _selectVideoFile() {
    // Mock file selection
    Get.snackbar(
      'file_selected'.tr,
      'video_file_selected'.tr,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }
  
  void _uploadVideo() {
    // Mock video upload
    Get.snackbar(
      'upload_started'.tr,
      'video_upload_progress'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }
  
  void _handleVideoAction(String action, Map<String, dynamic> video) {
    switch (action) {
      case 'edit':
        Get.snackbar(
          'edit_video'.tr,
          'editing_video'.tr.replaceAll('{title}', video['title']),
          backgroundColor: AppTheme.primaryColor,
          colorText: Colors.white,
        );
        break;
      case 'analytics':
        Get.snackbar(
          'video_analytics'.tr,
          'viewing_analytics'.tr.replaceAll('{title}', video['title']),
          backgroundColor: AppTheme.accentColor,
          colorText: Colors.white,
        );
        break;
      case 'delete':
        _showDeleteConfirmation(video);
        break;
    }
  }
  
  void _showDeleteConfirmation(Map<String, dynamic> video) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_video'.tr),
        content: Text(
          'delete_video_confirmation'.tr.replaceAll('{title}', video['title']),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'video_deleted'.tr,
                'video_deleted_success'.tr,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
