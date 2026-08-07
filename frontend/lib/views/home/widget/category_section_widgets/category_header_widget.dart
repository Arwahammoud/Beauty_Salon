import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_controller/favorite_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class CategoryHeaderWidget extends StatelessWidget {
  final String categoryName;
  final int servicesCount;
  // Stable, language-independent identifier for icon/background lookups —
  // falls back to categoryName if not supplied.
  final String? categoryKey;

  const CategoryHeaderWidget({
    super.key,
    required this.categoryName,
    required this.servicesCount,
    this.categoryKey,
  });

  @override
  Widget build(BuildContext context) {
    final key = categoryKey ?? categoryName;
    final bgImage = AppImages.categoryBg(key);
    final iconImage = _iconFor(key);

    return Stack(
      children: [
        // Background image
        Container(
          height: 260.h,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(bgImage),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient overlay (bottom fade to bg)
        Container(
          height: 260.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.bg,
                AppColors.bg.withValues(alpha: 0.7),
                Colors.transparent,
              ],
              stops: const [0.0, 0.25, 0.65],
            ),
          ),
        ),

        // Back + favourite buttons
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleBtn(
                  onTap: () => Get.back(),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18.sp, color: AppColors.text),
                ),
                Obx(() {
                  final favCtrl = Get.find<FavoriteController>();
                  final isFav = favCtrl.isFavoriteCategory(categoryName);
                  return _CircleBtn(
                    onTap: () => favCtrl.toggleFavoriteCategory(categoryName),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18.sp,
                      color: isFav ? AppColors.primary : AppColors.text,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Category icon + name
        Positioned(
          bottom: 20.h,
          left: 20.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                iconImage,
                width: 40.r,
                height: 40.r,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoryName,
                    style: GoogleFonts.outfit(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'services_available_count'.trParams({'count': '$servicesCount'}),
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'hair': return AppImages.hairIcon;
      case 'nails': return AppImages.nailIcon;
      case 'skincare': return AppImages.skinCareIcon;
      case 'laser': return AppImages.lizerIcon;
      case 'spa': return AppImages.spaIcon;
      case 'makeup': return AppImages.makeUpIcon;
      case 'medical': return AppImages.medicalIcon;
      case 'products': return AppImages.productIcon;
      default: return AppImages.hairIcon;
    }
  }
}

class _CircleBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _CircleBtn({required this.child, required this.onTap});

  @override
  State<_CircleBtn> createState() => _CircleBtnState();
}

class _CircleBtnState extends State<_CircleBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: _h
                ? AppColors.surface
                : AppColors.surface.withValues(alpha: 0.82),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
