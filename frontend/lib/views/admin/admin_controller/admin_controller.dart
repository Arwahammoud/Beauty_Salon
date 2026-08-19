import 'dart:async';

import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/utils/relative_time.dart';
import 'package:get/get.dart';

//  Data Models 

class AdminCategory {
  String id;
  String name;
  String nameAr;
  String emoji;
  String image;
  int serviceCount;
  bool isActive;

  AdminCategory({
    required this.id,
    required this.name,
    this.nameAr = '',
    this.emoji = '✨',
    this.image = '',
    this.serviceCount = 0,
    this.isActive = true,
  });

  factory AdminCategory.fromJson(Map<String, dynamic> j) => AdminCategory(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        nameAr: j['nameAr'] ?? '',
        emoji: j['emoji'] ?? '✨',
        image: j['image'] ?? '',
        serviceCount: j['serviceCount'] ?? 0,
        isActive: j['isActive'] ?? true,
      );
}

class AdminSpecialist {
  final String id;
  final String name;
  final String role;
  final String image;

  AdminSpecialist({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
  });

  factory AdminSpecialist.fromJson(Map<String, dynamic> j) => AdminSpecialist(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        role: j['role'] ?? '',
        image: j['image'] ?? '',
      );
}

class AdminService {
  String id;
  String name;
  String nameAr;
  String categoryId;
  double price;
  int durationMins;
  String description;
  String descriptionAr;
  List<String> benefits;
  List<String> benefitsAr;
  bool isActive;
  int bookingsPerWeek;
  String specialistId;
  String image;

  AdminService({
    required this.id,
    required this.name,
    this.nameAr = '',
    required this.categoryId,
    required this.price,
    required this.durationMins,
    this.description = '',
    this.descriptionAr = '',
    List<String>? benefits,
    List<String>? benefitsAr,
    this.isActive = true,
    this.bookingsPerWeek = 0,
    this.specialistId = '',
    this.image = '',
  })  : benefits = benefits ?? ['', '', ''],
        benefitsAr = benefitsAr ?? ['', '', ''];

  factory AdminService.fromJson(Map<String, dynamic> j) => AdminService(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        nameAr: j['nameAr'] ?? '',
        categoryId: j['categoryId'].toString(),
        price: (j['price'] ?? 0).toDouble(),
        durationMins: j['durationMins'] ?? 0,
        description: j['description'] ?? '',
        descriptionAr: j['descriptionAr'] ?? '',
        benefits: List<String>.from(j['benefits'] ?? []),
        benefitsAr: List<String>.from(j['benefitsAr'] ?? []),
        isActive: j['isActive'] ?? true,
        bookingsPerWeek: j['bookingsPerWeek'] ?? 0,
        specialistId: j['specialistId']?.toString() ?? '',
        image: j['image'] ?? '',
      );
}

class AdminDayOff {
  final String id;
  final String date; // yyyy-MM-dd
  final String? specialistId; // null = whole salon
  final String? specialistName;
  final String note;

  AdminDayOff({
    required this.id,
    required this.date,
    this.specialistId,
    this.specialistName,
    this.note = '',
  });

  factory AdminDayOff.fromJson(Map<String, dynamic> j) => AdminDayOff(
        id: j['id'].toString(),
        date: j['date'] ?? '',
        specialistId: j['specialistId']?.toString(),
        specialistName: j['specialistName'] as String?,
        note: j['note'] ?? '',
      );
}

class AdminBooking {
  final String id;
  final String clientName;
  final String? serviceId;
  final String serviceName;
  final String? specialistId;
  final String specialistName;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String dateTime;
  final double amount;
  String status; // confirmed | pending | cancelled | completed

  AdminBooking({
    required this.id,
    required this.clientName,
    this.serviceId,
    required this.serviceName,
    this.specialistId,
    required this.specialistName,
    this.date = '',
    this.time = '',
    required this.dateTime,
    required this.amount,
    required this.status,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> j) => AdminBooking(
        id: j['id'].toString(),
        clientName: j['clientName'] ?? '',
        serviceId: j['serviceId']?.toString(),
        serviceName: j['serviceName'] ?? '',
        specialistId: j['specialistId']?.toString(),
        specialistName: j['specialistName'] ?? '',
        date: j['date'] ?? '',
        time: j['time'] ?? '',
        dateTime: j['dateTime'] ?? '',
        amount: (j['amount'] ?? 0).toDouble(),
        status: j['status'] ?? 'pending',
      );
}

//  Controller 

class AdminController extends GetxController {
  static bool isValidServiceValues({
    required double price,
    required int durationMins,
  }) {
    return price > 0 && durationMins > 0;
  }

