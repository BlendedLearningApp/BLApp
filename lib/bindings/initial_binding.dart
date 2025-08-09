import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/instructor_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/navigation_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers - SupabaseService is used directly as a static class
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );
    Get.lazyPut<StudentController>(() => StudentController(), fenix: true);
    Get.lazyPut<InstructorController>(
      () => InstructorController(),
      fenix: true,
    );
    Get.lazyPut<AdminController>(() => AdminController(), fenix: true);
  }
}
