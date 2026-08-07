import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  List<({String q, String a})> get _faqs => [
    (q: 'help_faq_q1'.tr, a: 'help_faq_a1'.tr),
    (q: 'help_faq_q2'.tr, a: 'help_faq_a2'.tr),
    (q: 'help_faq_q3'.tr, a: 'help_faq_a3'.tr),
    (q: 'help_faq_q4'.tr, a: 'help_faq_a4'.tr),
    (q: 'help_faq_q5'.tr, a: 'help_faq_a5'.tr),
    (q: 'help_faq_q6'.tr, a: 'help_faq_a6'.tr),
    (q: 'help_faq_q7'.tr, a: 'help_faq_a7'.tr),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'profile_help_support'.tr,
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
            // Header banner
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 26.sp),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'help_banner_title'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'help_banner_subtitle'.tr,
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

            SizedBox(height: 24.h),

            // Contact options
            Text(
              'help_contact_us'.tr,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    label: 'help_contact_email_label'.tr,
                    value: 'support@bellesalon.com',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.phone_outlined,
                    label: 'help_contact_phone_label'.tr,
                    value: '+971 4 000 0000',
                  ),
                ),
              ],
            ),

            SizedBox(height: 28.h),

            // FAQ section
            Text(
              'help_faq_title'.tr,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 10.h),

            ...List.generate(_faqs.length, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _FaqTile(
                    question: _faqs[i].q, answer: _faqs[i].a),
              );
            }),

            SizedBox(height: 20.h),

            // Working hours
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.chip,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.primarySoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          color: AppColors.primary, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'help_working_hours'.tr,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _HoursRow(day: 'help_hours_sat_thu_days'.tr, time: 'help_hours_sat_thu_time'.tr),
                  SizedBox(height: 4.h),
                  _HoursRow(day: 'help_hours_fri_days'.tr, time: 'help_hours_fri_time'.tr),
                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: const BoxDecoration(
              color: AppColors.chip,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                if (_expanded) ...[
                  SizedBox(height: 10.h),
                  Divider(color: AppColors.line, height: 1),
                  SizedBox(height: 10.h),
                  Text(
                    widget.answer,
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      height: 1.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String time;
  const _HoursRow({required this.day, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: GoogleFonts.outfit(
              fontSize: 12.sp, color: AppColors.textMuted),
        ),
        Text(
          time,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
