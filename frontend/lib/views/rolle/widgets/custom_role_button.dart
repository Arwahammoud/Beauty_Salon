import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRoleButton extends StatefulWidget {
  final String name;
  final String role;
  final String imagePath;
  final VoidCallback onTap;

  const CustomRoleButton({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<CustomRoleButton> createState() => _CustomRoleButtonState();
}

class _CustomRoleButtonState extends State<CustomRoleButton> {
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
          margin: EdgeInsets.only(bottom: 8.r),
          padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.bg : AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _hovering ? AppColors.primary : AppColors.line,
              width: 1,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Avatar
              ClipOval(
                child: Image.asset(
                  widget.imagePath,
                  width: 40.r,
                  height: 40.r,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.r),
              // Name + role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.role,
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: 14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
