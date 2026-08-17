import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});
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
                  key: authController.resetPasswordFormKey,
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      Text(
                        "Belle",
                        style: GoogleFonts.dmSerifDisplay(
                          color: AppColors.white,
                          fontSize: 60.sp,
                          height: 0.8,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        'reset_password_title'.tr,
                        style: GoogleFonts.outfit(
                          color: AppColors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Obx(
                        () => Text(
                          'verify_code_prompt'.trParams({
                            'email': authController.pendingResetEmail.value,
                          }),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      CustomTextField(
                        hint: 'six_digit_code'.tr,
                        keyboardType: TextInputType.number,
                        controller: authController.resetCodeController,
                        validator: authController.validateVerificationCode,
                      ),
                      SizedBox(height: 14.h),
                      Obx(
                        () => CustomTextField(
                          hint: 'new_password_hint'.tr,
                          isPassword: true,
                          obscureText: authController.isResetNewPasswordHidden.value,
                          controller: authController.resetNewPasswordController,
                          validator: authController.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authController.isResetNewPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textFaint,
                            ),
                            onPressed: authController.toggleResetNewPasswordVisibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Obx(
                        () => CustomTextField(
                          hint: 'confirm_password'.tr,
                          isPassword: true,
                          obscureText: authController.isResetConfirmPasswordHidden.value,
                          controller: authController.resetConfirmPasswordController,
                          validator: authController.validateResetConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authController.isResetConfirmPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textFaint,
                            ),
                            onPressed: authController.toggleResetConfirmPasswordVisibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      CustomPrimaryButton(
                        text: 'reset_password_btn'.tr,
                        onPressed: authController.submitResetPassword,
                      ),
                      SizedBox(height: 18.h),
                      Obx(
                        () {
                          final cooldown = authController.resendCooldown.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'didnt_get_code'.tr,
                                style: GoogleFonts.outfit(
                                  color: AppColors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: cooldown > 0
                                    ? null
                                    : authController.resendResetCode,
                                child: Text(
                                  cooldown > 0
                                      ? 'resend_in_seconds'.trParams({'seconds': '$cooldown'})
                                      : 'resend'.tr,
                                  style: GoogleFonts.outfit(
                                    color: cooldown > 0
                                        ? AppColors.white.withValues(alpha: 0.5)
                                        : AppColors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                    decoration: cooldown > 0
                                        ? TextDecoration.none
                                        : TextDecoration.underline,
                                    decorationColor: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'change_email'.tr,
                          style: GoogleFonts.outfit(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.white,
                          ),
                        ),
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
