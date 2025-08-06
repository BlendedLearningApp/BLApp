import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:blapp/controllers/navigation_controller.dart';
import 'package:blapp/controllers/auth_controller.dart';
import 'package:blapp/controllers/admin_controller.dart';
import 'package:blapp/controllers/student_controller.dart';
import 'package:blapp/controllers/instructor_controller.dart';
import 'package:blapp/services/dummy_data_service.dart';
import 'package:blapp/views/admin/admin_dashboard_view.dart';
import 'package:blapp/views/student/student_dashboard_view.dart';
import 'package:blapp/views/instructor/instructor_dashboard_view.dart';
import 'package:blapp/translations/app_translations.dart';

void main() {
  group('Dashboard Navigation Tests', () {
    late NavigationController navigationController;
    late AuthController authController;
    late AdminController adminController;
    late StudentController studentController;
    late InstructorController instructorController;
    late DummyDataService dataService;

    setUp(() {
      // Initialize GetX
      Get.testMode = true;

      // Initialize services and controllers
      dataService = DummyDataService();
      Get.put<DummyDataService>(dataService);

      authController = AuthController();
      Get.put<AuthController>(authController);

      navigationController = NavigationController();
      Get.put<NavigationController>(navigationController);

      adminController = AdminController();
      Get.put<AdminController>(adminController);

      studentController = StudentController();
      Get.put<StudentController>(studentController);

      instructorController = InstructorController();
      Get.put<InstructorController>(instructorController);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('Admin dashboard should use IndexedStack for navigation', (
      WidgetTester tester,
    ) async {
      // Build the admin dashboard
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: const AdminDashboardView(),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that IndexedStack is present
      expect(find.byType(IndexedStack), findsOneWidget);

      // Verify that the initial index is 0 (dashboard)
      expect(navigationController.adminCurrentIndex, equals(0));
    });

    testWidgets(
      'Bottom navigation should change admin index without navigation',
      (WidgetTester tester) async {
        // Build the admin dashboard
        await tester.pumpWidget(
          GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('en', 'US'),
            home: const AdminDashboardView(),
          ),
        );

        await tester.pumpAndSettle();

        // Initial state should be dashboard (index 0)
        expect(navigationController.adminCurrentIndex, equals(0));

        // Simulate tapping on the second bottom navigation item (Users)
        final bottomNavBar = find.byType(BottomNavigationBar);
        expect(bottomNavBar, findsOneWidget);

        // Tap on the users tab (index 1)
        await tester.tap(find.byIcon(Icons.people_outlined));
        await tester.pumpAndSettle();

        // Verify that the index changed to 1
        expect(navigationController.adminCurrentIndex, equals(1));

        // Tap on the analytics tab (index 3)
        await tester.tap(find.byIcon(Icons.analytics_outlined));
        await tester.pumpAndSettle();

        // Verify that the index changed to 3
        expect(navigationController.adminCurrentIndex, equals(3));
      },
    );

    test('NavigationController should properly manage admin index', () {
      // Test initial state
      expect(navigationController.adminCurrentIndex, equals(0));

      // Test setting admin index
      navigationController.setAdminIndex(2);
      expect(navigationController.adminCurrentIndex, equals(2));

      // Test navigateAdmin method
      navigationController.navigateAdmin(4);
      expect(navigationController.adminCurrentIndex, equals(4));

      // Test reset
      navigationController.resetAllIndices();
      expect(navigationController.adminCurrentIndex, equals(0));
    });

    testWidgets('Student dashboard should use IndexedStack for navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: const StudentDashboardView(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(IndexedStack), findsOneWidget);
      expect(navigationController.studentCurrentIndex, equals(0));
    });

    testWidgets('Instructor dashboard should use IndexedStack for navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: const InstructorDashboardView(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(IndexedStack), findsOneWidget);
      expect(navigationController.instructorCurrentIndex, equals(0));
    });

    test(
      'Navigation controllers should work independently without SharedPreferences interference',
      () {
        // Test that all navigation controllers work independently
        // This verifies that removing SharedPreferences auto-navigation doesn't break anything

        // Test student navigation
        navigationController.setStudentIndex(2);
        expect(navigationController.studentCurrentIndex, equals(2));

        // Test instructor navigation
        navigationController.setInstructorIndex(3);
        expect(navigationController.instructorCurrentIndex, equals(3));

        // Test admin navigation
        navigationController.setAdminIndex(1);
        expect(navigationController.adminCurrentIndex, equals(1));

        // All should remain independent
        expect(navigationController.studentCurrentIndex, equals(2));
        expect(navigationController.instructorCurrentIndex, equals(3));
        expect(navigationController.adminCurrentIndex, equals(1));
      },
    );
  });
}
