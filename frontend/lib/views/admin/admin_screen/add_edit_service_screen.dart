import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/admin/admin_controller/admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late TextEditingController _priceCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _descCtrl;
  final List<TextEditingController> _benefitCtrls =
      List.generate(3, (_) => TextEditingController());

  String _selectedCategoryId = '';

  static const _staff = [
    (name: 'Layla',  initial: 'L'),
    (name: 'Maya',   initial: 'M'),
    (name: 'Sofia',  initial: 'S'),
    (name: 'Aisha',  initial: 'A'),
    (name: 'Noor',   initial: 'N'),
    (name: 'Dr.',    initial: 'D'),
  ];

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<AdminController>();
    existing = Get.arguments as AdminService?;

    _nameCtrl     = TextEditingController(text: existing?.name ?? '');
    _priceCtrl    = TextEditingController(
        text: existing != null ? existing!.price.toStringAsFixed(0) : '0');
    _durationCtrl = TextEditingController(
        text: existing != null ? '${existing!.durationMins}' : '30');
    _descCtrl     = TextEditingController(text: existing?.description ?? '');
    _selectedCategoryId =
        existing?.categoryId ?? (ctrl.categories.isNotEmpty ? ctrl.categories.first.id : '');

    if (existing != null) {
      final benefits = existing!.benefits;
      for (int i = 0; i < _benefitCtrls.length; i++) {
        _benefitCtrls[i].text = i < benefits.length ? benefits[i] : '';
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _benefitCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Missing name', 'Please enter a service name.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.chip,
          colorText: AppColors.text,
          margin: EdgeInsets.all(16.r));
      return;
    }
    final benefits = _benefitCtrls
        .map((c) => c.text.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    final svc = AdminService(
      id: existing?.id ?? ctrl.newServiceId(),
      name: name,
      categoryId: _selectedCategoryId,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      durationMins: int.tryParse(_durationCtrl.text) ?? 30,
      description: _descCtrl.text.trim(),
      benefits: benefits,
      isActive: existing?.isActive ?? true,
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
              Text('Delete Service?',
                  style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text)),
              SizedBox(height: 6.h),
              Text('This action cannot be undone.',
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
          isEdit ? 'Edit Service' : 'Add new',
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
              child: Text('Save',
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
            // Image placeholder
            Container(
              width: double.infinity,
              height: 180.h,
              color: AppColors.primarySoft,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.spa_rounded,
                      size: 60.sp,
                      color: AppColors.primary.withValues(alpha: 0.3)),
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
                          Text('Change photo',
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

            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _Label('NAME'),
                  SizedBox(height: 6.h),
                  _Field(
                      controller: _nameCtrl,
                      hint: 'e.g. Signature Facial'),
                  SizedBox(height: 16.h),

                  // Category
                  _Label('CATEGORY'),
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
                              Text(
                                cat.name,
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
                            _Label('PRICE (SP)'),
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
                            _Label('DURATION (MIN)'),
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
                  _Label('DESCRIPTION'),
                  SizedBox(height: 6.h),
                  _Field(
                    controller: _descCtrl,
                    hint: 'Service description...',
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),

                  // Benefits
                  _Label('BENEFITS'),
                  SizedBox(height: 6.h),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _Field(
                        controller: _benefitCtrls[i],
                        hint: 'Benefit ${i + 1}',
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Assigned staff (display only)
                  _Label('ASSIGNED STAFF'),
                  SizedBox(height: 10.h),
                  Row(
                    children: _staff.map((s) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              s.initial,
                              style: GoogleFonts.outfit(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                              'Delete Service',
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

// ── Helpers ───────────────────────────────────────────────────────────────────

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
