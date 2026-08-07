import 'package:belle_beauty_salon/models/user_model.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthDateController;

  var isSaving = false.obs;

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

  Future<void> saveProfileChanges() async {
    if (isSaving.value) return;
    final authController = Get.find<AuthController>();
    if (authController.currentUser.value == null) return;

    isSaving.value = true;
    try {
      final data = await ApiService.patch('/users/me', auth: true, body: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        if (birthDateController.text.trim().isNotEmpty)
          'birthDate': birthDateController.text.trim(),
      });

      authController.currentUser.value = UserModel.fromJson(data);

      Get.back();
      Get.snackbar(
        'success'.tr,
        'profile_update_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        margin: const EdgeInsets.all(15),
        borderRadius: 15,
      );
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
      isSaving.value = false;
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
