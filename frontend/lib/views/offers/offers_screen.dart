import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/offers/offers_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const List<List<Color>> _gradients = [
  [Color(0xFFFF4D88), Color(0xFFBF2C5E)],
  [Color(0xFF9B2BD4), Color(0xFF6B1490)],
  [Color(0xFFE03372), Color(0xFFBF1A5C)],
];

class OffersScreen extends StatelessWidget {
  OffersScreen({super.key});

  final OffersController controller = Get.put(OffersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: AppColors.text,
            ),
          ),
        ),
        title: Text(
          'Offers & Trends',
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            _SectionLabel('Special Offers'),
            SizedBox(height: 14.h),
            ...controller.offers.asMap().entries.map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _OfferDetailCard(
                    offer: e.value,
                    gradientColors: _gradients[e.key % _gradients.length],
                    onGetOffer: () => controller.onGetOfferTap(e.value),
                  ),
                )),
            SizedBox(height: 8.h),
            _SectionLabel('Trending Now'),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: controller.trendingTags
                  .map((tag) => _TrendingChip(tag: tag))
                  .toList(),
            ),
            SizedBox(height: 30.h),
          ],
        )),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class _OfferDetailCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final List<Color> gradientColors;
  final VoidCallback onGetOffer;

  const _OfferDetailCard({
    required this.offer,
    required this.gradientColors,
    required this.onGetOffer,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: SizedBox(
        height: 155.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(offer['image'] as String, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    gradientColors[0].withValues(alpha: 0.93),
                    gradientColors[1].withValues(alpha: 0.60),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LimitedBadge(label: offer['badge'] as String),
                  const Spacer(),
                  Text(
                    offer['title'] as String,
                    style: GoogleFonts.outfit(
                      color: AppColors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    offer['date'] as String,
                    style: GoogleFonts.outfit(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save',
                            style: GoogleFonts.outfit(
                              color: AppColors.white.withValues(alpha: 0.75),
                              fontSize: 10.sp,
                            ),
                          ),
                          Text(
                            offer['discount'] as String,
                            style: GoogleFonts.outfit(
                              color: AppColors.white,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _GetOfferButton(onTap: onGetOffer),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LimitedBadge extends StatelessWidget {
  final String label;
  const _LimitedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: AppColors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _GetOfferButton extends StatefulWidget {
  final VoidCallback onTap;
  const _GetOfferButton({required this.onTap});

  @override
  State<_GetOfferButton> createState() => _GetOfferButtonState();
}

class _GetOfferButtonState extends State<_GetOfferButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.primarySoft : AppColors.white,
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'get_offer_now'.tr,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: AppColors.text,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 9.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String tag;
  const _TrendingChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.primarySoft, width: 1),
      ),
      child: Text(
        tag,
        style: GoogleFonts.outfit(
          color: AppColors.primary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
