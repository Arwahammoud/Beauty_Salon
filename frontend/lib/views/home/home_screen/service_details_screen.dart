import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/home/home_controller/service_details_controller.dart';
import 'package:belle_beauty_salon/views/home/widget/service_widget/service_about_section.dart';
import 'package:belle_beauty_salon/views/home/widget/service_widget/service_details_header.dart';
import 'package:belle_beauty_salon/views/home/widget/service_widget/service_info_cards.dart';
import 'package:belle_beauty_salon/views/home/widget/service_widget/service_reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ServiceDetailsScreen extends StatelessWidget {
  ServiceDetailsScreen({Key? key}) : super(key: key);

  // Force a fresh controller on every navigation so `service` is always
  // re-initialized from the current Get.arguments.
  static ServiceDetailsController _initController() {
    if (Get.isRegistered<ServiceDetailsController>()) {
      Get.delete<ServiceDetailsController>(force: true);
    }
    return Get.put(ServiceDetailsController());
  }

  final ServiceDetailsController controller = _initController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: CustomPrimaryButton(
          text: 'book_now_price'.trParams({
            'price': '${controller.service.price.toInt()}',
          }),
          onPressed: () => controller.bookNow(),
          borderRadius: 15.r,
          hasShadow: true,
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ServiceDetailsHeader(
              imagePath: controller.service.image, 
              categoryName: controller.service.categoryName, 
              serviceName: controller.service.serviceName, 
              service: controller.service,
            ),

            Transform.translate(
              offset: const Offset(0, -25),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServiceInfoCards(
                      duration: controller.service.duration,
                      price: controller.service.price,
                      rating: controller.service.rating,
                      reviewsCount: controller.service.reviewsCount,
                    ),
                    SizedBox(height: 30.h),

                    ServiceAboutSection(
                      aboutText: controller.service.about,
                      benefits: controller.service.benefits,
                    ),
                    SizedBox(height: 30.h),

                    const ServiceReviewsSection(),

                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
