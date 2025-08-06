import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';

class AdminBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNavigation({
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
          icon: const Icon(Icons.people_outlined),
          activeIcon: const Icon(Icons.people),
          label: 'users'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.library_books_outlined),
          activeIcon: const Icon(Icons.library_books),
          label: 'content'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics_outlined),
          activeIcon: const Icon(Icons.analytics),
          label: 'analytics'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: 'settings'.tr,
        ),
      ],
    );
  }
}
