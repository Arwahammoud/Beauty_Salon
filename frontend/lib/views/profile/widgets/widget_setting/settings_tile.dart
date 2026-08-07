import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;
  final bool hideArrow;
  final VoidCallback? onTap;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    this.titleColor,
    this.iconColor,
    this.hideArrow = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF0F3),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFFF48FB1), size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? AppColors.black,
          ),
        ),
        trailing: trailing ?? 
            (hideArrow ? null : Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey.shade400)),
      ),
    );
  }
}