import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/widgets/network_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryGridCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String servicesCount;
  final VoidCallback onTap;

  const CategoryGridCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.servicesCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFB3AEAE), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Positioned(
                top: -20.h,
                right: -20.w,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEB8C5).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.w, bottom: 20.h),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12.sp,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: NetworkOrAssetImage(
                        path: imagePath,
                        fallbackAsset: AppImages.hairIcon,
                        width: 70.w,
                        height: 70.h,
                      ),
                    ),
                    // const Spacer(), // بتدفش النصوص لتحت
                    SizedBox(height: 8.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      servicesCount,
                      style: TextStyle(
                        fontFamily: "TimesNewRoman",
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
