import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 68.w,
              height: 68.w,
              transform: _hovering
                  ? Matrix4.translationValues(0, -3, 0)
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: _hovering
                    ? const Color(0xFFFFE4EF)
                    : const Color(0xFFFCEFF4),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: _hovering
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : const Color(0xFFF2DDE5),
                  width: 1,
                ),
                boxShadow: _hovering
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Image.asset(
                  widget.imagePath,
                  width: 42.w,
                  height: 42.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: _hovering ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
