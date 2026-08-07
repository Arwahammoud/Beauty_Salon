import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/home/home_controller/home_controller.dart';
import 'package:belle_beauty_salon/views/home/widget/category_section_widgets/category_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({Key? key}) : super(key: key);

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.backgroundMain), 
          fit: BoxFit.cover, 
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'home_categories'.tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontFamily: "TimesNewRoman",
            ),
          ),
        ),
        body: Obx(
          () => GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            physics: const BouncingScrollPhysics(),
            itemCount: controller.categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15.h,
              crossAxisSpacing: 15.w,
              childAspectRatio: 0.99,
            ),
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return CategoryGridCard(
                title: category["title"]!,
                imagePath: category["image"]!,
                servicesCount: category["services"]!,
                onTap: () {
                  Get.toNamed(AppRoutes.categoryServices, arguments: category);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}