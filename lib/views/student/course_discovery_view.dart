import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/course_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';

class CourseDiscoveryView extends StatefulWidget {
  const CourseDiscoveryView({super.key});

  @override
  State<CourseDiscoveryView> createState() => _CourseDiscoveryViewState();
}

class _CourseDiscoveryViewState extends State<CourseDiscoveryView> {
  final StudentController controller = Get.find<StudentController>();
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _searchController = TextEditingController();
  final RxList<CourseModel> _availableCourses = <CourseModel>[].obs;
  final RxList<CourseModel> _filteredCourses = <CourseModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedCategory = 'all'.obs;
  final RxString _selectedDifficulty = 'all'.obs;
  final RxString _sortBy = 'newest'.obs;

  final List<String> categories = [
    'all',
    'Programming',
    'Design',
    'Marketing',
    'Business',
    'Science',
    'Language',
    'Mathematics',
  ];

  final List<String> difficulties = [
    'all',
    'beginner',
    'intermediate',
    'advanced',
  ];
  final List<String> sortOptions = ['newest', 'oldest', 'rating', 'enrolled'];

  @override
  void initState() {
    super.initState();
    _loadAvailableCourses();
    _searchController.addListener(_filterCourses);

    // Ensure enrolled courses are loaded for enrollment status checking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadStudentData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableCourses() async {
    try {
      _isLoading.value = true;

      // Try to load from Supabase first
      List<CourseModel> courses;
      try {
        courses = await SupabaseService.getApprovedCourses();
        if (courses.isEmpty) {
          // If no courses in database, show mock data for testing
          print('No courses found in database, showing mock data for testing');
          courses = _createMockCourses();
        }
      } catch (e) {
        // If error loading from database, show mock data for testing
        print(
          'Error loading courses from database, showing mock data for testing: $e',
        );
        courses = _createMockCourses();
      }

      // Filter out already enrolled courses
      final enrolledCourseIds = controller.enrolledCourses
          .map((c) => c.id)
          .toSet();
      final availableCourses = courses
          .where((course) => !enrolledCourseIds.contains(course.id))
          .toList();

      _availableCourses.assignAll(availableCourses);
      _filteredCourses.assignAll(availableCourses);
    } catch (e) {
      _showErrorWithRetry(
        'error_loading_courses'.tr,
        () => _loadAvailableCourses(),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  List<CourseModel> _createMockCourses() {
    return [
      CourseModel(
        id: 'mock-1',
        title: 'Flutter Development Basics',
        description:
            'Learn the fundamentals of Flutter app development with hands-on projects and real-world examples.',
        category: 'Programming',
        instructorId: 'instructor-1',
        instructorName: 'John Smith',
        isApproved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        enrolledStudents: 45,
        rating: 4.8,
        videos: [],
        quizzes: [],
        worksheets: [],
      ),
      CourseModel(
        id: 'mock-2',
        title: 'UI/UX Design Principles',
        description:
            'Master the art of creating beautiful and user-friendly interfaces with modern design principles.',
        category: 'Design',
        instructorId: 'instructor-2',
        instructorName: 'Sarah Johnson',
        isApproved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        enrolledStudents: 32,
        rating: 4.6,
        videos: [],
        quizzes: [],
        worksheets: [],
      ),
      CourseModel(
        id: 'mock-3',
        title: 'Digital Marketing Strategy',
        description:
            'Build effective marketing campaigns and grow your online presence with proven strategies.',
        category: 'Marketing',
        instructorId: 'instructor-3',
        instructorName: 'Mike Davis',
        isApproved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        enrolledStudents: 28,
        rating: 4.5,
        videos: [],
        quizzes: [],
        worksheets: [],
      ),
    ];
  }

  void _showErrorWithRetry(String message, VoidCallback retryAction) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          retryAction();
        },
        child: Text(
          'retry'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _filterCourses() {
    var filtered = _availableCourses.where((course) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!course.title.toLowerCase().contains(query) &&
            !course.description.toLowerCase().contains(query) &&
            !course.instructorName.toLowerCase().contains(query) &&
            !course.category.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory.value != 'all' &&
          course.category != _selectedCategory.value) {
        return false;
      }

      return true;
    }).toList();

    // Sort courses
    switch (_sortBy.value) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'enrolled':
        filtered.sort(
          (a, b) => b.enrolledStudents.compareTo(a.enrolledStudents),
        );
        break;
    }

    _filteredCourses.assignAll(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('discover_courses'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_filteredCourses.isEmpty) {
                return _buildEmptyState();
              }

              return _buildCourseGrid();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'search_courses'.tr,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('category'.tr, _selectedCategory, categories),
                const SizedBox(width: 12),
                _buildFilterChip('sort_by'.tr, _sortBy, sortOptions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    RxString selectedValue,
    List<String> options,
  ) {
    return Obx(
      () => PopupMenuButton<String>(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label: ${selectedValue.value.tr}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ],
          ),
        ),
        onSelected: (value) {
          selectedValue.value = value;
          _filterCourses();
        },
        itemBuilder: (context) => options
            .map(
              (option) => PopupMenuItem(value: option, child: Text(option.tr)),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'no_courses_found'.tr,
      description: 'try_different_search'.tr,
      actionText: 'clear_filters'.tr,
      onActionPressed: () {
        _searchController.clear();
        _selectedCategory.value = 'all';
        _selectedDifficulty.value = 'all';
        _sortBy.value = 'newest';
        _filterCourses();
      },
    );
  }

  Widget _buildCourseGrid() {
    return RefreshIndicator(
      onRefresh: _loadAvailableCourses,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredCourses.length,
        itemBuilder: (context, index) {
          final course = _filteredCourses[index];
          return _buildCourseCard(course);
        },
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showCourseDetails(course),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: course.thumbnail != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        course.thumbnail!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.school,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    ),
            ),

            // Course Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: AppTheme.textColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.enrolledStudents}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor.withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),
                        if (course.rating > 0) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseDetails(CourseModel course) {
    // Check if student is already enrolled in this course
    final isEnrolled = controller.enrolledCourses.any((c) => c.id == course.id);

    // Use post-frame callback to prevent visitChildElements error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEnrolled) {
        // Navigate directly to course content
        Get.toNamed('/student/course/${course.id}');
      } else {
        // Navigate to course preview for enrollment
        Get.toNamed('/student/course-preview', arguments: course.id);
      }
    });
  }
}
