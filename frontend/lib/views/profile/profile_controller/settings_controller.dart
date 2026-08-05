import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {

  var notificationsEnabled = true.obs;
  var isArabic = false.obs; 

  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  var isOldPasswordHidden = true.obs;
  var isNewPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNotifications(bool value) => notificationsEnabled.value = value;
  
  void toggleOldPassword() => isOldPasswordHidden.value = !isOldPasswordHidden.value;
  void toggleNewPassword() => isNewPasswordHidden.value = !isNewPasswordHidden.value;
  void toggleConfirmPassword() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;


  void changeLanguage(bool toArabic) {
    isArabic.value = toArabic;
    Get.back(); 
    
    Get.snackbar(
      "Language Updated", 
      toArabic ? "تم تغيير لغة العرض إلى العربية" : "Display language changed to English",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  }

  void saveNewPassword() {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;

    String oldPass = oldPasswordController.text.trim();
    String newPass = newPasswordController.text.trim();
    String confirmPass = confirmPasswordController.text.trim();

    // 1. Check for empty fields
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        "Warning", 
        "Please fill in all fields first!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return; 
    }

    // 2. Check if old password is correct
    if (currentUser != null && oldPass != currentUser.password) {
      Get.snackbar(
        "Error", 
        "Incorrect old password!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return; 
    }

    // 3. Check if new passwords match
    if (newPass != confirmPass) {
      Get.snackbar(
        "Error", 
        "New passwords do not match!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }
    
    // 4. Check if new password is the same as the old one
    if (oldPass == newPass) {
      Get.snackbar(
        "Warning", 
        "The new password must be different from the old one!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }

    // 5. Success
    if (currentUser != null) {
      currentUser.password = newPass;
 
      authController.currentUser.refresh();

      Get.back(); 
      Get.snackbar(
        "Success", 
        "Password changed successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    }
  }

  void deleteAccount() {
    print("Account deleted successfully");
  }
}