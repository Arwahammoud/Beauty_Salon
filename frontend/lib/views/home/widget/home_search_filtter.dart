import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/home/home_controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearchFilter extends StatefulWidget {
  const HomeSearchFilter({super.key});

  @override
  State<HomeSearchFilter> createState() => _HomeSearchFilterState();
}

class _HomeSearchFilterState extends State<HomeSearchFilter> {
  bool _filterHovering = false;

  void _showFilterSheet(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    String tempSort = ctrl.filterSortBy.value;
    double tempMinRating = ctrl.filterMinRating.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final isModified = tempSort != 'popular' || tempMinRating > 0;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20.w, 0, 20.w, 24.h + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                // Title + Clear
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter & Sort',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    if (isModified)
                      GestureDetector(
                        onTap: () => setSheet(() {
                          tempSort = 'popular';
                          tempMinRating = 0.0;
                        }),
                        child: Text(
                          'Clear all',
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 22.h),

                // Sort By
                Text(
                  'SORT BY',
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textFaint,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _FilterChip(
                      label: 'Most Popular',
                      isSelected: tempSort == 'popular',
                      onTap: () => setSheet(() => tempSort = 'popular'),
                    ),
                    _FilterChip(
                      label: 'Price: Low → High',
                      isSelected: tempSort == 'price_asc',
                      onTap: () => setSheet(() => tempSort = 'price_asc'),
                    ),
                    _FilterChip(
                      label: 'Price: High → Low',
                      isSelected: tempSort == 'price_desc',
                      onTap: () => setSheet(() => tempSort = 'price_desc'),
                    ),
                    _FilterChip(
                      label: 'Top Rated',
                      isSelected: tempSort == 'rating',
                      onTap: () => setSheet(() => tempSort = 'rating'),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),

                // Min Rating
                Text(
                  'MINIMUM RATING',
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textFaint,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    _RatingChip(
                      label: 'Any',
                      isSelected: tempMinRating == 0.0,
                      onTap: () => setSheet(() => tempMinRating = 0.0),
                    ),
                    _RatingChip(
                      label: '4.0+',
                      isSelected: tempMinRating == 4.0,
                      onTap: () => setSheet(() => tempMinRating = 4.0),
                    ),
                    _RatingChip(
                      label: '4.5+',
                      isSelected: tempMinRating == 4.5,
                      onTap: () => setSheet(() => tempMinRating = 4.5),
                    ),
                    _RatingChip(
                      label: '5.0',
                      isSelected: tempMinRating == 5.0,
                      onTap: () => setSheet(() => tempMinRating = 5.0),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: () {
                        ctrl.filterSortBy.value = tempSort;
                        ctrl.filterMinRating.value = tempMinRating;
                        Get.back();
                      },
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Search bar — taps into search screen
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.line, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.textFaint, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Search services, staff...',
                      style: GoogleFonts.outfit(
                        color: AppColors.textFaint,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Filter button — reactive badge when active
          Obx(() {
            final ctrl = Get.find<HomeController>();
            final isActive = ctrl.isFilterActive;
            return MouseRegion(
              onEnter: (_) => setState(() => _filterHovering = true),
              onExit: (_) => setState(() => _filterHovering = false),
              child: GestureDetector(
                onTap: () => _showFilterSheet(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: EdgeInsets.all(13.w),
                      decoration: BoxDecoration(
                        color: isActive || _filterHovering
                            ? AppColors.primarySoft
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isActive || _filterHovering
                              ? AppColors.primary
                              : AppColors.line,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: isActive || _filterHovering
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: 20.sp,
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 10.r,
                          height: 10.r,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.line,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RatingChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.line,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'Any') ...[
              Icon(
                Icons.star_rounded,
                size: 13.sp,
                color: isSelected ? AppColors.white : AppColors.gold,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
