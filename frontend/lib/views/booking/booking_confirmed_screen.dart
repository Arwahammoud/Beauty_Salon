import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/booking/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingConfirmedScreen extends StatelessWidget {
  BookingConfirmedScreen({super.key});

  final BookingController controller = Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    final service = controller.service!;
    return Scaffold(
      body: Stack(
        children: [
          // Pink gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6BA8), Color(0xFFE03372)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative floating bubbles
          ..._bubbles(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Checkmark circle
                Container(
                  width: 90.r,
                  height: 90.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 68.r,
                      height: 68.r,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 36.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                Text(
                  'booking_confirmed_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'booking_confirmed_body'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),

                const Spacer(),

                // White bottom card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 32.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.r),
                      topRight: Radius.circular(32.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              service.image,
                              width: 56.r,
                              height: 56.r,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.serviceName,
                                style: GoogleFonts.outfit(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'with_specialist'.trParams({'name': service.specialist.name}),
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            _InfoColumn(
                              label: 'date_label'.tr,
                              value: controller.confirmedDateLabel,
                            ),
                            _VerticalDivider(),
                            _InfoColumn(
                              label: 'time_label'.tr,
                              value: controller.selectedTime.value,
                            ),
                            _VerticalDivider(),
                            _InfoColumn(
                              label: 'earned_label'.tr,
                              value: 'earned_points_value'.trParams({
                                'points': '${controller.earnedPoints}',
                              }),
                              valueColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Row(
                        children: [
                          Expanded(
                            child: _OutlinedBtn(
                              label: 'back_to_home'.tr,
                              onTap: controller.goHome,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _FilledBtn(
                              label: 'view_booking'.tr,
                              onTap: controller.viewBooking,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _bubbles() {
    final configs = [
      (left: 20.0, top: 80.0, size: 14.0, opacity: 0.20),
      (left: 80.0, top: 55.0, size: 8.0, opacity: 0.15),
      (left: null as double?, top: 100.0, size: 12.0, opacity: 0.18),
      (left: null as double?, top: 60.0, size: 20.0, opacity: 0.12),
      (left: 50.0, top: 200.0, size: 7.0, opacity: 0.15),
      (left: null as double?, top: 180.0, size: 10.0, opacity: 0.13),
      (left: 150.0, top: 130.0, size: 16.0, opacity: 0.10),
      (left: 30.0, top: 300.0, size: 9.0, opacity: 0.14),
    ];

    final rights = [null, null, 30.0, 50.0, null, 40.0, null, null];

    return List.generate(configs.length, (i) {
      final c = configs[i];
      return Positioned(
        left: c.left,
        right: rights[i],
        top: c.top,
        child: Container(
          width: c.size,
          height: c.size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: c.opacity),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoColumn({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textFaint,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      color: AppColors.line,
    );
  }
}

class _OutlinedBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlinedBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primarySoft, width: 1.2),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilledBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
