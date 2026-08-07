import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

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
            decoration: BoxDecoration(
              color: AppColors.chip,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.text, size: 16.sp),
          ),
        ),
        title: Text(
          'Manage Categories',
          style: GoogleFonts.outfit(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => _showCategoryDialog(context, ctrl),
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              width: 36.r,
              height: 36.r,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: ctrl.categories.length,
        itemBuilder: (_, i) {
          final cat = ctrl.categories[i];
          return _CategoryCard(
            category: cat,
            onEdit: () => _showCategoryDialog(context, ctrl, existing: cat),
            onDelete: () => _confirmDelete(context, ctrl, cat),
          );
        },
      )),
    );
  }

  void _showCategoryDialog(BuildContext context, AdminController ctrl,
      {AdminCategory? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '✨');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existing == null ? 'Add Category' : 'Edit Category',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 16.h),
              _DialogField(label: 'Emoji', controller: emojiCtrl, hint: 'e.g. ✂️'),
              SizedBox(height: 12.h),
              _DialogField(label: 'Name', controller: nameCtrl, hint: 'e.g. Hair'),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final name = nameCtrl.text.trim();
                        final emoji = emojiCtrl.text.trim();
                        if (name.isEmpty) return;
                        if (existing == null) {
                          ctrl.addCategory(name, emoji.isEmpty ? '✨' : emoji);
                        } else {
                          ctrl.editCategory(existing.id, name,
                              emoji.isEmpty ? existing.emoji : emoji);
                        }
                        Get.back();
                      },
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text('Save',
                              style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
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

  void _confirmDelete(
      BuildContext context, AdminController ctrl, AdminCategory cat) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger, size: 24.sp),
              ),
              SizedBox(height: 12.h),
              Text('Delete "${cat.name}"?',
                  style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              SizedBox(height: 6.h),
              Text('This will not delete the services inside it.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 12.sp, color: AppColors.textMuted)),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Center(
                            child: Text('Cancel',
                                style: GoogleFonts.outfit(
                                    fontSize: 13.sp,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ctrl.deleteCategory(cat.id);
                        Get.back();
                      },
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                            child: Text('Delete',
                                style: GoogleFonts.outfit(
                                    fontSize: 13.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700))),
                      ),
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

class _CategoryCard extends StatelessWidget {
  final AdminCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard(
      {required this.category, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
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
          // Emoji circle
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: AppColors.chip,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(category.emoji, style: TextStyle(fontSize: 22.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${category.serviceCount} services · ${category.isActive ? "active" : "inactive"}',
                  style: GoogleFonts.outfit(
                      fontSize: 11.sp, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Edit button
          _IconBtn(
            icon: Icons.edit_outlined,
            color: AppColors.primary,
            bg: AppColors.chip,
            onTap: onEdit,
          ),
          SizedBox(width: 8.w),
          // Delete button
          _IconBtn(
            icon: Icons.delete_outline_rounded,
            color: AppColors.danger,
            bg: AppColors.danger.withValues(alpha: 0.08),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _IconBtn(
      {required this.icon,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _DialogField(
      {required this.label, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(fontSize: 13.sp, color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
                fontSize: 13.sp, color: AppColors.textFaint),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
