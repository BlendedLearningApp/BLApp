import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/instructor_controller.dart';
import '../../models/quiz_model.dart';
import '../../models/course_model.dart';
import '../../widgets/instructor/course_selector_widget.dart';

class InstructorQuizManagerView extends StatefulWidget {
  const InstructorQuizManagerView({super.key});

  @override
  State<InstructorQuizManagerView> createState() =>
      _InstructorQuizManagerViewState();
}

class _InstructorQuizManagerViewState extends State<InstructorQuizManagerView>
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
                        Icons.quiz,
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
                            'quiz_manager'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'manage_your_quizzes'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showCreateQuizDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search_quizzes'.tr,
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
              title: 'select_course_for_quizzes'.tr,
              emptyMessage: 'create_course_first_to_add_quizzes'.tr,
              onCourseSelected: () {
                setState(() {
                  // Refresh the quiz list when course is selected
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
                Tab(text: 'all_quizzes'.tr),
                Tab(text: 'published'.tr),
                Tab(text: 'drafts'.tr),
              ],
            ),
          ),

          // Quiz List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuizList(instructorController, 'all'),
                _buildQuizList(instructorController, 'published'),
                _buildQuizList(instructorController, 'drafts'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList(InstructorController controller, String filter) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final selectedCourse = controller.currentCourse;

      // If no course is selected, show course selection prompt
      if (selectedCourse == null) {
        return _buildNoCourseSelectedState();
      }

      final List<Map<String, dynamic>> courseQuizzes = [];

      // Only get quizzes from the selected course
      for (final quiz in selectedCourse.quizzes) {
        courseQuizzes.add({'quiz': quiz, 'course': selectedCourse});
      }

      final filteredQuizzes = _filterQuizzes(courseQuizzes, filter);

      if (filteredQuizzes.isEmpty) {
        return _buildEmptyState(filter);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quizData = filteredQuizzes[index];
          return _buildQuizCard(quizData);
        },
      );
    });
  }

  List<Map<String, dynamic>> _filterQuizzes(
    List<Map<String, dynamic>> quizzes,
    String filter,
  ) {
    return quizzes.where((quizData) {
      final quiz = quizData['quiz'] as QuizModel;
      final course = quizData['course'] as CourseModel;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchMatch =
            quiz.title.toLowerCase().contains(_searchQuery) ||
            quiz.description.toLowerCase().contains(_searchQuery) ||
            course.title.toLowerCase().contains(_searchQuery);
        if (!searchMatch) return false;
      }

      // Course filter
      if (_selectedCourseFilter != 'all' && course.id != _selectedCourseFilter)
        return false;

      // Status filter
      switch (filter) {
        case 'published':
          return quiz.isActive;
        case 'drafts':
          return !quiz.isActive;
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
            'please_select_course_to_manage_quizzes'.tr,
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
        message = 'no_published_quizzes'.tr;
        icon = Icons.quiz;
        break;
      case 'drafts':
        message = 'no_draft_quizzes'.tr;
        icon = Icons.edit_note;
        break;
      default:
        message = 'no_quizzes_found'.tr;
        icon = Icons.quiz;
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
            onPressed: () => _showCreateQuizDialog(),
            icon: const Icon(Icons.add),
            label: Text('create_quiz'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quizData) {
    final quiz = quizData['quiz'] as QuizModel;
    final course = quizData['course'] as CourseModel;

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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
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
                  AppTheme.accentColor.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.quiz, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                _buildQuizStatusBadge(quiz.isActive),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Quiz Stats
                Row(
                  children: [
                    _buildStatItem(
                      Icons.help_outline,
                      '${quiz.questions.length}',
                      'questions'.tr,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.timer, '${quiz.timeLimit}', 'min'.tr),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.grade,
                      '${quiz.passingScore}%',
                      'pass'.tr,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editQuiz(quiz),
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
                        onPressed: () => _viewQuizResults(quiz),
                        icon: const Icon(Icons.analytics, size: 16),
                        label: Text('results'.tr),
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

  Widget _buildQuizStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'published'.tr : 'draft'.tr,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
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

  void _showCreateQuizDialog() {
    Get.snackbar(
      'info'.tr,
      'create_quiz_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _editQuiz(QuizModel quiz) {
    Get.snackbar(
      'info'.tr,
      'edit_quiz_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _viewQuizResults(QuizModel quiz) {
    Get.snackbar(
      'info'.tr,
      'quiz_results_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
