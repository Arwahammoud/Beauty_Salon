import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNotificationBell extends StatelessWidget {
  const AdminNotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return GestureDetector(
      onTap: () => Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          ),
          constraints: BoxConstraints(maxHeight: 0.8.sh),
          child: AdminNotificationPanel(controller: controller),
        ),
        isScrollControlled: true,
      ),
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(Icons.notifications_none_rounded,
                  color: Colors.white, size: 16.sp),
            ),
            Obx(() {
              final count = controller.unreadCount;
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 15.w,
                  height: 15.h,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: GoogleFonts.outfit(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AdminNotificationPanel extends StatelessWidget {
  final AdminController controller;
  const AdminNotificationPanel({super.key, required this.controller});

  void _onTileTap(int index) {
    controller.markNotificationRead(index);
    Get.back();
    Get.toNamed(AppRoutes.adminBookings);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
        ),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'home_notifications'.tr,
                        style: GoogleFonts.outfit(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.markAllNotificationsRead(),
                        child: Text(
                          'home_mark_all_read'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                if (controller.notifications.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'no_notifications'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 13.sp,
                        color: AppColors.textFaint,
                      ),
                    ),
                  )
                else
                  ...controller.notifications.asMap().entries.map((e) => _AdminNotificationTile(
                        title: e.value['title'] as String,
                        body: e.value['body'] as String,
                        time: e.value['time'] as String,
                        isRead: e.value['read'] as bool,
                        onTap: () => _onTileTap(e.key),
                      )),
              ],
            )),
      ),
    );
  }
}

class _AdminNotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  const _AdminNotificationTile({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.bg,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    time,
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp,
                      color: AppColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
