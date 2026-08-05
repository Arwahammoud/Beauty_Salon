import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_icons.dart';
import 'package:belle_beauty_salon/views/booking/booking_controller.dart';
import 'package:belle_beauty_salon/views/booking/booking_screen.dart';
import 'package:belle_beauty_salon/views/chat/chat_screen.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_screen/favorite_screen.dart';
import 'package:belle_beauty_salon/views/home/home_controller/main_controller.dart';
import 'package:belle_beauty_salon/views/home/home_screen/home_screen.dart';
import 'package:belle_beauty_salon/views/profile/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const _kActiveColor = Color(0xFFEC6B9D);
const _kInactiveColor = Color(0xFFB89DAA);

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final MainController controller = Get.put(MainController());
  // ignore: unused_field
  final BookingController _bookingController = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink,
      body: Obx(() {
        switch (controller.currentIndex.value) {
          case 0:
            return HomeScreen();
          case 1:
            return BookingScreen();
          case 2:
            return FavoriteScreen();
          case 3:
            return ChatScreen();
          case 4:
            return ProfileScreen();
          default:
            return HomeScreen();
        }
      }),
      bottomNavigationBar: Obx(
        () => _CustomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
        ),
      ),
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _CustomNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: AppIcons.home, label: 'Home'),
    (icon: AppIcons.booking, label: 'Booking'),
    (icon: AppIcons.saved, label: 'Saved'),
    (icon: AppIcons.chat, label: 'Chat'),
    (icon: AppIcons.profile, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB89DAA).withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            children: List.generate(
              _items.length,
              (i) => _NavItem(
                icon: _items[i].icon,
                label: _items[i].label,
                active: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _kActiveColor : _kInactiveColor;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Line indicator at top
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 2.5.h,
              width: active ? 28.w : 0,
              decoration: BoxDecoration(
                color: active ? _kActiveColor : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
            const Spacer(),
            AnimatedScale(
              scale: active ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: SvgPicture.asset(
                icon,
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: GoogleFonts.outfit(
                fontSize: 10.sp,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
