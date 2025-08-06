import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import 'course_approval_view.dart';
import 'admin_video_management_view.dart';
import 'admin_quiz_management_view.dart';

class ContentManagementView extends StatefulWidget {
  const ContentManagementView({super.key});

  @override
  State<ContentManagementView> createState() => _ContentManagementViewState();
}

class _ContentManagementViewState extends State<ContentManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('content_management'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: const Icon(Icons.school),
              text: 'courses'.tr,
            ),
            Tab(
              icon: const Icon(Icons.video_library),
              text: 'videos'.tr,
            ),
            Tab(
              icon: const Icon(Icons.quiz),
              text: 'quizzes'.tr,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CourseApprovalView(),
          AdminVideoManagementView(),
          AdminQuizManagementView(),
        ],
      ),
    );
  }
}
