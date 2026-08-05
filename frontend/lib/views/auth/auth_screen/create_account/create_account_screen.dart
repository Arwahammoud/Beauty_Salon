import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccount extends StatelessWidget {
  CreateAccount({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.backgroundRolle, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Form(
                  key: authController.registerFormKey,
                  child: Column(
                    children: [
                      SizedBox(height: 50.h),
                      Text(
                        "Belle",
                        style: GoogleFonts.dmSerifDisplay(
                          color: AppColors.white,
                          fontSize: 70.sp,
                          height: 0.8,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "BEAUTY SALON",
                        style: GoogleFonts.outfit(
                          color: AppColors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Text(
                        "Create a new account",
                        style: GoogleFonts.outfit(
                          color: AppColors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      CustomTextField(
                        hint: "Full Name",
                        controller: authController.nameController,
                        validator: authController.validateName,
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        hint: "Email Address",
                        keyboardType: TextInputType.emailAddress,
                        controller: authController.emailController,
                        validator: authController.validateEmail,
                      ),
                      SizedBox(height: 14.h),
                      CustomTextField(
                        hint: "Phone Number",
                        keyboardType: TextInputType.phone,
                        controller: authController.phoneController,
                        validator: authController.validatePhone,
                      ),
                      SizedBox(height: 14.h),
                      Obx(
                        () => CustomTextField(
                          hint: "Password",
                          isPassword: true,
                          obscureText: authController.isRegisterPasswordHidden.value,
                          controller: authController.passwordController,
                          validator: authController.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authController.isRegisterPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textFaint,
                            ),
                            onPressed: authController.toggleRegisterPasswordVisibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Obx(
                        () => CustomTextField(
                          hint: "Confirm Password",
                          isPassword: true,
                          obscureText: authController.isConfirmPasswordHidden.value,
                          controller: authController.confirmPasswordController,
                          validator: authController.validateConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authController.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textFaint,
                            ),
                            onPressed: authController.toggleConfirmPasswordVisibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      CustomPrimaryButton(
                        text: "Create Account",
                        onPressed: authController.createAccount,
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: GoogleFonts.outfit(
                              color: AppColors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.offNamed(AppRoutes.loginScreen),
                            child: Text(
                              "Login",
                              style: GoogleFonts.outfit(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