  //  Chat API key 
  final geminiKeyConfigured = false.obs;
  final isSavingGeminiKey = false.obs;

  Future<void> loadGeminiKeyStatus() async {
    try {
      final data = await ApiService.get('/admin/settings/gemini-key', auth: true);
      geminiKeyConfigured.value = data['configured'] ?? false;
    } catch (_) {}
  }

  Future<bool> setGeminiKey(String value) async {
    if (value.trim().isEmpty) return false;
    isSavingGeminiKey.value = true;
    try {
      final data = await ApiService.put('/admin/settings/gemini-key', auth: true, body: {'value': value.trim()});
      geminiKeyConfigured.value = data['configured'] ?? true;
      return true;
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_save_key'.trParams({'error': '$e'}));
      return false;
    } finally {
      isSavingGeminiKey.value = false;
    }
  }

  //  Categories 
  final categories = <AdminCategory>[].obs;

  //  Services 
  final services = <AdminService>[].obs;
  final selectedCategoryId = ''.obs;

  //  Specialists (read-only picker) 
  final specialists = <AdminSpecialist>[].obs;

  List<AdminService> get filteredServices {
    if (selectedCategoryId.value.isEmpty) return services.toList();
    return services.where((s) => s.categoryId == selectedCategoryId.value).toList();
  }

  //  Bookings 
  final bookings = <AdminBooking>[].obs;
  List<AdminBooking> get recentBookings => bookings.take(3).toList();

  //  Stats 
  final todayRevenue = 0.0.obs;
  final bookingsToday = 0.obs;
  final activeStaff = 0.obs;
  final avgRating = 0.0.obs;
  final weeklyRevenue = 0.0.obs;
  final weeklyData = <double>[0, 0, 0, 0, 0, 0, 0].obs;

  //  Notifications 
  final notifications = <Map<String, dynamic>>[].obs;
  Timer? _notificationsTimer;

  int get unreadCount => notifications.where((n) => n['read'] == false).length;

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

  //  Availability 
  // Key: 'dayOffset_hour' → 'available' | 'booked' | 'blocked'
  final availability = <String, String>{}.obs;
  DateTime? _availabilityWindowStart;

  String _slotKey(int dayOffset, int hour) => '${dayOffset}_$hour';

  String getSlotStatus(int dayOffset, int hour) =>
      availability[_slotKey(dayOffset, hour)] ?? 'available';

  DateTime _dateForOffset(int dayOffset) {
    final start = _availabilityWindowStart ?? DateTime.now();
    return DateTime(start.year, start.month, start.day + dayOffset);
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> toggleSlot(int dayOffset, int hour) async {
    final key = _slotKey(dayOffset, hour);
    final current = availability[key] ?? 'available';
    if (current == 'booked') return;
    final next = current == 'blocked' ? 'available' : 'blocked';
    availability[key] = next;

    try {
      await ApiService.patch('/admin/availability', auth: true, body: {
        'date': _isoDate(_dateForOffset(dayOffset)),
        'hour': hour,
        'status': next,
      });
    } catch (_) {
      availability[key] = current;
    }
  }

  Future<void> blockLunch(int dayOffset) async {
    for (int h = 12; h <= 13; h++) {
      if ((availability[_slotKey(dayOffset, h)] ?? 'available') != 'booked') {
        availability[_slotKey(dayOffset, h)] = 'blocked';
      }
    }
    try {
      await ApiService.patch('/admin/availability', auth: true, body: {
        'date': _isoDate(_dateForOffset(dayOffset)),
        'hourFrom': 12,
        'hourTo': 13,
        'status': 'blocked',
      });
    } catch (_) {}
  }

  Future<void> blockDay(int dayOffset) async {
    for (int h = 9; h <= 20; h++) {
      if ((availability[_slotKey(dayOffset, h)] ?? 'available') != 'booked') {
        availability[_slotKey(dayOffset, h)] = 'blocked';
      }
    }
    try {
      await ApiService.patch('/admin/availability', auth: true, body: {
        'date': _isoDate(_dateForOffset(dayOffset)),
        'hourFrom': 9,
        'hourTo': 20,
        'status': 'blocked',
      });
    } catch (_) {}
  }

  //  Day off calendar 
  // A day off can be whole-salon (specialistId null) or scoped to one
  // specialist — the admin picks the scope when marking it.
  final dayOffs = <AdminDayOff>[].obs;
  final calendarMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1).obs;

  List<AdminDayOff> dayOffsFor(String isoDate) =>
      dayOffs.where((d) => d.date == isoDate).toList();

