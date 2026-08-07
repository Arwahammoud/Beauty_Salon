import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart'; 

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      title: Text(
        'profile_logout'.tr,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.red.shade600,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'profile_logout_confirm'.tr,
        style: TextStyle(fontSize: 15.sp),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(
            'cancel'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.find<AuthController>().logout();

            Get.offAllNamed(AppRoutes.rolleSceeen);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          child: Text(
            'profile_logout'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}