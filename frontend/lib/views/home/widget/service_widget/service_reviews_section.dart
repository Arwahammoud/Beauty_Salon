import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/home/home_controller/service_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ServiceReviewsSection extends StatelessWidget {
  const ServiceReviewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ServiceDetailsController controller =
        Get.find<ServiceDetailsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reviews",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15.h),
        TextField(
          controller: controller.reviewController,
          decoration: InputDecoration(
            hintText: "Write a review...",
            hintStyle: TextStyle(
              color: AppColors.grey.shade500,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 15.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppColors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: AppColors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: const BorderSide(color: Color(0xFFF48FB1)),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFFF48FB1)),
              onPressed: () => controller.submitReview(),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Obx(
          () => Column(
            children: controller.reviewsList.map((review) {
              return _buildReviewCard(
                review["name"]!,
                review["comment"]!,
                review["time"]!,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String name, String comment, String time) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F3).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5.h),
          Text(
            comment,
            style: TextStyle(fontSize: 13.sp, color: AppColors.black),
          ),
          SizedBox(height: 5.h),
          Text(
            time,
            style: TextStyle(fontSize: 11.sp, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
