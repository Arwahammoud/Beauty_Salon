import 'dart:io';

import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:belle_beauty_salon/widgets/network_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.text,
              size: 16.sp,
            ),
          ),
        ),
        title: Text(
          'manage_categories_title'.tr,
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
      body: Obx(
        () => ListView.builder(
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
        ),
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    AdminController ctrl, {
    AdminCategory? existing,
  }) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final nameArCtrl = TextEditingController(text: existing?.nameAr ?? '');
    final emojiCtrl = TextEditingController(text: existing?.emoji ?? '✨');
    final imageUrl = (existing?.image ?? '').obs;
    final isActive = (existing?.isActive ?? true).obs;
    final isUploading = false.obs;

    Future<void> pickImage() async {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      isUploading.value = true;
      try {
        imageUrl.value = await ApiService.uploadImage(
          '/admin/upload-image',
          File(picked.path),
        );
      } catch (e) {
        Get.snackbar('error'.tr, '$e');
      } finally {
        isUploading.value = false;
      }
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppColors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'add_category'.tr : 'edit_category'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Obx(
                      () => Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          color: AppColors.chip,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isUploading.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : imageUrl.value.isEmpty
                            ? Center(
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppColors.textMuted,
                                  size: 22.sp,
                                ),
                              )
                            : NetworkOrAssetImage(
                                path: imageUrl.value,
                                fallbackAsset: AppImages.hairIcon,
                                width: 72.r,
                                height: 72.r,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _DialogField(
                  label: 'emoji_label'.tr,
                  controller: emojiCtrl,
                  hint: 'emoji_hint'.tr,
                ),
                SizedBox(height: 12.h),
                _DialogField(
                  label: 'name_label'.tr,
                  controller: nameCtrl,
                  hint: 'name_hint'.tr,
                ),
                SizedBox(height: 12.h),
                _DialogField(
                  label: 'name_ar_label'.tr,
                  controller: nameArCtrl,
                  hint: 'name_ar_hint'.tr,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'active_label'.tr,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Obx(
                      () => Switch(
                        value: isActive.value,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => isActive.value = v,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
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
                            child: Text(
                              'cancel'.tr,
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final name = nameCtrl.text.trim();
                          final nameAr = nameArCtrl.text.trim();
                          final emoji = emojiCtrl.text.trim();
                          if (name.isEmpty) return;
                          if (existing == null) {
                            ctrl.addCategory(
                              name,
                              emoji.isEmpty ? '✨' : emoji,
                              nameAr: nameAr,
                              image: imageUrl.value,
                            );
                          } else {
                            ctrl.editCategory(
                              existing.id,
                              name,
                              emoji.isEmpty ? existing.emoji : emoji,
                              nameAr: nameAr,
                              image: imageUrl.value,
                              isActive: isActive.value,
                            );
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
                            child: Text(
                              'save'.tr,
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminController ctrl,
    AdminCategory cat,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
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
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'delete_category_confirm'.trParams({'name': cat.name}),
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'delete_category_body'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                ),
              ),
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
                          child: Text(
                            'cancel'.tr,
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
                          child: Text(
                            'delete'.tr,
                            style: GoogleFonts.outfit(
                              fontSize: 13.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
}

class _CategoryCard extends StatelessWidget {
  final AdminCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

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
          // Photo (falls back to the emoji circle when no image is set)
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: AppColors.chip,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: category.image.isEmpty
                ? Center(
                    child: Text(
                      category.emoji,
                      style: TextStyle(fontSize: 22.sp),
                    ),
                  )
                : NetworkOrAssetImage(
                    path: category.image,
                    fallbackAsset: AppImages.hairIcon,
                    width: 46.r,
                    height: 46.r,
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
                  'category_services_status'.trParams({
                    'count': '${category.serviceCount}',
                    'status': category.isActive ? 'active'.tr : 'inactive'.tr,
                  }),
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
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

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _DialogField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          style: GoogleFonts.outfit(fontSize: 13.sp, color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textFaint,
            ),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 10.h,
            ),
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
