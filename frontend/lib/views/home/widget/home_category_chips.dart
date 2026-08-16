import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/home/home_controller/home_controller.dart';
import 'package:belle_beauty_salon/widgets/network_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const _activeGradient = [Color(0xFFEC4899), Color(0xFFE03372)];

class HomeCategoryChips extends StatelessWidget {
  final HomeController controller;
  const HomeCategoryChips({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategoryIndex.value;
      return SizedBox(
        height: 48.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: controller.categories.length,
          separatorBuilder: (_, i) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final cat = controller.categories[i];
            return _CategoryChip(
              label: cat['title']!,
              iconPath: cat['image']!,
              isSelected: selected == i,
              onTap: () => controller.selectedCategoryIndex.value = i,
            );
          },
        ),
      );
    });
  }
}

class _CategoryChip extends StatefulWidget {
  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? const LinearGradient(
                    colors: _activeGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected
                ? null
                : _hovering
                    ? const Color(0xFFFFE4EF)
                    : const Color(0xFFFCEFF4),
            borderRadius: BorderRadius.circular(999.r),
            border: widget.isSelected
                ? null
                : Border.all(
                    color: _hovering
                        ? const Color(0xFFEC4899).withValues(alpha: 0.5)
                        : const Color(0xFFF2DDE5),
                    width: 1,
                  ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24.r,
                height: 24.r,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7.r),
                  child: NetworkOrAssetImage(
                    path: widget.iconPath,
                    fallbackAsset: AppImages.hairIcon,
                    width: 24.r,
                    height: 24.r,
                  ),
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected
                      ? AppColors.white
                      : _hovering
                          ? const Color(0xFFEC4899)
                          : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
