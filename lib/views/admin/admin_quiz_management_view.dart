import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../models/quiz_model.dart';
import '../../models/course_model.dart';

class AdminQuizManagementView extends StatefulWidget {
  const AdminQuizManagementView({super.key});

  @override
  State<AdminQuizManagementView> createState() =>
      _AdminQuizManagementViewState();
}

class _AdminQuizManagementViewState extends State<AdminQuizManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCourseFilter = 'all';
  String _selectedInstructorFilter = 'all';
  String _selectedDifficultyFilter = 'all';

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
        title: Text('quiz_management'.tr),
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
            Tab(text: 'all_quizzes'.tr),
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

          // Quizzes List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuizzesList(adminController, 'all'),
                _buildQuizzesList(adminController, 'pending'),
                _buildQuizzesList(adminController, 'approved'),
                _buildQuizzesList(adminController, 'rejected'),
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
    );
  }

  Widget _buildQuizzesList(AdminController controller, String status) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final allQuizzes = _getAllQuizzes(controller);
      final filteredQuizzes = _filterQuizzes(allQuizzes, status);

      if (filteredQuizzes.isEmpty) {
        return _buildEmptyState(status);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quizData = filteredQuizzes[index];
          return _buildQuizCard(quizData, status);
        },
      );
    });
  }

  List<Map<String, dynamic>> _getAllQuizzes(AdminController controller) {
    final List<Map<String, dynamic>> allQuizzes = [];

    for (final course in controller.allCourses) {
      for (final quiz in course.quizzes) {
        allQuizzes.add({
          'quiz': quiz,
          'course': course,
          'status': course.isApproved ? 'approved' : 'pending',
        });
      }
    }

    return allQuizzes;
  }

  List<Map<String, dynamic>> _filterQuizzes(
    List<Map<String, dynamic>> quizzes,
    String status,
  ) {
    return quizzes.where((quizData) {
      final quiz = quizData['quiz'] as QuizModel;
      final course = quizData['course'] as CourseModel;
      final quizStatus = quizData['status'] as String;

      // Status filter
      if (status != 'all' && quizStatus != status) return false;

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

      // Instructor filter
      if (_selectedInstructorFilter != 'all' &&
          course.instructorId != _selectedInstructorFilter)
        return false;

      // Difficulty filter (based on question count)
      if (_selectedDifficultyFilter != 'all') {
        final difficulty = _getQuizDifficulty(quiz);
        if (difficulty != _selectedDifficultyFilter) return false;
      }

      return true;
    }).toList();
  }

  String _getQuizDifficulty(QuizModel quiz) {
    final questionCount = quiz.questions.length;
    if (questionCount <= 5) return 'easy';
    if (questionCount <= 10) return 'medium';
    return 'hard';
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status) {
      case 'pending':
        message = 'no_pending_quizzes'.tr;
        icon = Icons.pending;
        break;
      case 'approved':
        message = 'no_approved_quizzes'.tr;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        message = 'no_rejected_quizzes'.tr;
        icon = Icons.cancel;
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
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quizData, String status) {
    final quiz = quizData['quiz'] as QuizModel;
    final course = quizData['course'] as CourseModel;
    final quizStatus = quizData['status'] as String;

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
          // Header with quiz info and status
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
                  AppTheme.secondaryColor.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.quiz, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
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
                        course.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildQuizStatusBadge(quizStatus),
              ],
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quiz description
                Text(
                  quiz.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Quiz stats
                Row(
                  children: [
                    _buildQuizStatItem(
                      Icons.help_outline,
                      '${quiz.questions.length}',
                      'questions'.tr,
                    ),
                    const SizedBox(width: 16),
                    _buildQuizStatItem(
                      Icons.timer,
                      '${quiz.timeLimit}',
                      'minutes'.tr,
                    ),
                    const SizedBox(width: 16),
                    _buildQuizStatItem(
                      Icons.grade,
                      '${quiz.passingScore}%',
                      'passing'.tr,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Difficulty badge
                Row(
                  children: [
                    _buildDifficultyBadge(_getQuizDifficulty(quiz)),
                    const Spacer(),
                    Text(
                      _formatDate(quiz.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                _buildQuizActionButtons(quiz, course, quizStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizStatusBadge(String status) {
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

  Widget _buildQuizStatItem(IconData icon, String value, String label) {
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

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        difficulty.tr,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuizActionButtons(
    QuizModel quiz,
    CourseModel course,
    String status,
  ) {
    final adminController = Get.find<AdminController>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _previewQuiz(quiz),
                icon: const Icon(Icons.visibility, size: 18),
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
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _editQuizSettings(quiz),
                icon: const Icon(Icons.edit, size: 18),
                label: Text('edit_settings'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.secondaryColor,
                  side: const BorderSide(color: AppTheme.secondaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (status == 'pending') ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => adminController.approveQuiz(quiz.id),
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
                  onPressed: () => adminController.rejectQuiz(quiz.id),
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
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewQuizStatistics(quiz),
                  icon: const Icon(Icons.analytics, size: 18),
                  label: Text('view_stats'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
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
                  onPressed: () =>
                      _showDeleteConfirmation(quiz, adminController),
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
          ),
        ],
      ],
    );
  }

  void _previewQuiz(QuizModel quiz) {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(Get.context!).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                quiz.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    final question = quiz.questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'question'.tr} ${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.question,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...question.options.asMap().entries.map((entry) {
                              final optionIndex = entry.key;
                              final option = entry.value;
                              final isCorrect =
                                  optionIndex == question.correctAnswerIndex;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.grey.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${String.fromCharCode(65 + optionIndex)}. ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isCorrect
                                            ? Colors.green
                                            : AppTheme.textColor,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: isCorrect
                                              ? Colors.green
                                              : AppTheme.textColor,
                                        ),
                                      ),
                                    ),
                                    if (isCorrect)
                                      const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editQuizSettings(QuizModel quiz) {
    // TODO: Implement quiz settings editor
    Get.snackbar(
      'info'.tr,
      'quiz_settings_editor_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _viewQuizStatistics(QuizModel quiz) {
    // TODO: Implement quiz statistics view
    Get.snackbar(
      'info'.tr,
      'quiz_statistics_coming_soon'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showDeleteConfirmation(QuizModel quiz, AdminController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text('${'delete_quiz_confirmation'.tr}: ${quiz.title}'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteQuiz(quiz.id);
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
        title: Text('filter_quizzes'.tr),
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
            const SizedBox(height: 16),
            // Difficulty filter
            DropdownButtonFormField<String>(
              value: _selectedDifficultyFilter,
              decoration: InputDecoration(labelText: 'filter_by_difficulty'.tr),
              items: [
                DropdownMenuItem(
                  value: 'all',
                  child: Text('all_difficulties'.tr),
                ),
                DropdownMenuItem(value: 'easy', child: Text('easy'.tr)),
                DropdownMenuItem(value: 'medium', child: Text('medium'.tr)),
                DropdownMenuItem(value: 'hard', child: Text('hard'.tr)),
              ],
              onChanged: (value) =>
                  setState(() => _selectedDifficultyFilter = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCourseFilter = 'all';
                _selectedInstructorFilter = 'all';
                _selectedDifficultyFilter = 'all';
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
