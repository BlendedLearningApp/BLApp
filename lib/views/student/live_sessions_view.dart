import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/student_controller.dart';
import '../../models/live_session_model.dart';
import '../../widgets/common/live_session_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';

class LiveSessionsView extends StatelessWidget {
  const LiveSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('live_sessions'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GetBuilder<StudentController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const LoadingWidget();
          }

          final upcomingSessions = _getUpcomingSessions(controller);
          final pastSessions = _getPastSessions(controller);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upcoming Sessions Section
                _buildSectionHeader('upcoming_sessions'.tr, upcomingSessions.length),
                const SizedBox(height: 16),
                
                if (upcomingSessions.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.video_call_outlined,
                    title: 'no_upcoming_sessions'.tr,
                    description: 'check_back_later'.tr,
                  )
                else
                  ...upcomingSessions.map((session) => LiveSessionCard(
                    session: session,
                    onJoin: () => _joinSession(session),
                    onRemind: () => _setReminder(session),
                  )),

                if (pastSessions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader('past_sessions'.tr, pastSessions.length),
                  const SizedBox(height: 16),
                  
                  ...pastSessions.take(5).map((session) => LiveSessionCard(
                    session: session,
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  List<LiveSessionModel> _getUpcomingSessions(StudentController controller) {
    // Mock data for upcoming sessions - in real app, this would come from the controller
    return [
      LiveSessionModel(
        id: 'session_1',
        title: 'Introduction to Flutter Widgets',
        description: 'Live session covering basic Flutter widgets and their usage',
        courseId: 'course_1',
        courseName: 'Flutter Development',
        instructorId: 'instructor_1',
        instructorName: 'Dr. Sarah Johnson',
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        durationMinutes: 60,
        meetingUrl: 'https://meet.google.com/abc-def-ghi',
        status: LiveSessionStatus.scheduled,
        attendeeIds: ['student_1'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LiveSessionModel(
        id: 'session_2',
        title: 'Advanced State Management',
        description: 'Deep dive into GetX and state management patterns',
        courseId: 'course_1',
        courseName: 'Flutter Development',
        instructorId: 'instructor_1',
        instructorName: 'Dr. Sarah Johnson',
        scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
        durationMinutes: 90,
        meetingUrl: 'https://meet.google.com/xyz-uvw-rst',
        status: LiveSessionStatus.scheduled,
        attendeeIds: ['student_1'],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<LiveSessionModel> _getPastSessions(StudentController controller) {
    // Mock data for past sessions
    return [
      LiveSessionModel(
        id: 'session_past_1',
        title: 'Flutter Basics Q&A',
        description: 'Open Q&A session for Flutter fundamentals',
        courseId: 'course_1',
        courseName: 'Flutter Development',
        instructorId: 'instructor_1',
        instructorName: 'Dr. Sarah Johnson',
        scheduledTime: DateTime.now().subtract(const Duration(days: 2)),
        durationMinutes: 45,
        meetingUrl: 'https://meet.google.com/past-session',
        status: LiveSessionStatus.ended,
        attendeeIds: ['student_1'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  void _joinSession(LiveSessionModel session) {
    // In a real app, this would open the meeting URL or launch the meeting app
    Get.snackbar(
      'joining_session'.tr,
      'opening_meeting_link'.tr,
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
    
    // Simulate opening meeting URL
    // In real implementation: launch(session.meetingUrl);
  }

  void _setReminder(LiveSessionModel session) {
    Get.snackbar(
      'reminder_set'.tr,
      'you_will_be_notified'.tr,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
