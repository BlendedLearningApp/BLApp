import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/student_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';
import 'package:blapp/widgets/common/empty_state_widget.dart';

class AssignmentsView extends StatefulWidget {
  const AssignmentsView({super.key});

  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

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
    final studentController = Get.find<StudentController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('assignments'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => studentController.loadStudentData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: 'all_assignments'.tr),
            Tab(text: 'pending'.tr),
            Tab(text: 'submitted'.tr),
            Tab(text: 'graded'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllAssignmentsTab(),
          _buildPendingTab(),
          _buildSubmittedTab(),
          _buildGradedTab(),
        ],
      ),
    );
  }
  
  Widget _buildAllAssignmentsTab() {
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
                  hintText: 'search_assignments'.tr,
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
                    _buildFilterChip('all', 'all_courses'.tr),
                    _buildFilterChip('flutter', 'Flutter Development'),
                    _buildFilterChip('ui_ux', 'UI/UX Design'),
                    _buildFilterChip('overdue', 'overdue'.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Assignments List
        Expanded(
          child: _buildAssignmentsList(),
        ),
      ],
    );
  }
  
  Widget _buildPendingTab() {
    return _buildAssignmentsList(status: 'pending');
  }
  
  Widget _buildSubmittedTab() {
    return _buildAssignmentsList(status: 'submitted');
  }
  
  Widget _buildGradedTab() {
    return _buildAssignmentsList(status: 'graded');
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
  
  Widget _buildAssignmentsList({String? status}) {
    final assignments = _getFilteredAssignments(status: status);
    
    if (assignments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.assignment,
        title: 'no_assignments_found'.tr,
        description: status == null 
            ? 'no_assignments_available'.tr
            : 'no_assignments_in_status'.tr.replaceAll('{status}', status),
        actionText: null,
        onActionPressed: null,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }
  
  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final isOverdue = _isOverdue(assignment['dueDate']);
    final status = assignment['status'] as String;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openAssignment(assignment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment['title'] ?? 'untitled_assignment'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  _buildStatusChip(status, isOverdue),
                ],
              ),
              const SizedBox(height: 8),
              
              // Course and Instructor
              Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 16,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    assignment['course'] ?? 'no_course'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.person,
                    size: 16,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    assignment['instructor'] ?? 'unknown'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description
              if (assignment['description'] != null)
                Text(
                  assignment['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                  // Due Date
                  Icon(
                    isOverdue ? Icons.warning : Icons.schedule,
                    size: 16,
                    color: isOverdue ? Colors.red : AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'due'.tr + ': ${_formatDate(assignment['dueDate'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : AppTheme.textColor.withValues(alpha: 0.7),
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  
                  // Points
                  if (assignment['points'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${assignment['points']} ${'points'.tr}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              
              // Grade (if graded)
              if (status == 'graded' && assignment['grade'] != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getGradeColor(assignment['grade']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.grade,
                        size: 16,
                        color: _getGradeColor(assignment['grade']),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'grade'.tr + ': ${assignment['grade']}/${assignment['points']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getGradeColor(assignment['grade']),
                        ),
                      ),
                      if (assignment['feedback'] != null) ...[
                        const Spacer(),
                        Icon(
                          Icons.comment,
                          size: 16,
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status, bool isOverdue) {
    Color color;
    String text;
    
    if (isOverdue && status == 'pending') {
      color = Colors.red;
      text = 'overdue'.tr;
    } else {
      switch (status) {
        case 'pending':
          color = AppTheme.warningColor;
          text = 'pending'.tr;
          break;
        case 'submitted':
          color = AppTheme.primaryColor;
          text = 'submitted'.tr;
          break;
        case 'graded':
          color = AppTheme.accentColor;
          text = 'graded'.tr;
          break;
        default:
          color = Colors.grey;
          text = status;
          break;
      }
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
  
  List<Map<String, dynamic>> _getFilteredAssignments({String? status}) {
    final allAssignments = [
      {
        'id': '1',
        'title': 'Flutter Widget Assignment',
        'description': 'Create a custom widget that demonstrates state management using GetX.',
        'course': 'Flutter Development',
        'instructor': 'Dr. Ahmed Ali',
        'dueDate': DateTime.now().add(const Duration(days: 3)),
        'points': 100,
        'status': 'pending',
      },
      {
        'id': '2',
        'title': 'UI/UX Design Project',
        'description': 'Design a complete mobile app interface with user research and wireframes.',
        'course': 'UI/UX Design',
        'instructor': 'Sara Mohammed',
        'dueDate': DateTime.now().add(const Duration(days: 7)),
        'points': 150,
        'status': 'pending',
      },
      {
        'id': '3',
        'title': 'State Management Quiz',
        'description': 'Complete the quiz on Flutter state management patterns.',
        'course': 'Flutter Development',
        'instructor': 'Dr. Ahmed Ali',
        'dueDate': DateTime.now().subtract(const Duration(days: 1)),
        'points': 50,
        'status': 'submitted',
        'submittedDate': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '4',
        'title': 'Design System Documentation',
        'description': 'Create comprehensive documentation for your design system.',
        'course': 'UI/UX Design',
        'instructor': 'Sara Mohammed',
        'dueDate': DateTime.now().subtract(const Duration(days: 5)),
        'points': 80,
        'status': 'graded',
        'grade': 75,
        'feedback': 'Good work! Consider adding more component variations.',
      },
    ];
    
    var filtered = allAssignments.where((assignment) {
      // Filter by status if specified
      if (status != null && assignment['status'] != status) {
        return false;
      }
      
      // Filter by course if selected
      if (_selectedFilter != 'all') {
        if (_selectedFilter == 'overdue') {
          return _isOverdue(assignment['dueDate'] as DateTime?) && assignment['status'] == 'pending';
        } else if (_selectedFilter == 'flutter') {
          return (assignment['course'] as String).toLowerCase().contains('flutter');
        } else if (_selectedFilter == 'ui_ux') {
          return (assignment['course'] as String).toLowerCase().contains('ui/ux');
        }
      }
      
      // Filter by search query
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final title = (assignment['title'] as String).toLowerCase();
        final course = (assignment['course'] as String).toLowerCase();
        final description = (assignment['description'] as String? ?? '').toLowerCase();
        return title.contains(query) || course.contains(query) || description.contains(query);
      }
      
      return true;
    }).toList();
    
    // Sort by due date
    filtered.sort((a, b) {
      final dateA = a['dueDate'] as DateTime;
      final dateB = b['dueDate'] as DateTime;
      return dateA.compareTo(dateB);
    });
    
    return filtered;
  }
  
  bool _isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate);
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'no_date'.tr;
    
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays == 0) {
      return 'today'.tr;
    } else if (difference.inDays == 1) {
      return 'tomorrow'.tr;
    } else if (difference.inDays == -1) {
      return 'yesterday'.tr;
    } else if (difference.inDays > 0) {
      return 'in'.tr + ' ${difference.inDays} ' + 'days'.tr;
    } else {
      return '${difference.inDays.abs()} ' + 'days_ago'.tr;
    }
  }
  
  Color _getGradeColor(int? grade) {
    if (grade == null) return Colors.grey;
    
    if (grade >= 90) {
      return AppTheme.accentColor;
    } else if (grade >= 80) {
      return Colors.blue;
    } else if (grade >= 70) {
      return AppTheme.warningColor;
    } else {
      return Colors.red;
    }
  }
  
  void _openAssignment(Map<String, dynamic> assignment) {
    final status = assignment['status'] as String;
    
    if (status == 'pending') {
      _showSubmissionDialog(assignment);
    } else if (status == 'graded' && assignment['feedback'] != null) {
      _showFeedbackDialog(assignment);
    } else {
      Get.snackbar(
        'assignment_details'.tr,
        'viewing_assignment'.tr.replaceAll('{title}', assignment['title']),
        backgroundColor: AppTheme.primaryColor,
        colorText: Colors.white,
      );
    }
  }
  
  void _showSubmissionDialog(Map<String, dynamic> assignment) {
    Get.dialog(
      AlertDialog(
        title: Text('submit_assignment'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment['title']),
            const SizedBox(height: 16),
            Text(
              'due_date'.tr + ': ${_formatDate(assignment['dueDate'])}',
              style: TextStyle(
                color: _isOverdue(assignment['dueDate']) ? Colors.red : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'submission_notes'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Mock file selection
              },
              icon: const Icon(Icons.attach_file),
              label: Text('attach_files'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'assignment_submitted'.tr,
                'assignment_submitted_successfully'.tr,
                backgroundColor: AppTheme.accentColor,
                colorText: Colors.white,
              );
            },
            child: Text('submit'.tr),
          ),
        ],
      ),
    );
  }
  
  void _showFeedbackDialog(Map<String, dynamic> assignment) {
    Get.dialog(
      AlertDialog(
        title: Text('assignment_feedback'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assignment['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('grade'.tr + ': '),
                Text(
                  '${assignment['grade']}/${assignment['points']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(assignment['grade']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'feedback'.tr + ':',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(assignment['feedback'] ?? 'no_feedback'.tr),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
        ],
      ),
    );
  }
}
