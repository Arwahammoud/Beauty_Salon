import 'dart:convert';
import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CategoryDetailsController extends GetxController {
  var allServices = <ServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'Popular'.obs;

  final List<String> filters = ['Popular', 'Price: Low', 'Price: High', 'Quick'];

  String categoryName = '';

  @override
  void onInit() {
    super.onInit();
    categoryName = Get.arguments as String? ?? 'Hair';
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading.value = true;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/services.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data[categoryName] as List? ?? [])
          .map((j) => ServiceModel.fromJson(j as Map<String, dynamic>))
          .toList();
      allServices.value = list;
      applyFilter('Popular');
    } catch (_) {
      allServices.value = [];
      filteredServices.value = [];
    }
    isLoading.value = false;
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    var result = List<ServiceModel>.from(allServices);
    switch (filter) {
      case 'Popular':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price: Low':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Quick':
        result = result.where((s) => s.durationMins <= 45).toList();
        break;
    }
    filteredServices.value = result;
  }
}
