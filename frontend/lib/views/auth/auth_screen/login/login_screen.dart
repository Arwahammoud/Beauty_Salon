import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_text_field.dart';
import 'package:belle_beauty_salon/views/rolle/rolle_controller/role_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final AuthController authController = Get.find<AuthController>();
  final RoleController roleController = Get.find<RoleController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isArabic = roleController.isArabic.value;
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
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
                        key: authController.loginFormKey,
                        child: Column(
                          children: [
                            SizedBox(height: 50.h),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: GestureDetector(
                                onTap: roleController.toggleLanguage,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.white.withValues(alpha: 0.35), width: 1),
                                  ),
                                  child: Text(
                                    isArabic ? 'EN' : 'AR',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Belle',
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
                            SizedBox(height: 60.h),
                            Text(
                              'welcome_back'.tr,
                              style: GoogleFonts.outfit(
                                color: AppColors.white,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'login_to_account'.tr,
                              style: GoogleFonts.outfit(
                                color: AppColors.white.withValues(alpha: 0.8),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            CustomTextField(
                              hint: 'email_address'.tr,
                              keyboardType: TextInputType.emailAddress,
                              controller: authController.loginEmailController,
                              validator: authController.validateEmail,
                            ),
                            SizedBox(height: 14.h),
                            Obx(
                              () => CustomTextField(
                                hint: 'password'.tr,
                                isPassword: true,
                                obscureText: authController.isLoginPasswordHidden.value,
                                controller: authController.loginPasswordController,
                                validator: authController.validatePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    authController.isLoginPasswordHidden.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textFaint,
                                  ),
                                  onPressed: authController.toggleLoginPasswordVisibility,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 36.h),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'forgot_password'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.sp,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            CustomPrimaryButton(
                              text: 'login'.tr,
                              onPressed: authController.login,
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'dont_have_account'.tr,
                                  style: GoogleFonts.outfit(
                                    color: AppColors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Get.offNamed(AppRoutes.createAccount),
                                  child: Text(
                                    'sign_up'.tr,
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
          ),
        );
      },
    );
  }
}
