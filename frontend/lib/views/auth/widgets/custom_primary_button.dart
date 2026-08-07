import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:belle_beauty_salon/constant/app_colors.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final IconData? icon;
  final bool hasShadow;
  final double borderRadius;

  const CustomPrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.gradient,
    this.textColor = AppColors.white,
    this.icon,
    this.hasShadow = true,
    this.borderRadius = 999.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        gradient: gradient ?? (backgroundColor == null ? AppColors.primaryGradient : null),
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.33),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 15.sp,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
