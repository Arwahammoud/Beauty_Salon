import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomInfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;

  const CustomInfoField({
    Key? key,
    required this.label,
    required this.controller,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14.sp, 
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        decoration: InputDecoration(
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ), 
          prefixIcon: Padding(
           
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0F3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: const Color(0xFFF48FB1), size: 18.sp),
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w), 
        ),
      ),
    );
  }
}