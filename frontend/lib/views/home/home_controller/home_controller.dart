import 'dart:async';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final selectedCategoryIndex = 0.obs;
  final filterSortBy = 'popular'.obs;   // 'popular' | 'price_asc' | 'price_desc' | 'rating'
  final filterMinRating = 0.0.obs;      // 0.0 = no filter

  bool get isFilterActive =>
      filterSortBy.value != 'popular' || filterMinRating.value > 0;

  void resetFilters() {
    filterSortBy.value = 'popular';
    filterMinRating.value = 0.0;
  }

  final List<Map<String, String>> specialOffers = [
    {
      "category": "HAIRCUT & STYLE",
      "categoryTag": "Hair",
      "discount": "20% Off",
      "date": "May 16 – May 24",
      "image": AppImages.testLizer,
    },
    {
      "category": "SKINCARE SPA",
      "categoryTag": "Skincare",
      "discount": "30% Off",
      "date": "June 1 – June 10",
      "image": AppImages.potoks,
    },
    {
      "category": "NAIL ART",
      "categoryTag": "Nails",
      "discount": "15% Off",
      "date": "Valid Today Only",
      "image": AppImages.testCare,
    },
    {
      "category": "LASER PACKAGE",
      "categoryTag": "Laser",
      "discount": "25% Off",
      "date": "June 15 – June 25",
      "image": AppImages.testLizer,
    },
    {
      "category": "SPA RETREAT",
      "categoryTag": "Spa",
      "discount": "20% Off",
      "date": "July 1 – July 10",
      "image": AppImages.potoks,
    },
  ];

  final categories = <Map<String, String>>[
    {"title": "Hair", "image": AppImages.hairIcon, "services": "6 services"},
    {"title": "Nails", "image": AppImages.nailIcon, "services": "5 services"},
    {"title": "Skincare", "image": AppImages.skinCareIcon, "services": "5 services"},
    {"title": "Laser", "image": AppImages.lizerIcon, "services": "5 services"},
    {"title": "Spa", "image": AppImages.spaIcon, "services": "5 services"},
    {"title": "Makeup", "image": AppImages.makeUpIcon, "services": "5 services"},
    {"title": "Medical", "image": AppImages.medicalIcon, "services": "5 services"},
    {"title": "Products", "image": AppImages.productIcon, "services": "5 services"},
  ].obs;

  final List<Map<String, dynamic>> popularServices = [
    {"name": "Hair Cut & Style", "category": "Hair", "duration": "45 min", "rating": "4.9", "price": "\$35", "image": AppImages.hairSection},
    {"name": "Deep Conditioning", "category": "Hair", "duration": "60 min", "rating": "4.8", "price": "\$50", "image": AppImages.hairSection},
    {"name": "Nail Art Design", "category": "Nails", "duration": "30 min", "rating": "4.7", "price": "\$25", "image": AppImages.nailsSection},
    {"name": "Classic Manicure", "category": "Nails", "duration": "45 min", "rating": "4.9", "price": "\$30", "image": AppImages.nailsSection},
    {"name": "Facial Treatment", "category": "Skincare", "duration": "60 min", "rating": "4.8", "price": "\$65", "image": AppImages.potoks},
    {"name": "Laser Hair Removal", "category": "Laser", "duration": "30 min", "rating": "4.6", "price": "\$80", "image": AppImages.testLizer},
    {"name": "Swedish Massage", "category": "Spa", "duration": "60 min", "rating": "5.0", "price": "\$90", "image": AppImages.potoks},
    {"name": "Bridal Makeup", "category": "Makeup", "duration": "90 min", "rating": "4.9", "price": "\$120", "image": AppImages.testCare},
  ];

  final List<Map<String, dynamic>> notifications = [
    {"title": "New Offer!", "body": "Get 20% off your next haircut this week", "time": "2 min ago", "read": false, "icon": "offer"},
    {"title": "Appointment Reminder", "body": "Your spa session is tomorrow at 3:00 PM", "time": "1 hr ago", "read": false, "icon": "calendar"},
    {"title": "Review Request", "body": "How was your last nail art session? Rate us!", "time": "Yesterday", "read": true, "icon": "star"},
    {"title": "Loyalty Points", "body": "You earned 50 points from your last visit!", "time": "2 days ago", "read": true, "icon": "loyalty"},
  ];

  int get unreadCount => notifications.where((n) => n['read'] == false).length;

  List<Map<String, dynamic>> get filteredPopularServices {
    if (categories.isEmpty) return popularServices;
    final selected = categories[selectedCategoryIndex.value]['title']!;
    var list = popularServices.where((s) => s['category'] == selected).toList();
    if (list.isEmpty) list = List.from(popularServices);

    final minRating = filterMinRating.value;
    if (minRating > 0) {
      list = list.where((s) {
        final r = double.tryParse(s['rating'] as String) ?? 0.0;
        return r >= minRating;
      }).toList();
    }

    switch (filterSortBy.value) {
      case 'price_asc':
        list.sort((a, b) {
          final pa = double.tryParse((a['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final pb = double.tryParse((b['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return pa.compareTo(pb);
        });
        break;
      case 'price_desc':
        list.sort((a, b) {
          final pa = double.tryParse((a['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          final pb = double.tryParse((b['price'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
          return pb.compareTo(pa);
        });
        break;
      case 'rating':
        list.sort((a, b) {
          final ra = double.tryParse(a['rating'] as String) ?? 0;
          final rb = double.tryParse(b['rating'] as String) ?? 0;
          return rb.compareTo(ra);
        });
        break;
    }

    return list;
  }

  String get selectedCategoryName =>
      categories.isEmpty ? 'All' : categories[selectedCategoryIndex.value]['title']!;

  List<Map<String, String>> get filteredSpecialOffers {
    final tag = selectedCategoryName;
    final matches = specialOffers.where((o) => o['categoryTag'] == tag).toList();
    return matches.isEmpty ? specialOffers : matches;
  }

  final searchQuery = ''.obs;

  List<Map<String, String>> get filteredCategories {
    if (searchQuery.value.isEmpty) return [];
    return categories.where((c) {
      return c['title']!.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  late PageController pageController;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 999, viewportFraction: 0.85);
    startAutoPlay();
  }

  void startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (pageController.hasClients) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  String get userName {
    final name = authController.currentUser.value?.name;
    if (name == null || name.isEmpty) return "Beautiful";
    return name.split(" ")[0];
  }

  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}