  List<AdminBooking> bookingsOnDate(String isoDate, {String? specialistId}) {
    return bookings.where((b) {
      if (b.date != isoDate || b.status == 'cancelled') return false;
      if (specialistId != null && b.specialistId != specialistId) return false;
      return true;
    }).toList();
  }

  Future<void> loadDayOffs() async {
    final start = DateTime(calendarMonth.value.year, calendarMonth.value.month, 1);
    final end = DateTime(calendarMonth.value.year, calendarMonth.value.month + 1, 0);
    final days = end.difference(start).inDays + 1;
    try {
      final data = await ApiService.get(
        '/admin/day-off?startDate=${_isoDate(start)}&days=$days',
        auth: true,
      );
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      dayOffs.value = items.map((d) => AdminDayOff.fromJson(d)).toList();
    } catch (_) {}
  }

  void changeCalendarMonth(int delta) {
    final m = calendarMonth.value;
    calendarMonth.value = DateTime(m.year, m.month + delta, 1);
    loadDayOffs();
  }

  Future<bool> addDayOff({
    required String date,
    String? specialistId,
    String note = '',
  }) async {
    try {
      await ApiService.post('/admin/day-off', auth: true, body: {
        'date': date,
        'specialistId': specialistId,
        'note': note,
      });
      await loadDayOffs();
      return true;
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_save_day_off'.trParams({'error': '$e'}));
      return false;
    }
  }

  Future<void> removeDayOff(String id) async {
    try {
      await ApiService.delete('/admin/day-off/$id', auth: true);
      dayOffs.removeWhere((d) => d.id == id);
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_remove_day_off'.trParams({'error': '$e'}));
    }
  }

  Future<void> cancelBookingsOnDate(String isoDate, {String? specialistId}) async {
    final matches = bookingsOnDate(isoDate, specialistId: specialistId);
    for (final b in matches) {
      await updateBookingStatus(b.id, 'cancelled');
    }
  }

  //  Init 
  @override
  void onInit() {
    super.onInit();
    loadAll();
    _notificationsTimer = Timer.periodic(
      const Duration(seconds: 7),
      (_) => loadNotifications(),
    );
  }

