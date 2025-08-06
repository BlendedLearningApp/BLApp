import 'package:get/get.dart';
import '../views/splash/splash_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/student/student_dashboard_view.dart';
import '../views/student/course_detail_view.dart';
import '../views/student/quiz_view.dart';
import '../views/student/progress_view.dart';
import '../views/student/forum_view.dart';
import '../views/student/student_profile_view.dart';
import '../views/instructor/instructor_dashboard_view.dart';
import '../views/instructor/create_course_view.dart';
import '../views/instructor/manage_videos_view.dart';
import '../views/instructor/quiz_manager_view.dart';
import '../views/instructor/student_submissions_view.dart';
import '../views/instructor/instructor_profile_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../bindings/initial_binding.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Student Routes
  static const String studentDashboard = '/student/dashboard';
  static const String courseDetail = '/student/course';
  static const String quiz = '/student/quiz';
  static const String progress = '/student/progress';
  static const String forum = '/student/forum';
  static const String studentProfile = '/student/profile';

  // Instructor Routes
  static const String instructorDashboard = '/instructor/dashboard';
  static const String createCourse = '/instructor/create-course';
  static const String manageVideos = '/instructor/manage-videos';
  static const String quizManager = '/instructor/quiz-manager';
  static const String studentSubmissions = '/instructor/submissions';
  static const String instructorProfile = '/instructor/profile';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';

  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: signup,
      page: () => const SignupView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: InitialBinding(),
    ),

    // Student Pages
    GetPage(
      name: studentDashboard,
      page: () => const StudentDashboardView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: courseDetail,
      page: () => const CourseDetailView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: quiz,
      page: () => const QuizView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: progress,
      page: () => const ProgressView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: forum,
      page: () => const ForumView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: studentProfile,
      page: () => const StudentProfileView(),
      binding: InitialBinding(),
    ),

    // Instructor Pages
    GetPage(
      name: instructorDashboard,
      page: () => const InstructorDashboardView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: createCourse,
      page: () => const CreateCourseView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: manageVideos,
      page: () => const ManageVideosView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: quizManager,
      page: () => const QuizManagerView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: studentSubmissions,
      page: () => const StudentSubmissionsView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: instructorProfile,
      page: () => const InstructorProfileView(),
      binding: InitialBinding(),
    ),

    // Admin Pages
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardView(),
      binding: InitialBinding(),
    ),
  ];
}
