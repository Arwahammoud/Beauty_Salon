import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/views/auth/auth_controller/auth_controller.dart';
import 'package:belle_beauty_salon/views/home/home_controller/main_controller.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  ServiceModel? service;

  var selectedDate = Rx<DateTime?>(null);
  var selectedTime = ''.obs;
  var appointmentsTabIndex = 0.obs;

  var isLoadingSlots = false.obs;
  var isBooking = false.obs;
  var isLoadingAppointments = false.obs;

  // Loyalty program: redeem a banked free session for this booking instead
  // of paying + earning points on it.
  var useFreeSession = false.obs;
  var lastPointsEarned = 0.obs;
  var lastUsedFreeSession = false.obs;
  var lastFreeSessionEarned = false.obs;

  static const _months = [
    'month_jan','month_feb','month_mar','month_apr','month_may','month_jun',
    'month_jul','month_aug','month_sep','month_oct','month_nov','month_dec',
  ];
  static const _days = [
    'day_mon','day_tue','day_wed','day_thu','day_fri','day_sat','day_sun',
  ];

  var timeSlots = <String, List<Map<String, dynamic>>>{}.obs;

  var upcomingAppointments = <Map<String, dynamic>>[].obs;
  var pastAppointments = <Map<String, dynamic>>[].obs;
  var cancelledAppointments = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMyBookings();
  }

  Future<void> loadMyBookings() async {
    isLoadingAppointments.value = true;
    try {
      final data = await ApiService.get('/users/me/bookings', auth: true);
      final items = (data['items'] as List).cast<Map<String, dynamic>>();

      final upcoming = <Map<String, dynamic>>[];
      final past = <Map<String, dynamic>>[];
      final cancelled = <Map<String, dynamic>>[];

      for (final b in items) {
        final apt = {
          'id': b['id'].toString(),
          'serviceId': b['serviceId']?.toString(),
          'serviceName': b['serviceName'],
          'specialist': b['specialistName'],
          'image': b['image'],
          'date': b['date'],
          'time': b['time'],
          'status': b['status'],
        };
        switch (b['status']) {
          case 'UPCOMING':
            upcoming.add(apt);
            break;
          case 'CANCELLED':
            cancelled.add(apt);
            break;
          default:
            past.add(apt);
        }
      }

      upcomingAppointments.value = upcoming;
      pastAppointments.value = past;
      cancelledAppointments.value = cancelled;
    } catch (_) {
      // Keep whatever was already loaded.
    }
    isLoadingAppointments.value = false;
  }

  void startBooking(ServiceModel s) {
    service = s;
    selectedDate.value = null;
    selectedTime.value = '';
    timeSlots.value = {};
    useFreeSession.value = false;
    Get.toNamed(AppRoutes.selectDate, arguments: s);
  }

  Future<void> onDateSelected(DateTime date) async {
    selectedDate.value = date;
    selectedTime.value = '';
    await _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final s = service;
    final date = selectedDate.value;
    if (s == null || date == null) return;

    isLoadingSlots.value = true;
    try {
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = await ApiService.get(
        '/services/${s.id}/availability?date=$dateStr',
        auth: true,
      );
      final slots = (data['slots'] as List).cast<Map<String, dynamic>>();

      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final slot in slots) {
        final period = slot['period'] as String;
        grouped.putIfAbsent(period, () => []).add({
          'time': slot['time'],
          'available': slot['available'],
        });
      }
      timeSlots.value = grouped;
    } catch (_) {
      timeSlots.value = {};
    }
    isLoadingSlots.value = false;
  }

  void onTimeSelected(String time) => selectedTime.value = time;

  void goToSelectTime() {
    if (selectedDate.value == null) return;
    Get.toNamed(AppRoutes.selectTime);
  }

  void goToSummary() {
    if (selectedTime.value.isEmpty) return;
    Get.toNamed(AppRoutes.bookingSummary);
  }

  Future<void> confirmBooking() async {
    final s = service;
    final date = selectedDate.value;
    if (s == null || date == null || isBooking.value) return;

    isBooking.value = true;
    try {
      final dateStr =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final data = await ApiService.post('/bookings', auth: true, body: {
        'serviceId': s.id,
        'date': dateStr,
        'time': selectedTime.value,
        if (useFreeSession.value) 'useFreeSession': true,
      });

      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;
      if (currentUser != null) {
        currentUser.loyaltyPoints = data['loyaltyPoints'] ?? currentUser.loyaltyPoints;
        currentUser.freeSessions = data['freeSessions'] ?? currentUser.freeSessions;
        authController.currentUser.refresh();
      }
      lastPointsEarned.value = (data['pointsEarned'] ?? 0) as int;
      lastUsedFreeSession.value = data['usedFreeSession'] == true;
      lastFreeSessionEarned.value = data['freeSessionEarned'] == true;

      await loadMyBookings();
      Get.toNamed(AppRoutes.bookingConfirmed);
    } on ApiException catch (e) {
      Get.snackbar('booking_failed'.tr, e.message);
    } catch (_) {
      Get.snackbar('booking_failed'.tr, 'connection_error_body'.tr);
    } finally {
      isBooking.value = false;
      useFreeSession.value = false;
    }
  }

  Future<void> cancelAppointment(int index) async {
    if (index < 0 || index >= upcomingAppointments.length) return;
    final id = upcomingAppointments[index]['id'];

    try {
      await ApiService.post('/bookings/$id/cancel', auth: true);
      await loadMyBookings();
    } on ApiException catch (e) {
      Get.snackbar('could_not_cancel'.tr, e.message);
    } catch (_) {
      Get.snackbar('could_not_cancel'.tr, 'connection_error_body'.tr);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> availabilityForReschedule(
      String serviceId, DateTime date) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final data = await ApiService.get(
        '/services/$serviceId/availability?date=$dateStr',
        auth: true,
      );
      final slots = (data['slots'] as List).cast<Map<String, dynamic>>();
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final slot in slots) {
        final period = slot['period'] as String;
        grouped.putIfAbsent(period, () => []).add({
          'time': slot['time'],
          'available': slot['available'],
        });
      }
      return grouped;
    } catch (_) {
      return {};
    }
  }

  Future<bool> rescheduleAppointment(int index, DateTime date, String time) async {
    if (index < 0 || index >= upcomingAppointments.length) return false;
    final id = upcomingAppointments[index]['id'];
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      await ApiService.post('/bookings/$id/reschedule', auth: true, body: {
        'date': dateStr,
        'time': time,
      });
      await loadMyBookings();
      return true;
    } on ApiException catch (e) {
      Get.snackbar('could_not_reschedule'.tr, e.message);
      return false;
    } catch (_) {
      Get.snackbar('could_not_reschedule'.tr, 'connection_error_body'.tr);
      return false;
    }
  }

  void goHome() {
    Get.until((route) => route.isFirst);
    Get.find<MainController>().changePage(0);
  }

  void viewBooking() {
    Get.until((route) => route.isFirst);
    Get.find<MainController>().changePage(1);
  }

  String dayAbbrev(DateTime d) => _days[d.weekday - 1].tr;
  String monthAbbrev(DateTime d) => _months[d.month - 1].tr;

  String get formattedSelectedDate {
    final d = selectedDate.value;
    if (d == null) return '';
    return '${_days[d.weekday - 1].tr}, ${_months[d.month - 1].tr} ${d.day}';
  }

  String get confirmedDateLabel {
    final d = selectedDate.value;
    if (d == null) return '';
    return '${_days[d.weekday - 1].tr}, ${_months[d.month - 1].tr} ${d.day}';
  }

  String get bookingSubtitle {
    if (service == null) return '';
    final withSpecialist = 'with_specialist'.trParams({'name': service!.specialist.name});
    return '$formattedSelectedDate · ${service!.duration} · $withSpecialist';
  }

  // Loyalty points are only earned on bookings priced at 100 or more, and
  // never on a booking paid for with a redeemed free session.
  int get projectedPoints {
    if (service == null || useFreeSession.value || service!.price < 100) return 0;
    return (service!.price / 10).round();
  }

  int get availableFreeSessions =>
      Get.find<AuthController>().currentUser.value?.freeSessions ?? 0;

  double get chargedAmount {
    if (service == null) return 0;
    return useFreeSession.value ? 0 : service!.price;
  }

  void toggleUseFreeSession(bool value) {
    useFreeSession.value = value && availableFreeSessions > 0;
  }
}
