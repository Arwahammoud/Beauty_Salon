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
      return authController.currentUser.value?.name ?? "Guest User";
    } catch (e) {
      return "Guest User";
    }
  }

  var reviewsList = <Map<String, String>>[
    {
      "name": "Sara M.",
      "comment": "Absolutely loved it — highly recommended!",
      "time": "2 days ago",
    },
    {
      "name": "Fatima A.",
      "comment": "Best in town, will come back every month.",
      "time": "1 week ago",
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ServiceModel) {
      service = args;
    } else {
      // Fallback: pop back instead of crashing with LateInitializationError
      WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
    }
  }

  void submitReview() {
    if (reviewController.text.trim().isNotEmpty) {
      DateTime now = DateTime.now();
      String formattedTime =
          "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      String formattedDateAndTime =
          "${now.year}/${now.month}/${now.day}  $formattedTime";

      reviewsList.add({
        "name": currentUserFullName,
        "comment": reviewController.text.trim(),
        "time": formattedDateAndTime,
      });
      reviewController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      Get.snackbar(
        "نجاح",
        "تم إرسال تعليقك بنجاح",
        backgroundColor: Colors.green.withValues(alpha: 0.2),
      );
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
