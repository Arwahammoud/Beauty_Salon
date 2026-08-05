import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/rolle/rolle_controller/role_controller.dart';
import 'package:belle_beauty_salon/views/rolle/widgets/custom_role_button.dart';
import 'package:belle_beauty_salon/views/rolle/widgets/heart_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RolleScreen extends StatelessWidget {
  const RolleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RoleController controller = Get.find<RoleController>();
    final mq = MediaQuery.of(context);
    final usableHeight = mq.size.height - mq.padding.top - mq.padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6BA5), Color(0xFFFF4D88)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── Decorative blobs ─────────────────────────────────────────
          Positioned(top: -80, left: -60, child: _Blob(size: 220, opacity: 0.12)),
          Positioned(top: 130, right: -50, child: _Blob(size: 160, opacity: 0.08)),
          Positioned(bottom: 260, left: -30, child: _Blob(size: 120, opacity: 0.07)),

          // ── Scrollable content (robust on all screen sizes) ──────────
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: usableHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top: logo + texts
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomHeartLogo(),
                            SizedBox(height: 14.h),
                            Text(
                              'welcome_to'.tr,
                              style: GoogleFonts.outfit(
                                color: AppColors.white.withValues(alpha: 0.85),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Belle',
                              style: GoogleFonts.dmSerifDisplay(
                                color: AppColors.white,
                                fontSize: 56.sp,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'tagline'.tr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: AppColors.white.withValues(alpha: 0.85),
                                fontSize: 12.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom: white card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, mq.padding.bottom + 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDeep.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drag handle
                            Container(
                              width: 36.w,
                              height: 4.h,
                              margin: EdgeInsets.only(bottom: 14.h),
                              decoration: BoxDecoration(
                                color: AppColors.line,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),

                            Text(
                              'demo_accounts'.tr,
                              style: GoogleFonts.outfit(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textFaint,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            CustomRoleButton(
                              name: 'Kelly Ahmed',
                              role: 'role_customer'.tr,
                              imagePath: AppImages.perosnalImg,
                              onTap: () => controller.selectRole('CUSTOMER'),
                            ),
                            CustomRoleButton(
                              name: 'Salon Owner',
                              role: 'role_admin'.tr,
                              imagePath: AppImages.perosnalImg,
                              onTap: () => controller.selectRole('ADMIN'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Language toggle (kept last so it sits above the scroll
          // view's full-bounds gesture detector and remains tappable) ──
          Positioned(
            top: mq.padding.top + 12,
            right: 16,
            child: Obx(() => _LangButton(
              isArabic: controller.isArabic.value,
              onTap: controller.toggleLanguage,
            )),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _LangButton extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onTap;
  const _LangButton({required this.isArabic, required this.onTap});

  @override
  State<_LangButton> createState() => _LangButtonState();
}

class _LangButtonState extends State<_LangButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _hovering
                ? AppColors.white.withValues(alpha: 0.35)
                : AppColors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, color: AppColors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                widget.isArabic ? 'AR' : 'EN',
                style: GoogleFonts.outfit(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
