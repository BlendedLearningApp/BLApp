import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';

class InstructorBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const InstructorBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey[600],
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: 'dashboard'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.school_outlined),
          activeIcon: const Icon(Icons.school),
          label: 'my_courses'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.video_library_outlined),
          activeIcon: const Icon(Icons.video_library),
          label: 'videos'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.quiz_outlined),
          activeIcon: const Icon(Icons.quiz),
          label: 'quizzes'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_outlined),
          activeIcon: const Icon(Icons.assignment),
          label: 'submissions'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: 'profile'.tr,
        ),
      ],
    );
  }
}
