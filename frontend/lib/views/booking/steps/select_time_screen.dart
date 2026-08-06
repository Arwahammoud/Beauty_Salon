import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/booking/booking_controller.dart';
import 'package:belle_beauty_salon/views/booking/steps/booking_step_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const Map<String, String> _periodEmoji = {
  'Morning': '🌅',
  'Afternoon': '☀️',
  'Evening': '🌙',
};

const Map<String, String> _periodLabelKeys = {
  'Morning': 'period_morning',
  'Afternoon': 'period_afternoon',
  'Evening': 'period_evening',
};

class SelectTimeScreen extends StatelessWidget {
  SelectTimeScreen({super.key});

  final BookingController controller = Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    final serviceName = controller.service?.serviceName ?? 'book_service_fallback'.tr;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: buildBookingAppBar(serviceName, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 28.h),
                  Text(
                    'select_time_title'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Obx(() => Text(
                        controller.bookingSubtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      )),
                  SizedBox(height: 24.h),
                  Obx(() {
                    if (controller.isLoadingSlots.value) {
                      return Padding(
                        padding: EdgeInsets.only(top: 40.h),
                        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.timeSlots.entries.map((entry) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PeriodLabel(
                                label: _periodLabelKeys[entry.key]?.tr ?? entry.key,
                                emoji: _periodEmoji[entry.key] ?? '',
                              ),
                              SizedBox(height: 12.h),
                              Obx(() => GridView.count(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10.h,
                                    crossAxisSpacing: 10.w,
                                    childAspectRatio: 2.4,
                                    children: entry.value.map((slot) {
                                      final t = slot['time'] as String;
                                      final avail = slot['available'] as bool;
                                      final selected =
                                          controller.selectedTime.value == t;
                                      return _TimeSlot(
                                        time: t,
                                        available: avail,
                                        selected: selected,
                                        onTap: avail
                                            ? () => controller.onTimeSelected(t)
                                            : null,
                                      );
                                    }).toList(),
                                  )),
                              SizedBox(height: 24.h),
                            ],
                          )).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
            child: Obx(() {
              final enabled = controller.selectedTime.value.isNotEmpty;
              return Opacity(
                opacity: enabled ? 1.0 : 0.45,
                child: CustomPrimaryButton(
                  text: 'continue_btn'.tr,
                  onPressed: controller.goToSummary,
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

class _PeriodLabel extends StatelessWidget {
  final String label;
  final String emoji;
  const _PeriodLabel({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 16.sp)),
        SizedBox(width: 6.w),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String time;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  const _TimeSlot({
    required this.time,
    required this.available,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : available
                  ? AppColors.white
                  : AppColors.bg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            time,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: selected
                  ? AppColors.white
                  : available
                      ? AppColors.text
                      : AppColors.textFaint,
              decoration: available ? null : TextDecoration.lineThrough,
              decorationColor: AppColors.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}
