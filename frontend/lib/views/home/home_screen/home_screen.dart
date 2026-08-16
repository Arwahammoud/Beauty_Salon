import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:belle_beauty_salon/models/specialist_model.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_controller/favorite_controller.dart';
import 'package:belle_beauty_salon/views/home/home_controller/home_controller.dart';
import 'package:belle_beauty_salon/views/home/widget/home_category_chips.dart';
import 'package:belle_beauty_salon/views/home/widget/home_header.dart';
import 'package:belle_beauty_salon/views/home/widget/home_offer_card.dart';
import 'package:belle_beauty_salon/views/home/widget/home_category_item.dart';
import 'package:belle_beauty_salon/views/home/widget/home_popular_service_card.dart';
import 'package:belle_beauty_salon/views/home/widget/home_search_filtter.dart';
import 'package:belle_beauty_salon/views/home/widget/home_section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final FavoriteController _favCtrl = Get.find<FavoriteController>();

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) => NotificationPanel(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              //  Header 
              Obx(
                () => HomeHeader(
                  greeting: controller.greetingMessage,
                  userName: controller.userName,
                  onNotificationTap: () => _showNotifications(context),
                ),
              ),

              SizedBox(height: 18.h),

              //  Search bar 
              const HomeSearchFilter(),

              SizedBox(height: 16.h),

              //  Category chips 
              HomeCategoryChips(controller: controller),

              //  Special Offers 
              SectionTitle(
                title: 'home_special_offers'.tr,
                onSeeAll: () => Get.toNamed(AppRoutes.offersScreen),
              ),
              Obx(() {
                final offers = controller.filteredSpecialOffers;
                return SizedBox(
                  height: 230.h,
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemBuilder: (context, index) {
                      final i = index % offers.length;
                      final offer = offers[i];
                      return OfferCard(
                        categoryName: offer['category']!.tr,
                        discount: offer['discount']!.tr,
                        dateRange: offer['date']!.tr,
                        imagePath: offer['image']!,
                        index: i,
                        onBtnTap: () => Get.toNamed(AppRoutes.offersScreen),
                      );
                    },
                  ),
                );
              }),

              //  Categories 
              SectionTitle(
                title: 'home_categories'.tr,
                onSeeAll: () => Get.toNamed(AppRoutes.category),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Obx(
                  () => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (_, index) {
                      final cat = controller.categories[index];
                      return CategoryItem(
                        title: cat['title']!,
                        imagePath: cat['image']!,
                        onTap: () => Get.toNamed(
                          AppRoutes.categoryServices,
                          arguments: cat,
                        ),
                      );
                    },
                  ),
                ),
              ),

              //  Popular Services 
              Obx(
                () => SectionTitle(
                  title: 'home_popular_services'
                      .trParams({'category': controller.selectedCategoryName}),
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.categoryServices,
                    arguments: controller.categories.isNotEmpty
                        ? controller.categories[controller.selectedCategoryIndex.value]
                        : null,
                  ),
                ),
              ),
              Obx(
                () => SizedBox(
                  height: 220.h,
                  child: controller.filteredPopularServices.isEmpty
                      ? _EmptyServices()
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: controller.filteredPopularServices.length,
                          itemBuilder: (_, i) {
                            final s = controller.filteredPopularServices[i];
                            final name = s['name'] as String;
                            final serviceModel = ServiceModel(
                              id: s['id'] as String,
                              categoryName: s['category'] as String,
                              serviceName: name,
                              duration: s['duration'] as String,
                              durationMins: 60,
                              rating: double.tryParse(s['rating'] as String) ?? 4.5,
                              reviewsCount: 0,
                              price: double.tryParse(
                                (s['price'] as String).replaceAll(RegExp(r'[^\d.]'), ''),
                              ) ?? 0.0,
                              image: s['image'] as String,
                              about: '',
                              benefits: const [],
                              specialist: Specialist(
                                name: '', role: '', rating: 0,
                                experienceYears: 0, image: '',
                              ),
                            );
                            return Obx(() => PopularServiceCard(
                              name: name,
                              duration: s['duration'] as String,
                              rating: s['rating'] as String,
                              price: s['price'] as String,
                              imagePath: s['image'] as String,
                              isFavorite: _favCtrl.isFavorite(name),
                              onFavoriteTap: () => _favCtrl.toggleFavorite(serviceModel),
                              onTap: () => Get.toNamed(
                                AppRoutes.serviceDetails,
                                arguments: serviceModel,
                              ),
                            ));
                          },
                        ),
                ),
              ),

              // Bottom padding so last card clears the floating nav bar
              SizedBox(height: MediaQuery.of(context).padding.bottom + 90.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 36.sp, color: AppColors.textFaint),
          SizedBox(height: 8.h),
          Text(
            'home_no_services_category'.tr,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              color: AppColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}
