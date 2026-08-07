import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/booking/booking_controller.dart';
import 'package:belle_beauty_salon/views/home/home_controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingScreen extends StatelessWidget {
  BookingScreen({super.key});

  final BookingController controller = Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Get.find<MainController>().changePage(0),
          child: Container(
            margin: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
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
          'booking_appointments_title'.tr,
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          _TabBar(controller: controller),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              switch (controller.appointmentsTabIndex.value) {
                case 0:
                  return _AppointmentList(
                    appointments: controller.upcomingAppointments,
                    showActions: true,
                    onCancel: controller.cancelAppointment,
                    emptyLabel: 'no_upcoming_appointments'.tr,
                  );
                case 1:
                  return _AppointmentList(
                    appointments: controller.pastAppointments,
                    showActions: false,
                    emptyLabel: 'no_past_appointments'.tr,
                  );
                case 2:
                  return _AppointmentList(
                    appointments: controller.cancelledAppointments,
                    showActions: false,
                    emptyLabel: 'no_cancelled_appointments'.tr,
                  );
                default:
                  return const SizedBox.shrink();
              }
            }),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final BookingController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final labels = ['tab_upcoming'.tr, 'tab_past'.tr, 'tab_cancelled'.tr];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() => Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: List.generate(
                labels.length,
                (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => controller.appointmentsTabIndex.value = i,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      decoration: BoxDecoration(
                        color: controller.appointmentsTabIndex.value == i
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: controller.appointmentsTabIndex.value == i
                                ? AppColors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final bool showActions;
  final String emptyLabel;
  final void Function(int)? onCancel;

  const _AppointmentList({
    required this.appointments,
    required this.showActions,
    required this.emptyLabel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 40.sp, color: AppColors.textFaint),
            SizedBox(height: 12.h),
            Text(
              emptyLabel,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: AppColors.textFaint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: appointments.length,
      itemBuilder: (_, i) => _AppointmentCard(
        apt: appointments[i],
        showActions: showActions,
        onCancel: onCancel != null ? () => onCancel!(i) : null,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> apt;
  final bool showActions;
  final VoidCallback? onCancel;

  const _AppointmentCard({
    required this.apt,
    required this.showActions,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = apt['status'] as String;
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  apt['image'] as String,
                  width: 62.r,
                  height: 62.r,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            apt['serviceName'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _StatusBadge(status: status),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'with_specialist'.trParams({'name': '${apt['specialist']}'}),
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_outlined,
                            size: 13.sp, color: AppColors.primary),
                        SizedBox(width: 4.w),
                        Text(
                          apt['date'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Icon(Icons.access_time_rounded,
                            size: 13.sp, color: AppColors.primary),
                        SizedBox(width: 4.w),
                        Text(
                          apt['time'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showActions) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.line),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'reschedule'.tr,
                    color: AppColors.textMuted,
                    borderColor: AppColors.line,
                    onTap: () => Get.snackbar(
                      'coming_soon_title'.tr,
                      'coming_soon_reschedule_body'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.white,
                      colorText: AppColors.text,
                      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                      borderRadius: 14.r,
                      duration: const Duration(seconds: 2),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    label: 'cancel'.tr,
                    color: AppColors.primary,
                    borderColor: AppColors.primarySoft,
                    onTap: onCancel != null
                        ? () => _showCancelDialog(onCancel!)
                        : () {},
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

void _showCancelDialog(VoidCallback onConfirm) {
  final isLoading = false.obs;
  Get.dialog(
    Obx(
      () => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
        ),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  color: AppColors.primary,
                  size: 26.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'cancel_appointment_title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'cancel_appointment_body'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              if (isLoading.value)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: SizedBox(
                    width: 28.r,
                    height: 28.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: Get.back,
                        child: Container(
                          height: 46.h,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Center(
                            child: Text(
                              'keep_it'.tr,
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          isLoading.value = true;
                          await Future.delayed(
                              const Duration(milliseconds: 1200));
                          Get.back();
                          onConfirm();
                        },
                        child: Container(
                          height: 46.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'yes_cancel'.tr,
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'UPCOMING':
        bg = const Color(0xFFE8F8EF);
        fg = const Color(0xFF27AE60);
        break;
      case 'PAST':
        bg = const Color(0xFFF0F0F0);
        fg = const Color(0xFF888888);
        break;
      default:
        bg = const Color(0xFFFFE8EE);
        fg = AppColors.primary;
    }
    final labelKey = switch (status) {
      'UPCOMING' => 'status_upcoming',
      'PAST' => 'status_past',
      _ => 'status_cancelled',
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        labelKey.tr,
        style: GoogleFonts.outfit(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
