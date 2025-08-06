import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blapp/config/app_theme.dart';
import 'package:blapp/controllers/instructor_controller.dart';
import 'package:blapp/widgets/common/custom_card.dart';
import 'package:blapp/widgets/common/empty_state_widget.dart';

class QuizManagerView extends StatefulWidget {
  const QuizManagerView({super.key});

  @override
  State<QuizManagerView> createState() => _QuizManagerViewState();
}

class _QuizManagerViewState extends State<QuizManagerView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  List<Map<String, dynamic>> _questions = [];

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
        title: Text('quiz_manager'.tr),
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
            Tab(text: 'my_quizzes'.tr),
            Tab(text: 'create_quiz'.tr),
            Tab(text: 'analytics'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyQuizzesTab(),
          _buildCreateQuizTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }
  
  Widget _buildMyQuizzesTab() {
    return const Center(
      child: Text('Quiz List - Implementation in progress'),
    );
  }
  
  Widget _buildCreateQuizTab() {
    return const Center(
      child: Text('Create Quiz - Implementation in progress'),
    );
  }
  
  Widget _buildAnalyticsTab() {
    return const Center(
      child: Text('Quiz Analytics - Implementation in progress'),
    );
  }
}
