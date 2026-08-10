import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/widgets/network_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceListItemWidget extends StatefulWidget {
  final String title;
  final String duration;
  final double rating;
  final double prise;
  final String imagePath;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ServiceListItemWidget({
    super.key,
    required this.title,
    required this.duration,
    required this.rating,
    required this.prise,
    required this.imagePath,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  State<ServiceListItemWidget> createState() => _ServiceListItemWidgetState();
}

class _ServiceListItemWidgetState extends State<ServiceListItemWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.r),
          transform: _hovering
              ? (Matrix4.translationValues(0, -2, 0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: _hovering ? AppColors.primarySoft : AppColors.line,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hovering ? 0.1 : 0.05),
                blurRadius: _hovering ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Service image
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: NetworkOrAssetImage(
                  path: widget.imagePath,
                  fallbackAsset: AppImages.hairIcon,
                  width: 72.r,
                  height: 72.r,
                ),
              ),
              SizedBox(width: 14.w),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12.sp, color: AppColors.textFaint),
                        SizedBox(width: 3.w),
                        Text(
                          widget.duration,
                          style: GoogleFonts.outfit(
                              fontSize: 11.sp, color: AppColors.textMuted),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 3.w,
                          height: 3.w,
                          decoration: const BoxDecoration(
                            color: AppColors.textFaint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Icon(Icons.star_rounded,
                            size: 12.sp, color: AppColors.gold),
                        SizedBox(width: 3.w),
                        Text(
                          widget.rating.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'SP ${widget.prise.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              // Right buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onFavoriteTap != null) ...[
                    GestureDetector(
                      onTap: widget.onFavoriteTap,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: widget.isFavorite
                              ? AppColors.chip
                              : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: widget.isFavorite
                              ? AppColors.primary
                              : AppColors.textFaint,
                          size: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
