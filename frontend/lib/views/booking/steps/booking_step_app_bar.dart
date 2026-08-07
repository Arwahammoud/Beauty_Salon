import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

PreferredSizeWidget buildBookingAppBar(String title, int step) {
  return AppBar(
    backgroundColor: AppColors.bg,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16.sp,
          color: AppColors.text,
        ),
      ),
    ),
    title: Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    ),
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(10.h),
      child: BookingStepIndicator(currentStep: step),
    ),
  );
}

class BookingStepIndicator extends StatelessWidget {
  final int currentStep;
  const BookingStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 6.h),
      child: Row(
        children: List.generate(
          3,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              height: 3.h,
              decoration: BoxDecoration(
                color: i <= currentStep ? AppColors.primary : AppColors.line,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
