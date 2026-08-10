import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_controller/favorite_controller.dart';
import 'package:belle_beauty_salon/views/profile/widgets/logout_dialog.dart';
import 'package:belle_beauty_salon/views/profile/widgets/profile_custom_badge.dart';
import 'package:belle_beauty_salon/views/profile/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  final AuthController authController = Get.find<AuthController>();
  final FavoriteController favoriteController = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'profile_title'.tr,
          style: TextStyle(
            color: AppColors.black,
            fontFamily: "TimesNewRoman",
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Center(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      CircleAvatar(
                        radius: 60.r,
                        backgroundImage: AssetImage(AppImages.perosnalImg),
                      ),
                      Material(
                        color: const Color(0xFFF06292),
                        shape: const CircleBorder(),
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            print("تم الضغط على أيقونة تعديل الصورة");
                          },
                          child: Padding(
                            padding: EdgeInsets.all(6.w),
                            child: Icon(
                              Icons.edit,
                              color: AppColors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                Obx(
                  () => Text(
                    authController.currentUser.value?.name ?? 'guest'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Obx(
                  () => Text(
                    authController.currentUser.value?.email ?? 'profile_no_email'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'profile_personal_details'.tr,
                        onTap: () {
                          Get.toNamed(AppRoutes.personalInfo);
                        },
                      ),
                      Obx(
                        () => ProfileMenuItem(
                          icon: Icons.favorite_border,
                          title: 'profile_my_favorites'.tr,
                          trailingWidget: CustomBadge(
                            text:
                                "${favoriteController.favoriteServices.length}",
                            isPink: true,
                          ),
                          onTap: () {
                            Get.toNamed(AppRoutes.favorite);
                          },
                        ),
                      ),
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'profile_settings'.tr,
                        onTap: () {
                          Get.toNamed(AppRoutes.setting);
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'profile_help_support'.tr,
                        onTap: () {
                          Get.toNamed(AppRoutes.helpSupport);
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'profile_privacy_policy'.tr,
                        onTap: () {
                          Get.toNamed(AppRoutes.privacyPolicy);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                CustomPrimaryButton(
                  borderRadius: 18.r,
                  text: 'profile_logout'.tr,
                  icon: Icons.logout_rounded,
                  hasShadow: true,
                  onPressed: () {
                    Get.dialog(const LogoutDialog());
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
