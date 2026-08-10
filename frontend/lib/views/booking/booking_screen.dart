import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/booking/booking_controller.dart';
import 'package:belle_beauty_salon/views/home/home_controller/main_controller.dart';
import 'package:belle_beauty_salon/widgets/network_or_asset_image.dart';
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
                    onReschedule: controller.rescheduleAppointment,
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
  final Future<bool> Function(int, DateTime, String)? onReschedule;

  const _AppointmentList({
    required this.appointments,
    required this.showActions,
    required this.emptyLabel,
    this.onCancel,
    this.onReschedule,
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
        onReschedule: onReschedule != null
            ? (d, t) => onReschedule!(i, d, t)
            : null,
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> apt;
  final bool showActions;
  final VoidCallback? onCancel;
  final Future<bool> Function(DateTime, String)? onReschedule;

  const _AppointmentCard({
    required this.apt,
    required this.showActions,
    this.onCancel,
    this.onReschedule,
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
                child: NetworkOrAssetImage(
                  path: apt['image'] as String,
                  fallbackAsset: AppImages.hairIcon,
                  width: 62.r,
                  height: 62.r,
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
                    onTap: onReschedule != null
                        ? () => _showRescheduleSheet(apt, onReschedule!)
                        : () {},
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

const Map<String, String> _reschedulePeriodLabelKeys = {
  'Morning': 'period_morning',
  'Afternoon': 'period_afternoon',
  'Evening': 'period_evening',
};

void _showRescheduleSheet(
  Map<String, dynamic> apt,
  Future<bool> Function(DateTime, String) onConfirm,
) {
  Get.bottomSheet(
    _RescheduleSheet(apt: apt, onConfirm: onConfirm),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _RescheduleSheet extends StatefulWidget {
  final Map<String, dynamic> apt;
  final Future<bool> Function(DateTime, String) onConfirm;

  const _RescheduleSheet({required this.apt, required this.onConfirm});

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  final BookingController controller = Get.find<BookingController>();

  late final List<DateTime> _dates =
      List.generate(14, (i) => DateTime.now().add(Duration(days: i)));

  DateTime? _selectedDate;
  String _selectedTime = '';
  Map<String, List<Map<String, dynamic>>> _slots = {};
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _onDateTap(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedTime = '';
      _isLoadingSlots = true;
    });
    final serviceId = widget.apt['serviceId'] as String?;
    final grouped = serviceId == null
        ? <String, List<Map<String, dynamic>>>{}
        : await controller.availabilityForReschedule(serviceId, date);
    if (!mounted) return;
    setState(() {
      _slots = grouped;
      _isLoadingSlots = false;
    });
  }

  Future<void> _confirm() async {
    if (_selectedDate == null || _selectedTime.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final ok = await widget.onConfirm(_selectedDate!, _selectedTime);
    if (!mounted) return;
    if (ok) {
      Get.back();
      Get.snackbar(
        'reschedule_success_title'.tr,
        'reschedule_success_body'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.white,
        colorText: AppColors.text,
        margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        borderRadius: 14.r,
        duration: const Duration(seconds: 2),
      );
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _selectedDate != null && _selectedTime.isNotEmpty && !_isSubmitting;
    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.w, 16.h, 20.w, 20.h + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'reschedule_title'.tr,
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.apt['serviceName'] as String,
            style: GoogleFonts.outfit(fontSize: 12.sp, color: AppColors.textMuted),
          ),
          SizedBox(height: 16.h),
          Text(
            'select_new_date'.tr,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 82.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemBuilder: (_, i) {
                final d = _dates[i];
                final sel = _selectedDate != null && _isSameDay(_selectedDate!, d);
                return GestureDetector(
                  onTap: () => _onDateTap(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: 8.w),
                    width: 54.w,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.line,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.dayAbbrev(d).toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            color: sel
                                ? AppColors.white.withValues(alpha: 0.8)
                                : AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${d.day}',
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: sel ? AppColors.white : AppColors.text,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          controller.monthAbbrev(d),
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp,
                            color: sel
                                ? AppColors.white.withValues(alpha: 0.8)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          if (_selectedDate != null) ...[
            Text(
              'select_new_time'.tr,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 10.h),
            Flexible(
              child: SingleChildScrollView(
                child: _isLoadingSlots
                    ? Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    : _slots.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: Text(
                              'no_slots_available'.tr,
                              style: GoogleFonts.outfit(
                                fontSize: 12.sp,
                                color: AppColors.textFaint,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _slots.entries.map((entry) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _reschedulePeriodLabelKeys[entry.key]?.tr ??
                                          entry.key,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Wrap(
                                      spacing: 8.w,
                                      runSpacing: 8.h,
                                      children: entry.value.map((slot) {
                                        final t = slot['time'] as String;
                                        final avail = slot['available'] as bool;
                                        final sel = _selectedTime == t;
                                        return GestureDetector(
                                          onTap: avail
                                              ? () => setState(() => _selectedTime = t)
                                              : null,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12.w, vertical: 9.h),
                                            decoration: BoxDecoration(
                                              color: sel
                                                  ? AppColors.primary
                                                  : avail
                                                      ? AppColors.white
                                                      : AppColors.bg,
                                              borderRadius: BorderRadius.circular(10.r),
                                              border: Border.all(
                                                color: sel
                                                    ? AppColors.primary
                                                    : AppColors.line,
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Text(
                                              t,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                color: sel
                                                    ? AppColors.white
                                                    : avail
                                                        ? AppColors.text
                                                        : AppColors.textFaint,
                                                decoration: avail
                                                    ? null
                                                    : TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: canConfirm ? _confirm : null,
            child: Opacity(
              opacity: canConfirm ? 1.0 : 0.45,
              child: Container(
                height: 46.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : Text(
                          'confirm_reschedule'.tr,
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
    );
  }
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
