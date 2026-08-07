import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/auth/widgets/custom_primary_button.dart';
import 'package:belle_beauty_salon/views/profile/profile_controller/profile_controller.dart';
import 'package:belle_beauty_salon/views/profile/widgets/custom_info_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PersonalInfoScreen extends StatelessWidget {
  PersonalInfoScreen({Key? key}) : super(key: key);

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Personal Details",
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                SizedBox(height: 10.h),

                Center(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      CircleAvatar(
                        radius: 55.r,
                        backgroundImage: AssetImage(AppImages.perosnalImg),
                      ),
                      Material(
                        color: const Color(0xFFF06292),
                        shape: const CircleBorder(),
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            print("تم الضغط لتغيير الصورة");
                          },
                          child: Padding(
                            padding: EdgeInsets.all(6.w),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 35.h),
                CustomInfoField(
                  label: "Full Name",
                  controller: controller.nameController,
                  icon: Icons.person_outline,
                ),
                CustomInfoField(
                  label: "Email Address",
                  controller: controller.emailController,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),

                CustomInfoField(
                  label: "Phone Number",
                  controller: controller.phoneController,
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),

                CustomInfoField(
                  label: "Date of Birth",
                  controller: controller.birthDateController,
                  icon: Icons.cake_outlined,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFFF48FB1),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      controller.birthDateController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                SizedBox(height: 40.h),
                CustomPrimaryButton(
                  borderRadius: 18.r,
                  text: "Save Changes",
                  hasShadow: true,
                  onPressed: () {
                    controller.saveProfileChanges();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
