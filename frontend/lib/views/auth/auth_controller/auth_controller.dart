import 'dart:async';

import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/models/user_model.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final registerFormKey = GlobalKey<FormState>();
  final verifySignupFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  var currentUser = Rxn<UserModel>();
  var isLoading = false.obs;

  // for create account
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  // for signup email verification
  late TextEditingController verificationCodeController;
  var pendingSignupEmail = ''.obs;
  var resendCooldown = 0.obs;
  Timer? _resendTimer;
  // for login
  late TextEditingController loginEmailController;
  late TextEditingController loginPasswordController;

  var isRegisterPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoginPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    verificationCodeController = TextEditingController();
    loginEmailController = TextEditingController();
    loginPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    verificationCodeController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'validate_name_required'.tr;
    if (value.trim().length < 2) return 'validate_name_length'.tr;
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'validate_email_required'.tr;
    if (!GetUtils.isEmail(value)) return 'validate_email_invalid'.tr;
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'validate_phone_required'.tr;
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'validate_phone_numeric'.tr;
    if (value.trim().length < 7) return 'validate_phone_length'.tr;
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'validate_password_required'.tr;
    if (value.length < 8) return 'validate_password_length'.tr;
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) return 'validate_password_letter'.tr;
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'validate_password_number'.tr;
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'validate_confirm_password_required'.tr;
    if (value != passwordController.text) return 'validate_passwords_mismatch'.tr;
    return null;
  }

  String? validateVerificationCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'validate_code_required'.tr;
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) return 'validate_code_length'.tr;
    return null;
  }

  String get firstName {
    if (currentUser.value == null || currentUser.value!.name.trim().isEmpty) {
      return 'guest'.tr;
    }
    return currentUser.value!.name.trim().split(' ').first;
  }

  String get userEmail => currentUser.value?.email ?? '';
  String get userPhone => currentUser.value?.phone ?? '';

  Future<void> createAccount() async {
    if (isLoading.value) return;
    if (!registerFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await ApiService.post('/auth/signup', body: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
      });

      pendingSignupEmail.value = emailController.text.trim();
      verificationCodeController.clear();
      _startResendCooldown();

      Get.toNamed(AppRoutes.verifySignup);
    } on ApiException catch (e) {
      Get.snackbar('could_not_create_account'.tr, e.message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('connection_error_title'.tr, 'connection_error_body'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Verify signup email code (Step 2) ====================
  Future<void> verifySignupCode() async {
    if (isLoading.value) return;
    if (!verifySignupFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await ApiService.post('/auth/verify-signup', body: {
        'email': pendingSignupEmail.value,
        'verificationCode': verificationCodeController.text.trim(),
      });

      final data = response['data'];
      await ApiService.saveToken(data['token']);
      currentUser.value = UserModel.fromJson(data['user']);

      _resendTimer?.cancel();
      _clearSignupForm();

      Get.offAllNamed(AppRoutes.mainScreen);
    } on ApiException catch (e) {
      Get.snackbar('verification_failed'.tr, e.message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('connection_error_title'.tr, 'connection_error_body'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationCode() async {
    if (isLoading.value || resendCooldown.value > 0) return;

    isLoading.value = true;
    try {
      await ApiService.post('/auth/signup', body: {
        'name': nameController.text.trim(),
        'email': pendingSignupEmail.value,
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
      });

      _startResendCooldown();
      Get.snackbar('code_sent_title'.tr, 'code_sent_body'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (e) {
      Get.snackbar('could_not_resend_code'.tr, e.message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('connection_error_title'.tr, 'connection_error_body'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendCooldown() {
    resendCooldown.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value <= 1) {
        resendCooldown.value = 0;
        timer.cancel();
      } else {
        resendCooldown.value--;
      }
    });
  }

  void _clearSignupForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    verificationCodeController.clear();
    pendingSignupEmail.value = '';
  }

  // Demo credentials — match the accounts created by backend/src/scripts/seed.js
  static const _demoEmail    = 'kelly@belle.com';
  static const _demoPassword = 'Belle1234';
  static const _adminEmail    = 'admin@belle.com';
  static const _adminPassword = 'Admin1234';

  void fillDemoCredentials() {
    loginEmailController.text = _demoEmail;
    loginPasswordController.text = _demoPassword;
  }

  void fillAdminCredentials() {
    loginEmailController.text = _adminEmail;
    loginPasswordController.text = _adminPassword;
  }

  Future<void> login() async {
    if (isLoading.value) return;
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await ApiService.post('/auth/signin', body: {
        'email': loginEmailController.text.trim(),
        'password': loginPasswordController.text,
      });

      final data = response['data'];
      await ApiService.saveToken(data['token']);
      final user = UserModel.fromJson(data['user']);
      currentUser.value = user;

      // The server's role is the source of truth — not whatever role the
      // user tapped on the role-selection screen before logging in.
      final isAdmin = user.role.toUpperCase() == 'ADMIN';
      Get.offAllNamed(isAdmin ? AppRoutes.adminDashboard : AppRoutes.mainScreen);
    } on ApiException catch (e) {
      Get.snackbar('login_failed'.tr, e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('connection_error_title'.tr, 'connection_error_body'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    currentUser.value = null;

    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    loginEmailController.clear();
    loginPasswordController.clear();

    isRegisterPasswordHidden.value = true;
    isConfirmPasswordHidden.value = true;
    isLoginPasswordHidden.value = true;
  }
}
