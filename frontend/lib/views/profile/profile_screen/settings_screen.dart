import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/profile/profile_controller/settings_controller.dart';
import 'package:belle_beauty_salon/views/profile/widgets/widget_setting/change_password_bottom_sheet.dart';
import 'package:belle_beauty_salon/views/profile/widgets/widget_setting/language_bottom_sheet.dart';
import 'package:belle_beauty_salon/views/profile/widgets/widget_setting/settings_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'profile_settings'.tr,
          style: TextStyle(
            color: AppColors.black,
            fontFamily: "TimesNewRoman",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings_preferences'.tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            SizedBox(height: 15.h),
            Obx(() => SettingsTile(
              icon: Icons.notifications_none_outlined,
              title: 'settings_notifications'.tr,
              trailing: CupertinoSwitch(
                activeColor: const Color(0xFFF48FB1),
                value: controller.notificationsEnabled.value,
                onChanged: (value) => controller.toggleNotifications(value),
              ),
            )),
          Obx(() => SettingsTile(
              icon: Icons.language_outlined,
              title: 'settings_language'.tr,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.isArabic.value ? "العربية" : "English",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey.shade400),
                ],
              ),
              hideArrow: true,
              onTap: () {
                Get.bottomSheet(
                  LanguageBottomSheet(),
                );
              },
            )),

            SizedBox(height: 30.h),

            Text(
              'settings_account_security'.tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            SizedBox(height: 15.h),

            SettingsTile(
              icon: Icons.lock_outline,
              title: 'settings_change_password'.tr,
              onTap: () {
                Get.bottomSheet(
                  ChangePasswordBottomSheet(),
                  isScrollControlled: true,
                );
              },
            ),
            SettingsTile(
              icon: Icons.delete_outline,
              title: 'settings_delete_account'.tr,
              titleColor: Colors.red.shade400,
              iconColor: Colors.red.shade400,
              hideArrow: true,
              onTap: () => controller.deleteAccount(),
            ),
          ],
        ),
      ),
    );
  }
}