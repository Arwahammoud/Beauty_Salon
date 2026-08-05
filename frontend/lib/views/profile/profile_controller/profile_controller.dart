import 'package:belle_beauty_salon/models/user_model.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthDateController;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    phoneController = TextEditingController(text: user?.phone ?? "");
    birthDateController = TextEditingController(text: user?.birthDate ?? "");
  }

  void saveProfileChanges() {
    final authController = Get.find<AuthController>();
    
    if (authController.currentUser.value != null) {
      UserModel updatedUser = UserModel(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: authController.currentUser.value!.password,
        birthDate: birthDateController.text,
        loyaltyPoints: authController.currentUser.value!.loyaltyPoints,
      );
      authController.currentUser.value = updatedUser;
      Get.back(); 
      Get.snackbar(
        "نجاح",
        "تم تحديث معلوماتك الشخصية بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        margin: const EdgeInsets.all(15),
        borderRadius: 15,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    super.onClose();
  }
}