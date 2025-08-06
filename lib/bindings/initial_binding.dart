import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/instructor_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/navigation_controller.dart';
import '../services/dummy_data_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<DummyDataService>(() => DummyDataService(), fenix: true);
    
    // Controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<NavigationController>(() => NavigationController(), fenix: true);
    Get.lazyPut<StudentController>(() => StudentController(), fenix: true);
    Get.lazyPut<InstructorController>(() => InstructorController(), fenix: true);
    Get.lazyPut<AdminController>(() => AdminController(), fenix: true);
  }
}
