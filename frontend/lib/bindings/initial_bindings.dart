import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_controller/favorite_controller.dart';
import 'package:belle_beauty_salon/views/rolle/rolle_controller/role_controller.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(RoleController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.lazyPut(() => FavoriteController(), fenix: true);
    Get.lazyPut(() => AdminController(), fenix: true);
  }
}