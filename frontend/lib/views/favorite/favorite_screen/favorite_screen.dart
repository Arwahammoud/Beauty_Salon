import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_controller/favorite_controller.dart';
import 'package:belle_beauty_salon/views/favorite/widget/favorite_item_widget.dart';
import 'package:belle_beauty_salon/views/home/home_controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteScreen extends StatelessWidget {
  FavoriteScreen({Key? key}) : super(key: key);

  final FavoriteController controller = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: canPop
              ? () => Get.back()
              : () => Get.find<MainController>().changePage(0),
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
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16.sp, color: AppColors.text),
          ),
        ),
        title: Text(
          'Saved',
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final count = controller.favoriteServices.length;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '$count saved',
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.favoriteServices.isEmpty) {
          return _EmptyState();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            // Category filter chips
            Obx(() {
              final filters = controller.availableFilters;
              if (filters.length <= 1) return const SizedBox.shrink();
              return SizedBox(
                height: 42.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final f = filters[i];
                    return Obx(() => _FilterChip(
                          label: f,
                          selected: controller.selectedCategoryFilter == f,
                          onTap: () => controller.setFilter(f),
                        ));
                  },
                ),
              );
            }),
            SizedBox(height: 14.h),
            Expanded(
              child: Obx(() {
                final items = controller.filteredByCategory;
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No services in this category',
                      style: GoogleFonts.outfit(
                          fontSize: 13.sp, color: AppColors.textFaint),
                    ),
                  );
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final service = items[i];
                    return FavoriteItemWidget(
                      service: service,
                      onCardTap: () => Get.toNamed(
                        AppRoutes.serviceDetails,
                        arguments: service,
                      ),
                      onFavoriteTap: () => controller.toggleFavorite(service),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE8F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppImages.brokenHeard,
                width: 46.r,
                height: 46.r,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Nothing saved yet',
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the ♡ on any service to save it here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: selected ? null : Border.all(color: AppColors.line),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
