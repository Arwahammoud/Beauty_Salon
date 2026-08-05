import 'dart:convert';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OffersController extends GetxController {
  var isLoading = false.obs;
  final _services = <String, List<ServiceModel>>{};

  final List<Map<String, dynamic>> offers = [
    {
      'badge': 'LIMITED',
      'title': '20% Off Haircut',
      'date': 'May 16 – May 24',
      'discount': '20%',
      'image': AppImages.hairSection,
      'serviceCategory': 'Hair',
      'serviceIndex': 0,
      'gradientIndex': 0,
    },
    {
      'badge': 'LIMITED',
      'title': 'Glow Bundle',
      'date': 'Limited time',
      'discount': '30%',
      'image': AppImages.potoks,
      'serviceCategory': 'Skincare',
      'serviceIndex': 1,
      'gradientIndex': 1,
    },
    {
      'badge': 'LIMITED',
      'title': 'Bridal Package',
      'date': 'May 20 – Jun 15',
      'discount': '15%',
      'image': AppImages.makeupSection,
      'serviceCategory': 'Makeup',
      'serviceIndex': 1,
      'gradientIndex': 2,
    },
  ];

  final List<String> trendingTags = [
    '#BalayageVibes',
    '#HydraGlow',
    '#BridalSeason',
    '#NailArtMay',
    '#KeratinSmooth',
    '#SpaSunday',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadServices();
  }

  Future<void> _loadServices() async {
    isLoading.value = true;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/services.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      data.forEach((key, value) {
        _services[key] = (value as List)
            .map((j) => ServiceModel.fromJson(j as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {}
    isLoading.value = false;
  }

  void onGetOfferTap(Map<String, dynamic> offer) {
    final cat = offer['serviceCategory'] as String;
    final idx = offer['serviceIndex'] as int;
    final list = _services[cat];
    if (list != null && list.isNotEmpty) {
      Get.toNamed(
        AppRoutes.serviceDetails,
        arguments: list[idx.clamp(0, list.length - 1)],
      );
    }
  }
}
