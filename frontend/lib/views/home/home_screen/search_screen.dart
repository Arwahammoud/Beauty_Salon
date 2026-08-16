import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/home/home_controller/home_controller.dart';
import 'package:belle_beauty_salon/views/home/widget/category_section_widgets/category_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.searchQuery.value = '';
    });
    return Container(
      width: double.infinity,
      height: double.infinity,
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
            onPressed: () => Get.back(),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: EdgeInsets.only(right: 24.w),
            child: Container(
              height: 45.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: const Color(0xFFF48FB1), width: 1.5.w),
              ),
              child: TextField(
                autofocus: true,
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFFF48FB1),
                    size: 22.sp,
                  ),
                  hintText: 'home_search_hint'.tr,
                  hintStyle: TextStyle(
                    color: AppColors.grey.shade400,
                    fontSize: 13.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                style: TextStyle(fontSize: 14.sp, color: AppColors.black),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 35.h),
          child: Obx(() {
            final results = controller.filteredCategories;

            if (controller.searchQuery.value.isEmpty) {
              return Center(
                child: Text(
                  'type_to_search'.tr,
                  style: TextStyle(color: AppColors.black, fontSize: 16.sp),
                ),
              );
            }
            if (results.isEmpty) {
              return Center(
                child: Text(
                  'no_categories_found'.tr,
                  style: TextStyle(color: AppColors.black, fontSize: 16.sp),
                ),
              );
            }
            return GridView.builder(
              padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 20.h),
              physics: const BouncingScrollPhysics(),
              itemCount: results.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15.h,
                crossAxisSpacing: 15.w,
                childAspectRatio: 0.99,
              ),
              itemBuilder: (context, index) {
                final category = results[index];
                return CategoryGridCard(
                  title: category["title"]!,
                  imagePath: category["image"]!,
                  servicesCount: category["services"]!,
                  onTap: () => Get.toNamed(
                    AppRoutes.categoryServices,
                    arguments: category,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}