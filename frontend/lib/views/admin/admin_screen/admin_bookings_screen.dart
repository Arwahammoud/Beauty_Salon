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
          'All Bookings',
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
        itemBuilder: (_, i) => _BookingCard(booking: ctrl.bookings[i]),
      )),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final AdminBooking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final statusLabel = booking.status.toUpperCase();

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
      child: Row(
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
                  booking.clientName,
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
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return AppColors.success;
      case 'pending':   return AppColors.warn;
      case 'cancelled': return AppColors.danger;
      default:          return AppColors.textMuted;
    }
  }
}
