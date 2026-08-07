import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ServiceInfoCards extends StatelessWidget {
  final String duration;
  final double price;
  final double rating;
  final int reviewsCount;

  const ServiceInfoCards({
    Key? key,
    required this.duration,
    required this.price,
    required this.rating,
    required this.reviewsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoCard(
          Icons.access_time_rounded,
          const Color(0xFFF48FB1),
          'duration_label'.tr,
          duration,
        ),
        _buildInfoCard(
          Icons.attach_money_rounded,
          const Color(0xFFF48FB1),
          'price_label'.tr,
          "SP ${price.toInt()}",
        ),
        _buildInfoCard(
          Icons.star_rounded,
          Colors.orange,
          'reviews_label'.tr,
          "$rating ($reviewsCount)",
        ),
      ],
    );
  }

  // 💡 [شرح]: دالة بتبني المربع الواحد مشان ما نكتب كود المربع 3 مرات
  Widget _buildInfoCard(
    IconData icon,
    Color iconColor,
    String title,
    String value,
  ) {
    return Container(
      width: 105.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24.sp),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: AppColors.grey.shade600),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
