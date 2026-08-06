import 'dart:async';
import 'package:belle_beauty_salon/constant/app_images.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/utils/relative_time.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final selectedCategoryIndex = 0.obs;
  final filterSortBy = 'popular'.obs;   // 'popular' | 'price_asc' | 'price_desc' | 'rating'
  final filterMinRating = 0.0.obs;

  final isLoading = false.obs;

  bool get isFilterActive =>
      filterSortBy.value != 'popular' || filterMinRating.value > 0;

  void resetFilters() {
    filterSortBy.value = 'popular';
    filterMinRating.value = 0.0;
  }

  // The backend doesn't host category images yet — map by title locally.
  static const Map<String, String> _categoryIcons = {
    'Hair': AppImages.hairIcon,
    'Nails': AppImages.nailIcon,
    'Skincare': AppImages.skinCareIcon,
    'Laser': AppImages.lizerIcon,
    'Spa': AppImages.spaIcon,
    'Makeup': AppImages.makeUpIcon,
    'Medical': AppImages.medicalIcon,
    'Products': AppImages.productIcon,
  };

  // Home screen promo carousel — no dedicated backend model for this yet
  // (see /offers for the real Offers screen data), kept as editorial content.
  // 'category'/'discount'/'date' hold translation KEYS, resolved with .tr at
  // display time — 'categoryTag' stays a raw English identifier used only to
  // match against the (also backend-localized) selected category name.
  final List<Map<String, String>> specialOffers = [
    {
      "category": "home_offer_hair_title",
      "categoryTag": "Hair",
      "discount": "home_offer_hair_discount",
      "date": "home_offer_hair_date",
      "image": AppImages.testLizer,
    },
    {
      "category": "home_offer_skincare_title",
      "categoryTag": "Skincare",
      "discount": "home_offer_skincare_discount",
      "date": "home_offer_skincare_date",
      "image": AppImages.potoks,
    },
    {
      "category": "home_offer_nails_title",
      "categoryTag": "Nails",
      "discount": "home_offer_nails_discount",
      "date": "home_offer_nails_date",
      "image": AppImages.testCare,
    },
    {
      "category": "home_offer_laser_title",
      "categoryTag": "Laser",
      "discount": "home_offer_laser_discount",
      "date": "home_offer_laser_date",
      "image": AppImages.testLizer,
    },
    {
      "category": "home_offer_spa_title",
      "categoryTag": "Spa",
      "discount": "home_offer_spa_discount",
      "date": "home_offer_spa_date",
      "image": AppImages.potoks,
    },
  ];

  final categories = <Map<String, String>>[].obs;
  final popularServices = <Map<String, dynamic>>[].obs;
  final notifications = <Map<String, dynamic>>[].obs;

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
      categories.isEmpty ? 'all'.tr : categories[selectedCategoryIndex.value]['title']!;

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
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    try {
      final catData = await ApiService.get('/categories');
      final items = (catData['items'] as List).cast<Map<String, dynamic>>();
      categories.value = items.map((c) => {
        'id': c['id'].toString(),
        'title': c['title'] as String,
        'image': _categoryIcons[c['title']] ?? AppImages.hairIcon,
        'services': '${c['servicesCount']} services',
      }).toList();

      final popularData = await ApiService.get('/services/popular');
      final popularItems = (popularData['items'] as List).cast<Map<String, dynamic>>();
      popularServices.value = popularItems.map((s) => {
        'id': s['id'].toString(),
        'name': s['serviceName'],
        'category': s['categoryName'],
        'duration': s['duration'],
        'rating': s['rating'].toString(),
        'price': 'SP ${s['price']}',
        'image': s['image'],
      }).toList();

      await loadNotifications();
    } catch (_) {
      // Keep the screen usable even if the backend isn't reachable yet.
    }
    isLoading.value = false;
  }

  Future<void> loadNotifications() async {
    try {
      final data = await ApiService.get('/users/me/notifications', auth: true);
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      notifications.value = items.map((n) => {
        'id': n['id'].toString(),
        'title': n['title'],
        'body': n['body'],
        'time': relativeTime(n['createdAt'] as String),
        'read': n['read'] as bool,
        'icon': n['icon'],
      }).toList();
    } catch (_) {
      notifications.value = [];
    }
  }

  Future<void> markNotificationRead(int index) async {
    if (index < 0 || index >= notifications.length) return;
    if (notifications[index]['read'] == true) return;
    final id = notifications[index]['id'];
    notifications[index]['read'] = true;
    notifications.refresh();
    try {
      await ApiService.post('/users/me/notifications/$id/read', auth: true);
    } catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    final unreadIndexes = <int>[
      for (int i = 0; i < notifications.length; i++)
        if (notifications[i]['read'] == false) i,
    ];
    for (final i in unreadIndexes) {
      notifications[i]['read'] = true;
    }
    notifications.refresh();
    for (final i in unreadIndexes) {
      final id = notifications[i]['id'];
      try {
        await ApiService.post('/users/me/notifications/$id/read', auth: true);
      } catch (_) {}
    }
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
    if (name == null || name.isEmpty) return 'home_greeting_fallback_name'.tr;
    return name.split(" ")[0];
  }

  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home_greeting_morning'.tr;
    if (hour < 17) return 'home_greeting_afternoon'.tr;
    return 'home_greeting_evening'.tr;
  }
}
