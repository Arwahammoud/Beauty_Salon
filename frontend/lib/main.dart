import 'package:belle_beauty_salon/app_pages.dart';
import 'package:belle_beauty_salon/bindings/initial_bindings.dart';
import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/services/locale_prefs.dart';
import 'package:belle_beauty_salon/translations/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isArabic = await LocalePrefs.load();
  runApp(MyApp(
    initialLocale: isArabic ? const Locale('ar', 'SA') : const Locale('en', 'US'),
  ));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialBinding: InitialBindings(),
          initialRoute: AppRoutes.rolleSceeen,
          getPages: routes,
          translations: AppTranslations(),
          locale: initialLocale,
          fallbackLocale: const Locale('ar', 'SA'),
        );
      },
    );
  }
}
