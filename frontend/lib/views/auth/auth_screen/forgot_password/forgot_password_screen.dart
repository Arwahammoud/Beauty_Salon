import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
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
                  key: authController.forgotPasswordFormKey,
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
                        'beauty_salon'.tr,
                        style: GoogleFonts.outfit(
                          color: AppColors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      Text(
                        'forgot_password_title'.tr,
                        style: GoogleFonts.outfit(
                          color: AppColors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'forgot_password_prompt'.tr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      CustomTextField(
                        hint: 'email_address'.tr,
                        keyboardType: TextInputType.emailAddress,
                        controller: authController.resetEmailController,
                        validator: authController.validateEmail,
                      ),
                      SizedBox(height: 28.h),
                      CustomPrimaryButton(
                        text: 'send_code_btn'.tr,
                        onPressed: authController.sendResetCode,
                      ),
                      SizedBox(height: 18.h),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'back_to_login'.tr,
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
