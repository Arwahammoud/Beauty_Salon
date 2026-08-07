import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/booking/booking_controller.dart';
import 'package:belle_beauty_salon/views/booking/steps/booking_step_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectDateScreen extends StatelessWidget {
  SelectDateScreen({super.key});

  final BookingController controller = Get.isRegistered<BookingController>()
      ? Get.find<BookingController>()
      : Get.put(BookingController());

  List<DateTime> get _dates {
    final now = DateTime.now();
    return List.generate(14, (i) => now.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final serviceName = controller.service?.serviceName ?? 'book_service_fallback'.tr;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: buildBookingAppBar(serviceName, 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 28.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'select_date_title'.tr,
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 96.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _dates.length,
              itemBuilder: (_, i) {
                final d = _dates[i];
                return Obx(() {
                  final sel = controller.selectedDate.value != null &&
                      _isSameDay(controller.selectedDate.value!, d);
                  return _DateCard(
                    date: d,
                    selected: sel,
                    dayAbbrev: controller.dayAbbrev(d).toUpperCase(),
                    monthAbbrev: controller.monthAbbrev(d),
                    onTap: () => controller.onDateSelected(d),
                  );
                });
              },
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
            child: Obx(() {
              final enabled = controller.selectedDate.value != null;
              return Opacity(
                opacity: enabled ? 1.0 : 0.45,
                child: CustomPrimaryButton(
                  text: 'continue_btn'.tr,
                  onPressed: controller.goToSelectTime,
                  borderRadius: 15.r,
                  hasShadow: enabled,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final String dayAbbrev;
  final String monthAbbrev;
  final VoidCallback onTap;

  const _DateCard({
    required this.date,
    required this.selected,
    required this.dayAbbrev,
    required this.monthAbbrev,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        width: 60.w,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayAbbrev,
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: selected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : AppColors.textMuted,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${date.day}',
              style: GoogleFonts.outfit(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.text,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              monthAbbrev,
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                color: selected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
