import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/instructor_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';
import 'package:blapp/widgets/common/loading_widget.dart';
import 'package:blapp/widgets/common/empty_state_widget.dart';

class StudentSubmissionsView extends StatefulWidget {
  const StudentSubmissionsView({super.key});

  @override
  State<StudentSubmissionsView> createState() => _StudentSubmissionsViewState();
}

class _StudentSubmissionsViewState extends State<StudentSubmissionsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    final instructorController = Get.find<InstructorController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('student_submissions'.tr),
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
            onPressed: () => instructorController.loadInstructorData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: 'all_submissions'.tr),
            Tab(text: 'pending_review'.tr),
            Tab(text: 'graded'.tr),
            Tab(text: 'late_submissions'.tr),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Section
          _buildSearchSection(),

          // Submissions List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubmissionsList(instructorController, 'all'),
                _buildSubmissionsList(instructorController, 'pending'),
                _buildSubmissionsList(instructorController, 'graded'),
                _buildSubmissionsList(instructorController, 'late'),
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
      color: Colors.grey.withValues(alpha: 0.1),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'search_submissions'.tr,
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
    );
  }

  Widget _buildSubmissionsList(InstructorController controller, String filter) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      // Mock submissions data
      final submissions = _getFilteredSubmissions(filter);

      if (submissions.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.assignment_outlined,
          title: 'No Submissions Found',
          description: _getEmptyStateMessage(filter),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final submission = submissions[index];
          return _buildSubmissionCard(submission);
        },
      );
    });
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    final isLate = submission['isLate'] as bool;
    final isGraded = submission['grade'] != null;
    final status = submission['status'] as String;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Student Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    submission['studentName']
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission['studentName'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Text(
                        submission['courseName'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                _buildStatusBadge(status, isLate),
              ],
            ),
            const SizedBox(height: 12),

            // Assignment Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          submission['assignmentTitle'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        'Submitted: ${submission['submittedAt']}',
                      ),
                      if (submission['dueDate'] != null)
                        _buildInfoChip(
                          Icons.schedule,
                          'Due: ${submission['dueDate']}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Grade Section
            if (isGraded) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.grade,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Grade: ${submission['grade']}/${submission['maxGrade']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const Spacer(),
                    if (submission['feedback'] != null)
                      const Icon(
                        Icons.comment,
                        color: AppTheme.accentColor,
                        size: 16,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons - Responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                // Use column layout on very small screens
                if (constraints.maxWidth < 400) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _viewSubmission(submission),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: Text('view_submission'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _gradeSubmission(submission),
                          icon: Icon(
                            isGraded ? Icons.edit : Icons.grade,
                            size: 18,
                          ),
                          label: Text(isGraded ? 'edit_grade'.tr : 'grade'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isGraded
                                ? AppTheme.warningColor
                                : AppTheme.accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _viewSubmission(submission),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: Text('view_submission'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _gradeSubmission(submission),
                          icon: Icon(
                            isGraded ? Icons.edit : Icons.grade,
                            size: 18,
                          ),
                          label: Text(isGraded ? 'edit_grade'.tr : 'grade'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isGraded
                                ? AppTheme.warningColor
                                : AppTheme.accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isLate) {
    Color color;
    String text;

    if (isLate) {
      color = Colors.red;
      text = 'Late';
    } else {
      switch (status.toLowerCase()) {
        case 'pending':
          color = AppTheme.warningColor;
          text = 'Pending';
          break;
        case 'graded':
          color = AppTheme.accentColor;
          text = 'Graded';
          break;
        case 'reviewed':
          color = AppTheme.primaryColor;
          text = 'Reviewed';
          break;
        default:
          color = Colors.grey;
          text = status;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.textColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredSubmissions(String filter) {
    // Mock submissions data
    final allSubmissions = [
      {
        'id': '1',
        'studentName': 'Ahmed Ali',
        'courseName': 'Flutter Development',
        'assignmentTitle': 'Build a Todo App',
        'submittedAt': '2 hours ago',
        'dueDate': 'Today 11:59 PM',
        'status': 'pending',
        'isLate': false,
        'grade': null,
        'maxGrade': 100,
        'feedback': null,
      },
      {
        'id': '2',
        'studentName': 'Sara Mohammed',
        'courseName': 'UI/UX Design',
        'assignmentTitle': 'Design System Project',
        'submittedAt': '1 day ago',
        'dueDate': 'Yesterday 11:59 PM',
        'status': 'graded',
        'isLate': true,
        'grade': 85,
        'maxGrade': 100,
        'feedback': 'Great work on the color palette!',
      },
      {
        'id': '3',
        'studentName': 'Omar Hassan',
        'courseName': 'React Native',
        'assignmentTitle': 'Navigation Implementation',
        'submittedAt': '3 days ago',
        'dueDate': '4 days ago',
        'status': 'graded',
        'isLate': false,
        'grade': 92,
        'maxGrade': 100,
        'feedback': 'Excellent implementation!',
      },
      {
        'id': '4',
        'studentName': 'Fatima Al-Zahra',
        'courseName': 'Flutter Development',
        'assignmentTitle': 'State Management Quiz',
        'submittedAt': '5 hours ago',
        'dueDate': 'Tomorrow 11:59 PM',
        'status': 'pending',
        'isLate': false,
        'grade': null,
        'maxGrade': 50,
        'feedback': null,
      },
      {
        'id': '5',
        'studentName': 'Khalid Ibrahim',
        'courseName': 'Web Development',
        'assignmentTitle': 'Responsive Layout',
        'submittedAt': '2 days ago',
        'dueDate': '1 day ago',
        'status': 'pending',
        'isLate': true,
        'grade': null,
        'maxGrade': 75,
        'feedback': null,
      },
    ];

    var filtered = allSubmissions.where((submission) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return submission['studentName'].toString().toLowerCase().contains(
              query,
            ) ||
            submission['courseName'].toString().toLowerCase().contains(query) ||
            submission['assignmentTitle'].toString().toLowerCase().contains(
              query,
            );
      }
      return true;
    }).toList();

    // Apply tab filter
    switch (filter) {
      case 'pending':
        filtered = filtered.where((s) => s['status'] == 'pending').toList();
        break;
      case 'graded':
        filtered = filtered.where((s) => s['status'] == 'graded').toList();
        break;
      case 'late':
        filtered = filtered.where((s) => s['isLate'] == true).toList();
        break;
      // 'all' shows everything
    }

    return filtered;
  }

  String _getEmptyStateMessage(String filter) {
    switch (filter) {
      case 'pending':
        return 'No pending submissions to review';
      case 'graded':
        return 'No graded submissions found';
      case 'late':
        return 'No late submissions found';
      default:
        return 'No submissions found';
    }
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('filter_submissions'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Course filter would go here
            Text('Advanced filters will be implemented'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('close'.tr)),
        ],
      ),
    );
  }

  void _viewSubmission(Map<String, dynamic> submission) {
    Get.snackbar(
      'info'.tr,
      'Viewing submission by ${submission['studentName']}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _gradeSubmission(Map<String, dynamic> submission) {
    final isGraded = submission['grade'] != null;

    Get.dialog(
      AlertDialog(
        title: Text(isGraded ? 'edit_grade'.tr : 'grade_submission'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${submission['studentName']}'),
            Text('Assignment: ${submission['assignmentTitle']}'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Grade (out of ${submission['maxGrade']})',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Feedback (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'success'.tr,
                'Grade ${isGraded ? "updated" : "submitted"} for ${submission['studentName']}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text(isGraded ? 'update_grade'.tr : 'submit_grade'.tr),
          ),
        ],
      ),
    );
  }
}
