import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  List<({String title, String body})> get _sections => [
    (title: 'privacy_title_1'.tr, body: 'privacy_body_1'.tr),
    (title: 'privacy_title_2'.tr, body: 'privacy_body_2'.tr),
    (title: 'privacy_title_3'.tr, body: 'privacy_body_3'.tr),
    (title: 'privacy_title_4'.tr, body: 'privacy_body_4'.tr),
    (title: 'privacy_title_5'.tr, body: 'privacy_body_5'.tr),
    (title: 'privacy_title_6'.tr, body: 'privacy_body_6'.tr),
    (title: 'privacy_title_7'.tr, body: 'privacy_body_7'.tr),
    (title: 'privacy_title_8'.tr, body: 'privacy_body_8'.tr),
    (title: 'privacy_title_9'.tr, body: 'privacy_body_9'.tr),
    (title: 'privacy_title_10'.tr, body: 'privacy_body_10'.tr),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'profile_privacy_policy'.tr,
          style: TextStyle(
            color: AppColors.black,
            fontFamily: 'TimesNewRoman',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.privacy_tip_outlined,
                        color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_privacy_policy'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'privacy_last_updated'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Intro
            Text(
              'privacy_intro'.tr,
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                height: 1.65,
                color: AppColors.textMuted,
              ),
            ),

            SizedBox(height: 20.h),

            // Sections
            ...List.generate(_sections.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _PolicySection(
                    title: _sections[i].title, body: _sections[i].body),
              );
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              height: 1.65,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
