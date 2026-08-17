import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/views/auth/auth_screen/create_account/create_account_screen.dart';
import 'package:belle_beauty_salon/views/auth/auth_screen/forgot_password/forgot_password_screen.dart';
import 'package:belle_beauty_salon/views/auth/auth_screen/login/login_screen.dart';
import 'package:belle_beauty_salon/views/auth/auth_screen/reset_password/reset_password_screen.dart';
import 'package:belle_beauty_salon/views/auth/auth_screen/verify_signup/verify_signup_screen.dart';
import 'package:belle_beauty_salon/views/favorite/favorite_screen/favorite_screen.dart';
import 'package:belle_beauty_salon/views/home/home_screen/categories_screen.dart';
import 'package:belle_beauty_salon/views/home/home_screen/category_services_screen.dart';
import 'package:belle_beauty_salon/views/home/home_screen/home_screen.dart';
import 'package:belle_beauty_salon/views/home/home_screen/main_screen.dart';
import 'package:belle_beauty_salon/views/home/home_screen/search_screen.dart';
import 'package:belle_beauty_salon/views/home/home_screen/service_details_screen.dart';
import 'package:belle_beauty_salon/views/profile/profile_screen/personal_info_screen.dart';
import 'package:belle_beauty_salon/views/profile/profile_screen/profile_screen.dart';
import 'package:belle_beauty_salon/views/admin/admin_screen/add_edit_service_screen.dart';
import 'package:belle_beauty_salon/views/admin/admin_screen/admin_bookings_screen.dart';
import 'package:belle_beauty_salon/views/admin/admin_screen/admin_dashboard_screen.dart';
import 'package:belle_beauty_salon/views/admin/admin_screen/availability_screen.dart';
import 'package:belle_beauty_salon/views/admin/admin_screen/manage_categories_screen.dart';
import 'package:belle_beauty_salon/views/admin/admin_screen/manage_services_screen.dart';
import 'package:belle_beauty_salon/views/profile/profile_screen/help_support_screen.dart';
import 'package:belle_beauty_salon/views/profile/profile_screen/privacy_policy_screen.dart';
import 'package:belle_beauty_salon/views/profile/profile_screen/settings_screen.dart';
import 'package:belle_beauty_salon/views/booking/booking_confirmed_screen.dart';
import 'package:belle_beauty_salon/views/booking/steps/booking_summary_screen.dart';
import 'package:belle_beauty_salon/views/booking/steps/select_date_screen.dart';
import 'package:belle_beauty_salon/views/booking/steps/select_time_screen.dart';
import 'package:belle_beauty_salon/views/offers/offers_screen.dart';
import 'package:belle_beauty_salon/views/rolle/rolle_screen/rolle_screen.dart';
import 'package:get/get.dart';

List<GetPage<dynamic>>? routes = [
  //rolle screen
  GetPage(name: AppRoutes.rolleSceeen, page: () => RolleScreen()),
  GetPage(name: AppRoutes.createAccount, page: () => CreateAccount()),
  GetPage(
    name: AppRoutes.verifySignup,
    page: () => VerifySignupScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 350),
  ),
  GetPage(name: AppRoutes.loginScreen, page: () => LoginScreen()),
  GetPage(
    name: AppRoutes.forgotPassword,
    page: () => ForgotPasswordScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 350),
  ),
  GetPage(
    name: AppRoutes.resetPassword,
    page: () => ResetPasswordScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 350),
  ),

  //(main+home)screen
  GetPage(name: AppRoutes.mainScreen, page: () => MainScreen()),
  GetPage(name: AppRoutes.home, page: () => HomeScreen()),
  GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
  GetPage(name: AppRoutes.personalInfo, page: () => PersonalInfoScreen()),
  GetPage(name: AppRoutes.setting, page: () => SettingsScreen()),
  GetPage(name: AppRoutes.category, page: () => CategoriesScreen()),
  GetPage(name: AppRoutes.search, page: () => SearchScreen()),
  GetPage(
    name: AppRoutes.categoryServices,
    page: () => CategoryServicesScreen(),
    transition: Transition.leftToRight,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: AppRoutes.serviceDetails,
    page: () => ServiceDetailsScreen(),
    transition: Transition.fadeIn,
  ),
  GetPage(name: AppRoutes.favorite, page: () => FavoriteScreen()),
  GetPage(
    name: AppRoutes.offersScreen,
    page: () => OffersScreen(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: AppRoutes.selectDate,
    page: () => SelectDateScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 350),
  ),
  GetPage(
    name: AppRoutes.selectTime,
    page: () => SelectTimeScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 350),
  ),
  GetPage(
    name: AppRoutes.bookingSummary,
    page: () => BookingSummaryScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 350),
  ),
  GetPage(
    name: AppRoutes.bookingConfirmed,
    page: () => BookingConfirmedScreen(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 400),
  ),
  GetPage(
    name: AppRoutes.helpSupport,
    page: () => const HelpSupportScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.privacyPolicy,
    page: () => const PrivacyPolicyScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),

  // ── Admin routes ────────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.adminDashboard,
    page: () => AdminDashboardScreen(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 350),
  ),
  GetPage(
    name: AppRoutes.adminCategories,
    page: () => const ManageCategoriesScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.adminServices,
    page: () => const ManageServicesScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.adminAddEditService,
    page: () => const AddEditServiceScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.adminBookings,
    page: () => const AdminBookingsScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
  GetPage(
    name: AppRoutes.adminAvailability,
    page: () => const AvailabilityScreen(),
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 300),
  ),
];
