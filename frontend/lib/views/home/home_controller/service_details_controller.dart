import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/utils/relative_time.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/booking/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:belle_beauty_salon/models/service_model.dart';

class ServiceDetailsController extends GetxController {
  late ServiceModel service;
  final TextEditingController reviewController = TextEditingController();

  String get currentUserFullName {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser.value?.name ?? 'guest_user'.tr;
    } catch (e) {
      return 'guest_user'.tr;
    }
  }

  var reviewsList = <Map<String, String>>[].obs;
  var isLoadingReviews = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ServiceModel) {
      service = args;
      loadReviews();
    } else {
      // Fallback: pop back instead of crashing with LateInitializationError
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
    }
  }

  Future<void> loadReviews() async {
    isLoadingReviews.value = true;
    try {
      final data = await ApiService.get('/services/${service.id}/reviews');
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      reviewsList.value = items.map((r) => {
        "name": r['userName'] as String,
        "comment": r['comment'] as String,
        "time": relativeTime(r['createdAt'] as String),
      }).toList();
    } catch (_) {
      reviewsList.value = [];
    }
    isLoadingReviews.value = false;
  }

  Future<void> submitReview() async {
    final comment = reviewController.text.trim();
    if (comment.isEmpty) return;

    try {
      final created = await ApiService.post(
        '/services/${service.id}/reviews',
        body: {'comment': comment},
        auth: true,
      );
      reviewsList.insert(0, {
        "name": created['userName'] as String,
        "comment": created['comment'] as String,
        "time": 'just_now'.tr,
      });
      reviewController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      Get.snackbar(
        'success'.tr,
        'review_submitted'.tr,
        backgroundColor: Colors.green.withValues(alpha: 0.2),
      );
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message, backgroundColor: Colors.red.withValues(alpha: 0.2));
    } catch (_) {
      Get.snackbar('error'.tr, 'could_not_submit_review'.tr,
          backgroundColor: Colors.red.withValues(alpha: 0.2));
    }
  }

  void bookNow() {
    final bc = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    bc.startBooking(service);
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
