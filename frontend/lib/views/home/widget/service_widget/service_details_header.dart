import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_controller/favorite_controller.dart';
import 'package:belle_beauty_salon/widgets/network_or_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:belle_beauty_salon/models/service_model.dart';

class ServiceDetailsHeader extends StatelessWidget {
  final String imagePath;
  final String categoryName;
  final String serviceName;
  final ServiceModel service; 

  const ServiceDetailsHeader({
    Key? key,
    required this.imagePath,
    required this.categoryName,
    required this.serviceName,
    required this.service, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FavoriteController favController = Get.find<FavoriteController>();
    return Stack(
      children: [
        NetworkOrAssetImage(
          path: imagePath,
          fallbackAsset: AppImages.hairIcon,
          width: double.infinity,
          height: 350.h,
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.white.withOpacity(0.4),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),

                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => favController.toggleFavorite(service),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Obx(
                        () => Icon(
                          favController.isFavorite(service.serviceName)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favController.isFavorite(service.serviceName)
                              ? Colors.red
                              : Colors.black,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 40.h,
          left: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                serviceName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "TimesNewRoman",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
