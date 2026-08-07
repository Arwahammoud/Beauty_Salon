import 'package:belle_beauty_salon/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ServiceAboutSection extends StatelessWidget {
  final String aboutText;
  final List<String> benefits; 

  const ServiceAboutSection({
    Key? key,
    required this.aboutText,
    required this.benefits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('about_this_service'.tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        Text(aboutText, style: TextStyle(fontSize: 14.sp, color: AppColors.grey.shade700, height: 1.5)),

        SizedBox(height: 20.h),

        Text('benefits_label'.tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        
        ...benefits.map((benefit) => Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(color: const Color(0xFFF48FB1).withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.check, size: 16.sp, color: const Color(0xFFF48FB1)),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Text(benefit, style: TextStyle(fontSize: 14.sp, color: Colors.black))),
            ],
          ),
        )).toList(),
      ],
    );
  }
}