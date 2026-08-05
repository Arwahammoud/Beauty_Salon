import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  static const _hours = [
    9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  ];

  static const _weekDays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

    // Compute dates for this week starting today
    final today = DateTime.now();
    // Align to Monday of the current week
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final dates = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration:
                BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.text, size: 16.sp),
          ),
        ),
        title: Text(
          'My Availability',
          style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Instruction text
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                'Tap a slot to block it. Booked slots are read-only.',
                style: GoogleFonts.outfit(
                    fontSize: 11.sp, color: AppColors.textMuted),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Legend
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _LegendDot(color: AppColors.bg, border: AppColors.line, label: 'Available'),
                SizedBox(width: 16.w),
                _LegendDot(color: AppColors.primary, label: 'Booked'),
                SizedBox(width: 16.w),
                _LegendDot(color: const Color(0xFF2D0A14), label: 'Blocked'),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Grid
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day headers
                    Row(
                      children: [
                        SizedBox(width: 44.w), // offset for time column
                        ...List.generate(7, (dayIdx) {
                          final date = dates[dayIdx];
                          final isToday = date.day == today.day &&
                              date.month == today.month;
                          return _DayHeader(
                            day: _weekDays[dayIdx],
                            dateNum: date.day,
                            isToday: isToday,
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Hour rows
                    ...List.generate(_hours.length, (hIdx) {
                      final hour = _hours[hIdx];
                      return Obx(() => Row(
                        children: [
                          // Time label
                          SizedBox(
                            width: 44.w,
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                color: AppColors.textFaint,
                              ),
                            ),
                          ),
                          // Slot cells
                          ...List.generate(7, (dayIdx) {
                            final status = ctrl.getSlotStatus(dayIdx, hour);
                            return _SlotCell(
                              status: status,
                              onTap: () => ctrl.toggleSlot(dayIdx, hour),
                            );
                          }),
                        ],
                      ));
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Block Time section
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w,
                MediaQuery.of(context).padding.bottom + 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Block Time',
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _BlockBtn(
                        label: '+ Block lunch',
                        onTap: () {
                          final todayIdx = today.weekday - 1;
                          ctrl.blockLunch(todayIdx);
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _BlockBtn(
                        label: '+ Day off',
                        onTap: () {
                          final todayIdx = today.weekday - 1;
                          ctrl.blockDay(todayIdx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String day;
  final int dateNum;
  final bool isToday;

  const _DayHeader(
      {required this.day, required this.dateNum, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.outfit(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isToday ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: 22.r,
            height: 22.r,
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$dateNum',
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isToday ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotCell extends StatelessWidget {
  final String status;
  final VoidCallback onTap;

  const _SlotCell({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg;
    bool showDot = false;

    switch (status) {
      case 'booked':
        bg = AppColors.primary;
        showDot = true;
        break;
      case 'blocked':
        bg = const Color(0xFF2D0A14);
        break;
      default:
        bg = AppColors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 38.h,
        margin: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8.r),
          border: status == 'available'
              ? Border.all(color: AppColors.line, width: 0.8)
              : null,
        ),
        child: showDot
            ? Center(
                child: Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final Color? border;
  final String label;

  const _LegendDot({required this.color, required this.label, this.border});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.r,
          height: 12.r,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border != null
                ? Border.all(color: border!, width: 1)
                : null,
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11.sp, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _BlockBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BlockBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.line),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
