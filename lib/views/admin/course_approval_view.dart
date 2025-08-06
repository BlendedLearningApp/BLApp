import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/admin_controller.dart';
import 'package:blapp/widgets/common/loading_widget.dart';
import 'package:blapp/widgets/common/empty_state_widget.dart';
import 'package:blapp/models/course_model.dart';
import 'package:blapp/models/video_model.dart';
import 'package:blapp/widgets/admin/video_review_player.dart';

class CourseApprovalView extends StatefulWidget {
  const CourseApprovalView({super.key});

  @override
  State<CourseApprovalView> createState() => _CourseApprovalViewState();
}

class _CourseApprovalViewState extends State<CourseApprovalView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryFilter = 'all';

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
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('course_approval'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.loadAdminData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'pending_approval'.tr),
            Tab(text: 'approved_courses'.tr),
            Tab(text: 'rejected_courses'.tr),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Stats Section
          _buildSearchAndStatsSection(adminController),

          // Courses List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesList(adminController, 'pending'),
                _buildCoursesList(adminController, 'approved'),
                _buildCoursesList(adminController, 'rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndStatsSection(AdminController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.withValues(alpha: 0.1),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'search_courses'.tr,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Quick Stats
          Builder(
            builder: (context) {
              final pendingCount = _getFilteredCourses(
                controller,
                'pending',
              ).length;
              final approvedCount = _getFilteredCourses(
                controller,
                'approved',
              ).length;
              final rejectedCount = _getFilteredCourses(
                controller,
                'rejected',
              ).length;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'pending_approval'.tr,
                      pendingCount.toString(),
                      AppTheme.warningColor,
                      Icons.pending_actions,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'approved'.tr,
                      approvedCount.toString(),
                      AppTheme.accentColor,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'rejected'.tr,
                      rejectedCount.toString(),
                      Colors.red,
                      Icons.cancel,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
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
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(AdminController controller, String status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      final courses = _getFilteredCourses(controller, status);

      if (courses.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.school_outlined,
          title: 'no_courses_found'.tr,
          description: _getEmptyStateMessage(status),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _buildCourseCard(course, status);
        },
      );
    });
  }

  Widget _buildCourseCard(CourseModel course, String status) {
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
          // Header with thumbnail and status
          Container(
            height: 120,
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
                // Background pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      image: course.thumbnail != null
                          ? DecorationImage(
                              image: NetworkImage(course.thumbnail!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.3),
                                BlendMode.darken,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                // Content overlay
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${'by'.tr} ${course.instructorName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildModernStatusBadge(status),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _buildModernCategoryChip(course.category),
                          const Spacer(),
                          Text(
                            _formatDate(course.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
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
                // Course description
                Text(
                  course.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Course stats
                Row(
                  children: [
                    _buildStatItem(
                      Icons.video_library,
                      '${course.videos.length}',
                      'videos'.tr,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.quiz,
                      '${course.quizzes.length}',
                      'quizzes'.tr,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.description,
                      '${course.worksheets.length}',
                      'worksheets'.tr,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action buttons
                _buildModernActionButtons(course, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = AppTheme.warningColor;
        text = 'pending'.tr;
        icon = Icons.pending;
        break;
      case 'approved':
        color = AppTheme.accentColor;
        text = 'approved'.tr;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'rejected'.tr;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  List<CourseModel> _getFilteredCourses(
    AdminController controller,
    String status,
  ) {
    // Mock course approval data - in real app this would come from controller
    final allCourses = [
      CourseModel(
        id: '1',
        title: 'Advanced Flutter Development',
        description:
            'Learn advanced Flutter concepts including state management, animations, and performance optimization.',
        instructorId: 'instructor_1',
        instructorName: 'Ahmed Hassan',
        thumbnail: null,
        category: 'Technology',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isApproved: status == 'approved',
        enrolledStudents: 0,
        rating: 0.0,
      ),
      CourseModel(
        id: '2',
        title: 'UI/UX Design Fundamentals',
        description:
            'Master the principles of user interface and user experience design with practical projects.',
        instructorId: 'instructor_2',
        instructorName: 'Sara Mohammed',
        thumbnail: null,
        category: 'Design',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isApproved: status == 'approved',
        enrolledStudents: 0,
        rating: 0.0,
      ),
      CourseModel(
        id: '3',
        title: 'Digital Marketing Strategy',
        description:
            'Comprehensive guide to digital marketing including SEO, social media, and content marketing.',
        instructorId: 'instructor_3',
        instructorName: 'Omar Al-Rashid',
        thumbnail: null,
        category: 'Marketing',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isApproved: status == 'approved',
        enrolledStudents: 0,
        rating: 0.0,
      ),
    ];

    var filtered = allCourses.where((course) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return course.title.toLowerCase().contains(query) ||
            course.instructorName.toLowerCase().contains(query) ||
            course.category.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Apply category filter
    if (_selectedCategoryFilter != 'all') {
      filtered = filtered
          .where(
            (course) =>
                course.category.toLowerCase() ==
                _selectedCategoryFilter.toLowerCase(),
          )
          .toList();
    }

    return filtered;
  }

  String _getEmptyStateMessage(String status) {
    switch (status) {
      case 'pending':
        return 'no_pending_courses'.tr;
      case 'approved':
        return 'no_approved_courses'.tr;
      case 'rejected':
        return 'no_rejected_courses'.tr;
      default:
        return 'no_courses_available'.tr;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today'.tr;
    } else if (difference == 1) {
      return 'yesterday'.tr;
    } else if (difference < 7) {
      return '$difference ${'days_ago'.tr}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('filter_courses'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategoryFilter,
              decoration: InputDecoration(
                labelText: 'category'.tr,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('all_categories'.tr),
                ),
                DropdownMenuItem(
                  value: 'technology',
                  child: Text('technology'.tr),
                ),
                DropdownMenuItem(value: 'design', child: Text('design'.tr)),
                DropdownMenuItem(
                  value: 'marketing',
                  child: Text('marketing'.tr),
                ),
                DropdownMenuItem(value: 'business', child: Text('business'.tr)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryFilter = value ?? 'all';
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('close'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() {}); // Refresh the list
            },
            child: Text('apply_filter'.tr),
          ),
        ],
      ),
    );
  }

  void _viewCourseDetails(CourseModel course) {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(Get.context!).size.height * 0.8,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'course_details'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            course.title,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info
                      _buildDetailRow('instructor'.tr, course.instructorName),
                      _buildDetailRow('category'.tr, course.category),
                      _buildDetailRow(
                        'created_at'.tr,
                        _formatDate(course.createdAt),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'description'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(course.description),

                      const SizedBox(height: 24),

                      // Course Content
                      if (course.videos.isNotEmpty) ...[
                        Text(
                          'course_videos'.tr + ' (${course.videos.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...course.videos.map(
                          (video) => _buildVideoPreviewCard(video),
                        ),
                      ],

                      if (course.quizzes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'course_quizzes'.tr + ' (${course.quizzes.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...course.quizzes.map((quiz) => _buildQuizCard(quiz)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _approveCourse(CourseModel course) {
    Get.dialog(
      AlertDialog(
        title: Text('approve_course'.tr),
        content: Text(
          'approve_course_confirmation'.tr.replaceAll('{course}', course.title),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'success'.tr,
                'course_approved_successfully'.tr.replaceAll(
                  '{course}',
                  course.title,
                ),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.accentColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: Text('approve'.tr),
          ),
        ],
      ),
    );
  }

  void _rejectCourse(CourseModel course) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('reject_course'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reject_course_confirmation'.tr.replaceAll(
                '{course}',
                course.title,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'rejection_reason'.tr,
                hintText: 'enter_rejection_reason'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'error'.tr,
                  'rejection_reason_required'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              Get.snackbar(
                'success'.tr,
                'course_rejected_successfully'.tr.replaceAll(
                  '{course}',
                  course.title,
                ),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('reject'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        icon = Icons.schedule;
        text = 'pending'.tr;
        break;
      case 'approved':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        icon = Icons.check_circle;
        text = 'approved'.tr;
        break;
      case 'rejected':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        icon = Icons.cancel;
        text = 'rejected'.tr;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        icon = Icons.help;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        category.tr,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButtons(CourseModel course, String status) {
    return Column(
      children: [
        // Primary action row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewCourseDetails(course),
                icon: const Icon(Icons.visibility, size: 18),
                label: Text('view_details'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),

        if (status == 'pending') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveCourse(course),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text('approve'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectCourse(course),
                  icon: const Icon(Icons.close, size: 18),
                  label: Text('reject'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ] else if (status == 'approved') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectCourse(course),
                  icon: const Icon(Icons.block, size: 18),
                  label: Text('revoke_approval'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ] else if (status == 'rejected') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveCourse(course),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text('approve_now'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreviewCard(VideoModel video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Video thumbnail placeholder
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  video.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(video.durationSeconds),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _previewVideo(video),
            icon: const Icon(Icons.play_arrow, color: AppTheme.primaryColor),
            tooltip: 'preview_video'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.quiz,
              color: AppTheme.accentColor,
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quiz.questions.length} ${'questions'.tr} • ${quiz.timeLimit} ${'minutes'.tr}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _previewVideo(VideoModel video) {
    // Use the new VideoReviewPlayer widget for consistent video preview
    Get.dialog(
      VideoReviewPlayer(
        video: video,
        // No approval/rejection actions in course approval view - just preview
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
