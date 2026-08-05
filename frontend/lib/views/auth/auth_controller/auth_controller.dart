import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/models/user_model.dart';
import 'package:belle_beauty_salon/views/rolle/rolle_controller/role_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final registerFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  var currentUser = Rxn<UserModel>();

  // for create account
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
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
    loginEmailController.dispose();
    loginPasswordController.dispose();
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
    if (value == null || value.trim().isEmpty) return 'Please enter your full name';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email address';
    if (!GetUtils.isEmail(value)) return 'Invalid email format';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Phone number must contain numbers only';
    if (value.trim().length < 7) return 'Phone number must be at least 7 digits';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) return 'Password must contain at least one letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one number';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  String get firstName {
    if (currentUser.value == null || currentUser.value!.name.trim().isEmpty) {
      return "Guest";
    }
    return currentUser.value!.name.trim().split(' ').first;
  }

  String get userEmail => currentUser.value?.email ?? '';
  String get userPhone => currentUser.value?.phone ?? '';

  void createAccount() {
    if (registerFormKey.currentState!.validate()) {
      UserModel newUser = UserModel(
        name: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
      );
      currentUser.value = newUser;
      Get.offAllNamed(AppRoutes.mainScreen);
    }
  }

  // Demo credentials
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

  void login() {
    if (loginFormKey.currentState!.validate()) {
      currentUser.value = UserModel(
        name: Get.isRegistered<RoleController>() &&
                Get.find<RoleController>().currentRole.value == 'ADMIN'
            ? 'Salon Owner'
            : 'Kelly Ahmed',
        email: loginEmailController.text,
        phone: '0501234567',
        password: loginPasswordController.text,
      );
      final isAdmin = Get.isRegistered<RoleController>() &&
          Get.find<RoleController>().currentRole.value == 'ADMIN';
      Get.offAllNamed(isAdmin ? AppRoutes.adminDashboard : AppRoutes.mainScreen);
    }
  }

  void logout() {
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
