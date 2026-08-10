import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:belle_beauty_salon/widgets/network_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageServicesScreen extends StatelessWidget {
  const ManageServicesScreen({super.key});

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
            decoration: BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_rounded, color: AppColors.text, size: 16.sp),
          ),
        ),
        title: Text(
          'manage_services_title'.tr,
          style: GoogleFonts.outfit(
              fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.adminAddEditService),
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              width: 36.r,
              height: 36.r,
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Obx(() => SizedBox(
            height: 52.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: ctrl.categories.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _Chip(
                    label: 'all'.tr,
                    selected: ctrl.selectedCategoryId.value.isEmpty,
                    emoji: null,
                    onTap: () => ctrl.selectedCategoryId.value = '',
                  );
                }
                final cat = ctrl.categories[i - 1];
                return _Chip(
                  label: cat.name,
                  emoji: cat.emoji,
                  selected: ctrl.selectedCategoryId.value == cat.id,
                  onTap: () => ctrl.selectedCategoryId.value = cat.id,
                );
              },
            ),
          )),
          // Service list
          Expanded(
            child: Obx(() {
              final list = ctrl.filteredServices;
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'no_services_found'.tr,
                    style: GoogleFonts.outfit(
                        fontSize: 13.sp, color: AppColors.textMuted),
                  ),
                );
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                itemCount: list.length,
                itemBuilder: (_, i) => _ServiceCard(
                  service: list[i],
                  ctrl: ctrl,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;

  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.emoji});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
              color: selected ? Colors.transparent : AppColors.line, width: 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: TextStyle(fontSize: 13.sp)),
              SizedBox(width: 5.w),
            ],
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final AdminService service;
  final AdminController ctrl;

  const _ServiceCard({required this.service, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
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
          // Thumbnail (falls back to the category emoji when no photo is set)
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              gradient: AppColors.softGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: service.image.isEmpty
                ? Center(
                    child: Text(
                      _categoryEmoji(ctrl, service.categoryId),
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  )
                : NetworkOrAssetImage(
                    path: service.image,
                    fallbackAsset: AppImages.hairIcon,
                    width: 64.r,
                    height: 64.r,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'service_duration_price'.trParams({
                    'duration': '${service.durationMins}',
                    'price': service.price.toStringAsFixed(0),
                  }),
                  style: GoogleFonts.outfit(
                      fontSize: 11.sp, color: AppColors.textMuted),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    _Badge(
                        label: service.isActive ? 'service_active_badge'.tr : 'service_inactive_badge'.tr,
                        color: service.isActive
                            ? AppColors.success
                            : AppColors.textFaint),
                    SizedBox(width: 8.w),
                    Text(
                      'bookings_per_week'.trParams({'count': '${service.bookingsPerWeek}'}),
                      style: GoogleFonts.outfit(
                          fontSize: 10.sp, color: AppColors.textFaint),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Edit icon
          GestureDetector(
            onTap: () => Get.toNamed(
                AppRoutes.adminAddEditService,
                arguments: service),
            child: Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(8.r)),
              child: Icon(Icons.edit_outlined,
                  color: AppColors.primary, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(AdminController ctrl, String catId) =>
      ctrl.categories.firstWhereOrNull((c) => c.id == catId)?.emoji ?? '✨';
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
