import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    (
      title: '1. Information We Collect',
      body:
          'We collect information you provide directly when you create an account, book an appointment, or contact us. This includes your name, email address, phone number, and appointment history.\n\nWe also collect usage data such as which screens you visit in the app and which services you save to your favourites.',
    ),
    (
      title: '2. How We Use Your Information',
      body:
          'We use your information to:\n• Process and manage your appointments\n• Send booking confirmations and reminders\n• Improve our services and app experience\n• Respond to your support requests\n• Track your loyalty points and membership status',
    ),
    (
      title: '3. Information Sharing',
      body:
          'We do not sell, trade, or rent your personal information to third parties. We may share data with trusted service providers who assist us in operating the app (e.g., hosting and analytics), under strict confidentiality agreements.',
    ),
    (
      title: '4. Data Security',
      body:
          'We implement industry-standard security measures to protect your personal data. Your password is stored in encrypted form and is never visible to our staff. All data is transmitted over secure HTTPS connections.',
    ),
    (
      title: '5. AI Chat Feature',
      body:
          'The in-app chat assistant is powered by a third-party AI service (Groq / Meta Llama). Messages you send in the chat are forwarded to this service to generate responses. Do not share sensitive personal information (such as payment card numbers) in the chat.',
    ),
    (
      title: '6. Your Rights',
      body:
          'You have the right to:\n• Access the personal data we hold about you\n• Request correction of inaccurate data\n• Request deletion of your account and associated data\n• Opt out of marketing communications\n\nTo exercise any of these rights, contact us at support@bellesalon.com.',
    ),
    (
      title: '7. Cookies & Analytics',
      body:
          'The app may use anonymous analytics to understand how users interact with features. This data is aggregated and cannot be used to identify you personally.',
    ),
    (
      title: '8. Children\'s Privacy',
      body:
          'Our services are not directed at children under the age of 13. We do not knowingly collect personal information from children. If you believe a child has provided us with their data, please contact us immediately.',
    ),
    (
      title: '9. Changes to This Policy',
      body:
          'We may update this Privacy Policy from time to time. We will notify you of significant changes through the app or by email. Continued use of the app after changes constitutes acceptance of the updated policy.',
    ),
    (
      title: '10. Contact Us',
      body:
          'If you have any questions about this Privacy Policy, please contact:\n\nBelle Beauty Salon\nEmail: support@bellesalon.com\nPhone: +971 4 000 0000',
    ),
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
          'Privacy Policy',
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
                          'Privacy Policy',
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Last updated: June 2026',
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
              'Your privacy matters to us. This policy explains what information Belle Beauty Salon collects, how we use it, and how we protect it.',
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
