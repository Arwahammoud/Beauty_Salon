import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/profile/profile_controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChangePasswordBottomSheet extends StatelessWidget {
  ChangePasswordBottomSheet({Key? key}) : super(key: key);

  final SettingsController controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Text('change_password_title'.tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            Text('change_password_subtitle'.tr,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
            SizedBox(height: 20.h),

            Obx(() => _buildPasswordField('old_password_hint'.tr, controller.oldPasswordController,
                controller.isOldPasswordHidden.value, controller.toggleOldPassword)),
            SizedBox(height: 12.h),

            Obx(() => _buildPasswordField('new_password_hint'.tr, controller.newPasswordController,
                controller.isNewPasswordHidden.value, controller.toggleNewPassword)),
            SizedBox(height: 12.h),

            Obx(() => _buildPasswordField('confirm_new_password_hint'.tr, controller.confirmPasswordController,
                controller.isConfirmPasswordHidden.value, controller.toggleConfirmPassword)),
            SizedBox(height: 30.h),

            CustomPrimaryButton(
              borderRadius: 15.r,
              text: 'update_password_btn'.tr,
              onPressed: () => controller.saveNewPassword(),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom), 
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController textController, bool isHidden, VoidCallback onToggle) {
    return TextField(
      controller: textController,
      obscureText: isHidden,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
    );
  }
}