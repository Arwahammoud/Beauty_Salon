import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const List<List<Color>> _offerGradients = [
  [Color(0xFFFF4D88), Color(0xFFBF2C5E)],
  [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  [Color(0xFF0891B2), Color(0xFF065F7E)],
];

class OfferCard extends StatefulWidget {
  final String categoryName;
  final String discount;
  final String dateRange;
  final String imagePath;
  final VoidCallback onBtnTap;
  final int index;

  const OfferCard({
    super.key,
    required this.categoryName,
    required this.discount,
    required this.dateRange,
    required this.imagePath,
    required this.onBtnTap,
    this.index = 0,
  });

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final gradientColors = _offerGradients[widget.index % _offerGradients.length];
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        transform: _hovering
            ? (Matrix4.translationValues(0, -4, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: _hovering ? 0.45 : 0.28),
              blurRadius: _hovering ? 28 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Photo on the right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 155.w,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(22.r),
                  bottomRight: Radius.circular(22.r),
                ),
                child: Image.asset(widget.imagePath, fit: BoxFit.cover),
              ),
            ),
            // Gradient fade over image (left edge only)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 180.w,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(22.r),
                    bottomRight: Radius.circular(22.r),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      gradientColors[0],
                      gradientColors[0].withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Text content
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 155.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.categoryName.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.discount,
                    style: GoogleFonts.outfit(
                      color: AppColors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.dateRange,
                    style: GoogleFonts.outfit(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _GetOfferButton(onTap: widget.onBtnTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GetOfferButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GetOfferButton({required this.onTap});

  @override
  State<_GetOfferButton> createState() => _GetOfferButtonState();
}

class _GetOfferButtonState extends State<_GetOfferButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.primarySoft : AppColors.white,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'get_offer_now'.tr,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: AppColors.text,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 9.sp,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
