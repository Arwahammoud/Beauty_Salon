import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/home/home_controller/home_controller.dart';
import 'package:belle_beauty_salon/views/home/home_controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text('👋', style: TextStyle(fontSize: 20.sp)),
                ],
              ),
            ],
          ),
          _NotificationBell(onTap: onNotificationTap),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatefulWidget {
  final VoidCallback onTap;
  const _NotificationBell({required this.onTap});

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.primarySoft : AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hovering ? 0.15 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 24.sp,
                color: _hovering ? AppColors.primary : AppColors.text,
              ),
              if (controller.unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16.w,
                    height: 16.h,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${controller.unreadCount}',
                        style: GoogleFonts.outfit(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationPanel extends StatelessWidget {
  final HomeController controller;
  const NotificationPanel({super.key, required this.controller});

  void _onTileTap(int index) {
    final n = controller.notifications[index];
    controller.markNotificationRead(index);
    Get.back(); // close the sheet before navigating

    switch (n['icon']) {
      case 'offer':
        Get.toNamed(AppRoutes.offersScreen);
        break;
      case 'calendar':
        if (Get.isRegistered<MainController>()) {
          Get.find<MainController>().changePage(1); // Booking tab
        }
        break;
      case 'loyalty':
        if (Get.isRegistered<MainController>()) {
          Get.find<MainController>().changePage(4); // Profile tab
        }
        break;
      default:
        // 'star' (review request) has no specific service attached — just
        // marking it read (already done above) is all we can do here.
        break;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'offer': return Icons.local_offer_rounded;
      case 'calendar': return Icons.calendar_today_rounded;
      case 'star': return Icons.star_rounded;
      case 'loyalty': return Icons.card_giftcard_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'offer': return AppColors.primary;
      case 'calendar': return const Color(0xFF3B82F6);
      case 'star': return AppColors.gold;
      case 'loyalty': return const Color(0xFF10B981);
      default: return AppColors.textMuted;
    }
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
          ...controller.notifications.asMap().entries.map((e) => _NotificationTile(
            title: e.value['title'] as String,
            body: e.value['body'] as String,
            time: e.value['time'] as String,
            isRead: e.value['read'] as bool,
            icon: _iconForType(e.value['icon'] as String),
            iconColor: _colorForType(e.value['icon'] as String),
            onTap: () => _onTileTap(e.key),
          )),
        ],
        )),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.iconColor,
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
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
