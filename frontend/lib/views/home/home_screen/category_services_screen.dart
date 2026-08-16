import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_controller/favorite_controller.dart';
import 'package:belle_beauty_salon/views/home/home_controller/category_details_controller.dart';
import 'package:belle_beauty_salon/views/home/widget/category_section_widgets/category_header_widget.dart';
import 'package:belle_beauty_salon/views/home/widget/category_section_widgets/service_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const Map<String, String> _filterLabelKeys = {
  'Popular': 'filter_popular',
  'Price: Low': 'filter_price_low',
  'Price: High': 'filter_price_high',
  'Quick': 'filter_quick',
};

class CategoryServicesScreen extends StatelessWidget {
  CategoryServicesScreen({super.key});

  final CategoryDetailsController controller = Get.put(
    CategoryDetailsController(),
    tag: DateTime.now().millisecondsSinceEpoch.toString(),
  );
  final FavoriteController _favCtrl = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEFF4),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Header 
            // Pull RxList length into local so Obx registers the dependency
            // directly in its scope, not lazily inside a child builder.
            Obx(() {
              final count = controller.allServices.length;
              return CategoryHeaderWidget(
                categoryName: controller.categoryName,
                categoryKey: controller.categoryKey,
                servicesCount: count,
              );
            }),

            //  Filter chips 
            // Pull selectedFilter.value into a local variable before the
            // ListView so Obx tracks it in its own evaluation scope.
            SizedBox(
              height: 44.h,
              child: Obx(() {
                final selected = controller.selectedFilter.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, i) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final f = controller.filters[i];
                    return _FilterChip(
                      label: _filterLabelKeys[f] ?? f,
                      isSelected: selected == f,
                      isFirst: i == 0,
                      onTap: () => controller.applyFilter(f),
                    );
                  },
                );
              }),
            ),

            SizedBox(height: 16.h),

            //  Service list 
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                }
                if (controller.filteredServices.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 40.sp, color: AppColors.textFaint),
                          SizedBox(height: 10.h),
                          Text(
                            'no_services_match_filter'.tr,
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              color: AppColors.textFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 40.h),
                  itemCount: controller.filteredServices.length,
                  itemBuilder: (_, index) {
                    final service = controller.filteredServices[index];
                    return Obx(() => ServiceListItemWidget(
                      title: service.serviceName,
                      duration: service.duration,
                      rating: service.rating,
                      prise: service.price,
                      imagePath: service.image,
                      isFavorite: _favCtrl.isFavorite(service.serviceName),
                      onFavoriteTap: () => _favCtrl.toggleFavorite(service),
                      onTap: () => Get.toNamed(
                        AppRoutes.serviceDetails,
                        arguments: service,
                      ),
                    ));
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

//  Filter chip 

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool isFirst;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isFirst,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.primaryGradient : null,
            color: widget.isSelected
                ? null
                : _hovering
                    ? AppColors.primarySoft
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(999.r),
            border: widget.isSelected
                ? null
                : Border.all(
                    color: _hovering ? AppColors.primary : AppColors.line,
                    width: 1,
                  ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isFirst && widget.isSelected) ...[
                Icon(Icons.star_rounded, size: 13.sp, color: AppColors.gold),
                SizedBox(width: 4.w),
              ],
              Center(
                child: Text(
                  widget.label.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isSelected
                        ? AppColors.white
                        : _hovering
                            ? AppColors.primary
                            : AppColors.textMuted,
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
