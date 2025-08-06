import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';

class StudentBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StudentBottomNavigation({
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
          icon: const Icon(Icons.book_outlined),
          activeIcon: const Icon(Icons.book),
          label: 'my_courses'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.quiz_outlined),
          activeIcon: const Icon(Icons.quiz),
          label: 'quizzes'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.forum_outlined),
          activeIcon: const Icon(Icons.forum),
          label: 'forum'.tr,
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
