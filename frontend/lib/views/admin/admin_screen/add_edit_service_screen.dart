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

class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({super.key});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  late AdminController ctrl;
  AdminService? existing;
  bool get isEdit => existing != null;

  late TextEditingController _nameCtrl;
  late TextEditingController _nameArCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _descArCtrl;
  final List<TextEditingController> _benefitCtrls =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _benefitArCtrls =
      List.generate(3, (_) => TextEditingController());

  String _selectedCategoryId = '';
  String _selectedSpecialistId = '';
  String _imageUrl = '';
  bool _isActive = true;
  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _isUploadingImage = true);
    try {
      final url = await ApiService.uploadImage('/admin/upload-image', picked);
      setState(() => _imageUrl = url);
    } catch (e) {
      Get.snackbar('error'.tr, '$e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<AdminController>();
    existing = Get.arguments as AdminService?;

    _nameCtrl     = TextEditingController(text: existing?.name ?? '');
    _nameArCtrl   = TextEditingController(text: existing?.nameAr ?? '');
    _priceCtrl    = TextEditingController(
        text: existing != null ? existing!.price.toStringAsFixed(0) : '0');
    _durationCtrl = TextEditingController(
        text: existing != null ? '${existing!.durationMins}' : '30');
    _descCtrl     = TextEditingController(text: existing?.description ?? '');
    _descArCtrl   = TextEditingController(text: existing?.descriptionAr ?? '');
    _selectedCategoryId =
        existing?.categoryId ?? (ctrl.categories.isNotEmpty ? ctrl.categories.first.id : '');
    _selectedSpecialistId = existing != null && existing!.specialistId.isNotEmpty
        ? existing!.specialistId
        : (ctrl.specialists.isNotEmpty ? ctrl.specialists.first.id : '');
    _imageUrl = existing?.image ?? '';
    _isActive = existing?.isActive ?? true;

    if (existing != null) {
      final benefits = existing!.benefits;
      final benefitsAr = existing!.benefitsAr;
      for (int i = 0; i < _benefitCtrls.length; i++) {
        _benefitCtrls[i].text = i < benefits.length ? benefits[i] : '';
        _benefitArCtrls[i].text = i < benefitsAr.length ? benefitsAr[i] : '';
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameArCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    _descArCtrl.dispose();
    for (final c in _benefitCtrls) {
      c.dispose();
    }
    for (final c in _benefitArCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('missing_name_title'.tr, 'missing_name_body'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.chip,
          colorText: AppColors.text,
          margin: EdgeInsets.all(16.r));
      return;
    }

    final parsedPrice = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final parsedDuration = int.tryParse(_durationCtrl.text.trim()) ?? 0;
    if (!AdminController.isValidServiceValues(
      price: parsedPrice,
      durationMins: parsedDuration,
    )) {
      Get.snackbar(
        'Invalid data',
        'Price and duration must be greater than zero.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.chip,
        colorText: AppColors.text,
        margin: EdgeInsets.all(16.r),
      );
      return;
    }

    final benefits = _benefitCtrls
        .map((c) => c.text.trim())
        .where((b) => b.isNotEmpty)
        .toList();
    final benefitsAr = _benefitArCtrls
        .map((c) => c.text.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    final svc = AdminService(
      id: existing?.id ?? ctrl.newServiceId(),
      name: name,
      nameAr: _nameArCtrl.text.trim(),
      categoryId: _selectedCategoryId,
      specialistId: _selectedSpecialistId,
      price: parsedPrice,
      durationMins: parsedDuration,
      description: _descCtrl.text.trim(),
      descriptionAr: _descArCtrl.text.trim(),
      benefits: benefits,
      benefitsAr: benefitsAr,
      image: _imageUrl,
      isActive: _isActive,
      bookingsPerWeek: existing?.bookingsPerWeek ?? 0,
    );

    if (isEdit) {
      ctrl.editService(svc);
    } else {
      ctrl.addService(svc);
    }
    Get.back();
  }

  void _delete() {
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
                    shape: BoxShape.circle),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger, size: 24.sp),
              ),
              SizedBox(height: 12.h),
              Text('delete_service_title'.tr,
                  style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              SizedBox(height: 6.h),
              Text('delete_service_body'.tr,
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
                            child: Text('cancel'.tr,
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
                        ctrl.deleteService(existing!.id);
                        Get.back(); // close dialog
                        Get.back(); // back to services list
                      },
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Center(
                            child: Text('delete'.tr,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration:
                BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
            child: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.text, size: 16.sp),
          ),
        ),
        title: Text(
          isEdit ? 'edit_service_title'.tr : 'add_new_label'.tr,
          style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _save,
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text('save'.tr,
                  style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1, color: AppColors.line),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Image (tap to pick a new photo)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180.h,
                color: AppColors.primarySoft,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isUploadingImage)
                      const CircularProgressIndicator()
                    else if (_imageUrl.isEmpty)
                      Icon(Icons.spa_rounded,
                          size: 60.sp,
                          color: AppColors.primary.withValues(alpha: 0.3))
                    else
                      NetworkOrAssetImage(
                        path: _imageUrl,
                        fallbackAsset: AppImages.hairIcon,
                        width: double.infinity,
                        height: 180.h,
                      ),
                    Positioned(
                      bottom: 12.h,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 12.sp, color: AppColors.text),
                            SizedBox(width: 4.w),
                            Text('change_photo'.tr,
                                style: GoogleFonts.outfit(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _Label('field_name'.tr),
                  SizedBox(height: 6.h),
                  _Field(
                      controller: _nameCtrl,
                      hint: 'name_field_hint'.tr),
                  SizedBox(height: 12.h),
                  _Label('name_ar_label'.tr),
                  SizedBox(height: 6.h),
                  _Field(
                      controller: _nameArCtrl,
                      hint: 'name_ar_hint'.tr),
                  SizedBox(height: 16.h),

                  // Category
                  _Label('field_category'.tr),
                  SizedBox(height: 8.h),
                  Obx(() => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ctrl.categories.map((cat) {
                      final selected = _selectedCategoryId == cat.id;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategoryId = cat.id),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? AppColors.primaryGradient
                                : null,
                            color: selected ? null : AppColors.white,
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : AppColors.line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat.emoji,
                                  style: TextStyle(fontSize: 12.sp)),
                              SizedBox(width: 5.w),
                              Flexible(
                                child: Text(
                                  cat.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                  SizedBox(height: 16.h),

                  // Price + Duration row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('field_price_sp'.tr),
                            SizedBox(height: 6.h),
                            _Field(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('field_duration_min'.tr),
                            SizedBox(height: 6.h),
                            _Field(
                              controller: _durationCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Description
                  _Label('field_description'.tr),
                  SizedBox(height: 6.h),
                  _Field(
                    controller: _descCtrl,
                    hint: 'description_hint'.tr,
                    maxLines: 3,
                  ),
                  SizedBox(height: 12.h),
                  _Field(
                    controller: _descArCtrl,
                    hint: 'description_ar_hint'.tr,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),

                  // Benefits
                  _Label('benefits_label'.tr),
                  SizedBox(height: 6.h),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Column(
                        children: [
                          _Field(
                            controller: _benefitCtrls[i],
                            hint: 'benefit_placeholder'.trParams({'n': '${i + 1}'}),
                          ),
                          SizedBox(height: 6.h),
                          _Field(
                            controller: _benefitArCtrls[i],
                            hint: 'benefit_ar_placeholder'.trParams({'n': '${i + 1}'}),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Assigned staff
                  _Label('field_assigned_staff'.tr),
                  SizedBox(height: 10.h),
                  Obx(() => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ctrl.specialists.map((sp) {
                      final selected = _selectedSpecialistId == sp.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSpecialistId = sp.id),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            gradient: selected ? AppColors.primaryGradient : null,
                            color: selected ? null : AppColors.white,
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                                color: selected ? Colors.transparent : AppColors.line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 26.r,
                                height: 26.r,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    sp.name.isNotEmpty ? sp.name[0].toUpperCase() : '?',
                                    style: GoogleFonts.outfit(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  sp.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.sp,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    color: selected ? Colors.white : AppColors.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                  SizedBox(height: 16.h),

                  // Active toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Label('active_label'.tr),
                      Switch(
                        value: _isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ],
                  ),

                  // Delete button (edit mode only)
                  if (isEdit) ...[
                    SizedBox(height: 28.h),
                    GestureDetector(
                      onTap: _delete,
                      child: Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: AppColors.danger, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'delete_service_button'.tr,
                              style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Helpers 

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontSize: 13.sp, color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.outfit(fontSize: 13.sp, color: AppColors.textFaint),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
