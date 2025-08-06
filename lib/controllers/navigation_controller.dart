import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt _studentCurrentIndex = 0.obs;
  final RxInt _instructorCurrentIndex = 0.obs;
  final RxInt _adminCurrentIndex = 0.obs;

  int get studentCurrentIndex => _studentCurrentIndex.value;
  int get instructorCurrentIndex => _instructorCurrentIndex.value;
  int get adminCurrentIndex => _adminCurrentIndex.value;

  void setStudentIndex(int index) {
    _studentCurrentIndex.value = index;
  }

  void setInstructorIndex(int index) {
    _instructorCurrentIndex.value = index;
  }

  void setAdminIndex(int index) {
    _adminCurrentIndex.value = index;
  }

  void navigateStudent(int index) {
    setStudentIndex(index);
    // No navigation here! The dashboard view will swap the body content.
  }

  void navigateInstructor(int index) {
    setInstructorIndex(index);
    // No navigation here! The dashboard view will swap the body content.
  }

  void navigateAdmin(int index) {
    setAdminIndex(index);
    // No navigation here! The dashboard view will swap the body content.
  }

  void resetAllIndices() {
    _studentCurrentIndex.value = 0;
    _instructorCurrentIndex.value = 0;
    _adminCurrentIndex.value = 0;
  }
}
