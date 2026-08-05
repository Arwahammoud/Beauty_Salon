import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoleController extends GetxController {
  final isArabic = false.obs;

  // Stores the role selected on the role screen so login can route correctly
  final currentRole = 'CUSTOMER'.obs;

  void toggleLanguage() {
    isArabic.value = !isArabic.value;
    Get.updateLocale(
      isArabic.value ? const Locale('ar', 'SA') : const Locale('en', 'US'),
    );
  }

  void selectRole(String role) {
    currentRole.value = role;
    if (role == 'ADMIN') {
      Get.offNamed(AppRoutes.loginScreen);
    } else {
      Get.offNamed(AppRoutes.createAccount);
    }
  }
}
