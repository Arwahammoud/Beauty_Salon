import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();

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
          'all_bookings_label'.tr,
          style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text),
        ),
        centerTitle: true,
      ),
      body: Obx(() => ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: ctrl.bookings.length,
        itemBuilder: (_, i) => _BookingCard(booking: ctrl.bookings[i], ctrl: ctrl),
      )),
    );
  }
}

// Fixed business-hour slots (09:00-19:30, 30 min steps) — mirrors the
// backend's buildDaySlots() in booking.controller.js.
List<String> _timeSlots() {
  final slots = <String>[];
  for (int hour = 9; hour < 20; hour++) {
    for (final minute in [0, 30]) {
      slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }
  }
  return slots;
}

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void _showEditBookingDialog(BuildContext context, AdminController ctrl, AdminBooking booking) {
  String? selectedServiceId = booking.serviceId;
  String? selectedSpecialistId = booking.specialistId;
  DateTime selectedDate = DateTime.tryParse(booking.date) ?? DateTime.now();
  String selectedTime = _timeSlots().contains(booking.time) ? booking.time : _timeSlots().first;

  Get.dialog(
    StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('edit_booking_title'.tr,
                  style: GoogleFonts.outfit(
                      fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.text)),
              SizedBox(height: 16.h),
              Text('field_service'.tr,
                  style: GoogleFonts.outfit(
                      fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                initialValue: selectedServiceId,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                items: ctrl.services
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedServiceId = v),
              ),
              SizedBox(height: 12.h),
              Text('field_specialist'.tr,
                  style: GoogleFonts.outfit(
                      fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                initialValue: selectedSpecialistId,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                items: ctrl.specialists
                    .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setState(() => selectedSpecialistId = v),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('field_date'.tr,
                            style: GoogleFonts.outfit(
                                fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        SizedBox(height: 6.h),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => selectedDate = picked);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(_isoDate(selectedDate),
                                style: GoogleFonts.outfit(fontSize: 13.sp, color: AppColors.text)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('field_time'.tr,
                            style: GoogleFonts.outfit(
                                fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        SizedBox(height: 6.h),
                        DropdownButtonFormField<String>(
                          initialValue: selectedTime,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.bg,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          items: _timeSlots()
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(() => selectedTime = v ?? selectedTime),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Center(
                            child: Text('cancel'.tr,
                                style: GoogleFonts.outfit(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted))),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ctrl.adminEditBooking(
                          booking.id,
                          serviceId: selectedServiceId,
                          specialistId: selectedSpecialistId,
                          date: _isoDate(selectedDate),
                          time: selectedTime,
                        );
                        Get.back();
                      },
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                            child: Text('save'.tr,
                                style: GoogleFonts.outfit(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white))),
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
  );
}

class _BookingCard extends StatelessWidget {
  final AdminBooking booking;
  final AdminController ctrl;
  const _BookingCard({required this.booking, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final statusLabel = _statusLabel(booking.status).toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Initials circle
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primarySoft, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _initials(booking.clientName),
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.clientName.trim().isEmpty
                          ? 'admin_unknown_client'.tr
                          : booking.clientName,
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${booking.serviceName} · ${booking.specialistName}',
                      style: GoogleFonts.outfit(
                          fontSize: 11.sp, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      booking.dateTime,
                      style: GoogleFonts.outfit(
                          fontSize: 11.sp, color: AppColors.textFaint),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SP ${booking.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              if (booking.status == 'pending') ...[
                Expanded(
                  child: _ActionButton(
                    label: 'accept_button'.tr,
                    icon: Icons.check_rounded,
                    color: AppColors.success,
                    onTap: () => ctrl.updateBookingStatus(booking.id, 'confirmed'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _ActionButton(
                    label: 'reject_button'.tr,
                    icon: Icons.close_rounded,
                    color: AppColors.danger,
                    onTap: () => ctrl.updateBookingStatus(booking.id, 'cancelled'),
                  ),
                ),
                SizedBox(width: 8.w),
              ] else if (booking.status == 'confirmed') ...[
                Expanded(
                  child: _ActionButton(
                    label: 'complete_button'.tr,
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    onTap: () => ctrl.updateBookingStatus(booking.id, 'completed'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _ActionButton(
                    label: 'cancel'.tr,
                    icon: Icons.close_rounded,
                    color: AppColors.danger,
                    onTap: () => ctrl.updateBookingStatus(booking.id, 'cancelled'),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              _IconOnlyButton(
                icon: Icons.edit_outlined,
                onTap: () => _showEditBookingDialog(context, ctrl, booking),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0].isNotEmpty ? parts[0][0] : '?';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return AppColors.success;
      case 'pending':   return AppColors.warn;
      case 'completed': return AppColors.primary;
      case 'cancelled': return AppColors.danger;
      default:          return AppColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed': return 'admin_status_confirmed'.tr;
      case 'pending':   return 'admin_status_pending'.tr;
      case 'completed': return 'admin_status_completed'.tr;
      default:          return 'admin_status_cancelled'.tr;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconOnlyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconOnlyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: AppColors.primary, size: 16.sp),
      ),
    );
  }
}