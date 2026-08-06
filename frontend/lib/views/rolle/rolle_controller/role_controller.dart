import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/services/locale_prefs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoleController extends GetxController {
  // main() already resolved and cached the persisted preference before
  // runApp, so this starts in sync with the locale GetMaterialApp booted with.
  late final isArabic = LocalePrefs.cachedIsArabic.obs;

  // Stores the role selected on the role screen so login can route correctly
  final currentRole = 'CUSTOMER'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  // Safety net in case the cached value above was somehow stale.
  Future<void> _loadSavedLanguage() async {
    final saved = await LocalePrefs.load();
    if (saved != isArabic.value) {
      isArabic.value = saved;
      Get.updateLocale(saved ? const Locale('ar', 'SA') : const Locale('en', 'US'));
    }
  }

  // Single source of truth for the app's language — every screen (login,
  // role selection, settings) should call this so the whole app switches
  // together and the choice is remembered as the default next launch.
  Future<void> setLanguage(bool toArabic) async {
    isArabic.value = toArabic;
    Get.updateLocale(
      toArabic ? const Locale('ar', 'SA') : const Locale('en', 'US'),
    );
    await LocalePrefs.save(toArabic);
  }

  void toggleLanguage() => setLanguage(!isArabic.value);

  void selectRole(String role) {
    currentRole.value = role;
    if (role == 'ADMIN') {
      Get.offNamed(AppRoutes.loginScreen);
    } else {
      Get.offNamed(AppRoutes.createAccount);
    }
  }
}