  @override
  void onClose() {
    _notificationsTimer?.cancel();
    super.onClose();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadCategories(),
      loadServices(),
      loadSpecialists(),
      loadBookings(),
      loadAvailability(),
      loadDayOffs(),
      loadDashboardStats(),
      loadGeminiKeyStatus(),
      loadNotifications(),
    ]);
  }

  Future<void> loadDashboardStats() async {
    try {
      final data = await ApiService.get('/admin/dashboard/stats', auth: true);
      todayRevenue.value = (data['todayRevenue'] ?? 0).toDouble();
      bookingsToday.value = data['bookingsToday'] ?? 0;
      activeStaff.value = data['activeStaff'] ?? 0;
      avgRating.value = (data['avgRating'] ?? 0).toDouble();
      weeklyRevenue.value = (data['weeklyRevenue'] ?? 0).toDouble();
      weeklyData.value = (data['weeklyRevenueByDay'] as List)
          .map((v) => (v as num).toDouble())
          .toList();
      // recentBookings getter reads from `bookings`, filled by loadBookings().
    } catch (_) {}
  }

  Future<void> loadCategories() async {
    try {
      final data = await ApiService.get('/admin/categories', auth: true);
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      categories.value = items.map((c) => AdminCategory.fromJson(c)).toList();
    } catch (_) {}
  }

  Future<void> loadServices() async {
    try {
      final data = await ApiService.get('/admin/services', auth: true);
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      services.value = items.map((s) => AdminService.fromJson(s)).toList();
    } catch (_) {}
  }

  Future<void> loadSpecialists() async {
    try {
      final data = await ApiService.get('/admin/specialists', auth: true);
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      specialists.value = items.map((s) => AdminSpecialist.fromJson(s)).toList();
    } catch (_) {}
  }

  Future<void> loadBookings() async {
    try {
      final data = await ApiService.get('/admin/bookings', auth: true);
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      bookings.value = items.map((b) => AdminBooking.fromJson(b)).toList();
    } catch (_) {}
  }

  Future<void> loadAvailability() async {
    _availabilityWindowStart ??= DateTime.now();
    final start = _availabilityWindowStart!;
    try {
      final data = await ApiService.get(
        '/admin/availability?startDate=${_isoDate(start)}&days=7',
        auth: true,
      );
      final slots = (data['slots'] as List).cast<Map<String, dynamic>>();
      final map = <String, String>{};
      for (final s in slots) {
        final date = DateTime.parse(s['date'] as String);
        final offset = date.difference(DateTime(start.year, start.month, start.day)).inDays;
        map[_slotKey(offset, s['hour'] as int)] = s['status'] as String;
      }
      availability.value = map;
    } catch (_) {}
  }

  //  Category CRUD 
  Future<void> addCategory(String name, String emoji,
      {String nameAr = '', String image = ''}) async {
    try {
      await ApiService.post('/admin/categories', auth: true, body: {
        'name': name,
        'nameAr': nameAr,
        'emoji': emoji.isEmpty ? '✨' : emoji,
        'image': image,
      });
      await loadCategories();
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_create_category'.trParams({'error': '$e'}));
    }
  }

  Future<void> editCategory(String id, String name, String emoji,
      {String nameAr = '', String? image, bool? isActive}) async {
    try {
      await ApiService.patch('/admin/categories/$id', auth: true, body: {
        'name': name,
        'nameAr': nameAr,
        'emoji': emoji,
        'image': image ?? '',
        'isActive': isActive ?? true,
      });
      await loadCategories();
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_update_category'.trParams({'error': '$e'}));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await ApiService.delete('/admin/categories/$id', auth: true);
      categories.removeWhere((c) => c.id == id);
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message);
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_delete_category'.trParams({'error': '$e'}));
    }
  }

  //  Service CRUD 
  Future<void> addService(AdminService s) async {
    if (!isValidServiceValues(price: s.price, durationMins: s.durationMins)) {
      Get.snackbar(
        'Invalid data',
        'Price and duration must be greater than zero.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await ApiService.post('/admin/services', auth: true, body: {
        'name': s.name,
        'nameAr': s.nameAr,
        'categoryId': s.categoryId,
        'specialistId': s.specialistId.isNotEmpty ? s.specialistId : null,
        'price': s.price,
        'durationMins': s.durationMins,
        'description': s.description,
        'descriptionAr': s.descriptionAr,
        'benefits': s.benefits.where((b) => b.trim().isNotEmpty).toList(),
        'benefitsAr': s.benefitsAr.where((b) => b.trim().isNotEmpty).toList(),
        'image': s.image,
      });
      await Future.wait([loadServices(), loadCategories()]);
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message);
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_create_service'.trParams({'error': '$e'}));
    }
  }

  Future<void> editService(AdminService updated) async {
    if (!isValidServiceValues(price: updated.price, durationMins: updated.durationMins)) {
      Get.snackbar(
        'Invalid data',
        'Price and duration must be greater than zero.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await ApiService.patch('/admin/services/${updated.id}', auth: true, body: {
        'name': updated.name,
        'nameAr': updated.nameAr,
        'categoryId': updated.categoryId,
        'specialistId': updated.specialistId.isNotEmpty ? updated.specialistId : null,
        'price': updated.price,
        'durationMins': updated.durationMins,
        'description': updated.description,
        'descriptionAr': updated.descriptionAr,
        'benefits': updated.benefits.where((b) => b.trim().isNotEmpty).toList(),
        'benefitsAr': updated.benefitsAr.where((b) => b.trim().isNotEmpty).toList(),
        'image': updated.image,
        'isActive': updated.isActive,
      });
      await loadServices();
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_update_service'.trParams({'error': '$e'}));
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await ApiService.delete('/admin/services/$id', auth: true);
      await Future.wait([loadServices(), loadCategories()]);
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_delete_service'.trParams({'error': '$e'}));
    }
  }

  Future<void> updateBookingStatus(String id, String status) async {
    try {
      await ApiService.patch('/admin/bookings/$id/status', auth: true, body: {
        'status': status,
      });
      final idx = bookings.indexWhere((b) => b.id == id);
      if (idx != -1) {
        bookings[idx].status = status;
        bookings.refresh();
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_update_booking'.trParams({'error': '$e'}));
    }
  }

  Future<void> adminEditBooking(
    String id, {
    String? serviceId,
    String? specialistId,
    String? date,
    String? time,
  }) async {
    try {
      await ApiService.patch('/admin/bookings/$id', auth: true, body: {
        'serviceId': serviceId,
        'specialistId': specialistId,
        'date': date,
        'time': time,
      });
      await loadBookings();
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message);
    } catch (e) {
      Get.snackbar('error'.tr, 'could_not_update_booking'.trParams({'error': '$e'}));
    }
  }

  //  Helpers 
  String categoryNameById(String id) =>
      categories.firstWhereOrNull((c) => c.id == id)?.name ?? id;

  String newServiceId() => 'svc_${DateTime.now().millisecondsSinceEpoch}';
}
