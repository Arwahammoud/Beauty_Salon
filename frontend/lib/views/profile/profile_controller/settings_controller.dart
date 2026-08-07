import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/rolle/rolle_controller/role_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RoleController _roleController = Get.find<RoleController>();

  var notificationsEnabled = true.obs;

  // Language is app-wide state owned by RoleController — proxy to it so
  // every screen (login, role selection, settings) stays in sync.
  RxBool get isArabic => _roleController.isArabic;

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
    _roleController.setLanguage(toArabic);
    Get.back();

    Get.snackbar(
      'language_updated_title'.tr,
      toArabic ? 'language_changed_to_arabic'.tr : 'language_changed_to_english'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade800,
    );
  }

  var isChangingPassword = false.obs;
  var isDeletingAccount = false.obs;

  Future<void> saveNewPassword() async {
    if (isChangingPassword.value) return;

    String oldPass = oldPasswordController.text.trim();
    String newPass = newPasswordController.text.trim();
    String confirmPass = confirmPasswordController.text.trim();

    // 1. Check for empty fields
    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        'warning'.tr,
        'fill_all_fields_warning'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }

    // 2. Check if new passwords match
    if (newPass != confirmPass) {
      Get.snackbar(
        'error'.tr,
        'new_passwords_mismatch'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // The old-password check and "must differ from old" rule are now
    // enforced server-side (POST /users/me/change-password), since the
    // client no longer keeps a plaintext password to compare against.
    isChangingPassword.value = true;
    try {
      await ApiService.post('/users/me/change-password', auth: true, body: {
        'oldPassword': oldPass,
        'newPassword': newPass,
      });

      Get.back();
      Get.snackbar(
        'success'.tr,
        'password_changed_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } catch (_) {
      Get.snackbar('error'.tr, 'connection_error_body'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> deleteAccount() async {
    if (isDeletingAccount.value) return;
    isDeletingAccount.value = true;
    try {
      await ApiService.delete('/users/me', auth: true);
      await ApiService.clearToken();
      Get.find<AuthController>().currentUser.value = null;
      Get.offAllNamed(AppRoutes.rolleSceeen);
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } catch (_) {
      Get.snackbar('error'.tr, 'connection_error_body'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      isDeletingAccount.value = false;
    }
  }
}