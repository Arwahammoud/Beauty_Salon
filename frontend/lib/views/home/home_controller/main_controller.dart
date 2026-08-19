import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;

    if (index == 4) {
      final authController = Get.find<AuthController>();
      authController.refreshCurrentUser();
    }
  }
}