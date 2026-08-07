import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/profile/profile_controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LanguageBottomSheet extends StatelessWidget {
  LanguageBottomSheet({Key? key}) : super(key: key);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 5.h,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)),
          ),
          SizedBox(height: 20.h),
          Text('settings_select_language'.tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.h),

          Obx(() => _buildLangOption(
            title: "English",
            isSelected: !controller.isArabic.value, 
            onTap: () => controller.changeLanguage(false),
          )),

          SizedBox(height: 12.h),

          Obx(() => _buildLangOption(
            title: "العربية",
            isSelected: controller.isArabic.value, 
            onTap: () => controller.changeLanguage(true),
          )),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildLangOption({required String title, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDF0F3) : Colors.transparent, 
          border: Border.all(color: isSelected ? const Color(0xFFF48FB1) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: 16.sp, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, 
                color: AppColors.black
              )
            ),
            if (isSelected) 
              Icon(Icons.check_circle, color: const Color(0xFFF48FB1), size: 22.sp)
          ],
        ),
      ),
    );
  }
}