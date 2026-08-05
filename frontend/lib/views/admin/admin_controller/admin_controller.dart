import 'package:get/get.dart';

// ── Data Models ───────────────────────────────────────────────────────────────

class AdminCategory {
  String id;
  String name;
  String emoji;
  int serviceCount;
  bool isActive;

  AdminCategory({
    required this.id,
    required this.name,
    this.emoji = '✨',
    this.serviceCount = 0,
    this.isActive = true,
  });
}

class AdminService {
  String id;
  String name;
  String categoryId;
  double price;
  int durationMins;
  String description;
  List<String> benefits;
  bool isActive;
  int bookingsPerWeek;

  AdminService({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.durationMins,
    this.description = '',
    List<String>? benefits,
    this.isActive = true,
    this.bookingsPerWeek = 0,
  }) : benefits = benefits ?? ['', '', ''];
}

class AdminBooking {
  final String id;
  final String clientName;
  final String serviceName;
  final String specialistName;
  final String dateTime;
  final double amount;
  String status; // confirmed | pending | cancelled

  AdminBooking({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.specialistName,
    required this.dateTime,
    required this.amount,
    required this.status,
  });
}

// ── Controller ────────────────────────────────────────────────────────────────

class AdminController extends GetxController {
  // ── Categories ──────────────────────────────────────────────────────────────
  final categories = <AdminCategory>[].obs;

  // ── Services ────────────────────────────────────────────────────────────────
  final services = <AdminService>[].obs;
  final selectedCategoryId = ''.obs;

  List<AdminService> get filteredServices {
    if (selectedCategoryId.value.isEmpty) return services.toList();
    return services.where((s) => s.categoryId == selectedCategoryId.value).toList();
  }

  // ── Bookings ────────────────────────────────────────────────────────────────
  final bookings = <AdminBooking>[].obs;
  List<AdminBooking> get recentBookings => bookings.take(3).toList();

  // ── Stats (mock) ─────────────────────────────────────────────────────────────
  final todayRevenue = 8420.0;
  final bookingsToday = 28;
  final activeStaff = 6;
  final avgRating = 4.9;
  final weeklyRevenue = 52890.0;
  final weeklyData = [6800.0, 7200.0, 8100.0, 7400.0, 8420.0, 9100.0, 5870.0];

  // ── Availability ─────────────────────────────────────────────────────────────
  // Key: 'dayOffset_hour' → 'available' | 'booked' | 'blocked'
  final availability = <String, String>{}.obs;

  String _slotKey(int dayOffset, int hour) => '${dayOffset}_$hour';

  String getSlotStatus(int dayOffset, int hour) =>
      availability[_slotKey(dayOffset, hour)] ?? 'available';

  void toggleSlot(int dayOffset, int hour) {
    final key = _slotKey(dayOffset, hour);
    final current = availability[key] ?? 'available';
    if (current == 'booked') return;
    availability[key] = current == 'blocked' ? 'available' : 'blocked';
  }

  void blockLunch(int dayOffset) {
    for (int h = 12; h <= 13; h++) {
      final key = _slotKey(dayOffset, h);
      if ((availability[key] ?? 'available') != 'booked') {
        availability[key] = 'blocked';
      }
    }
  }

  void blockDay(int dayOffset) {
    for (int h = 9; h <= 20; h++) {
      final key = _slotKey(dayOffset, h);
      if ((availability[key] ?? 'available') != 'booked') {
        availability[key] = 'blocked';
      }
    }
  }

  // ── Init ─────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    categories.addAll([
      AdminCategory(id: 'hair',     name: 'Hair',           emoji: '✂️',  serviceCount: 12),
      AdminCategory(id: 'nails',    name: 'Nails',          emoji: '💅',  serviceCount: 8),
      AdminCategory(id: 'skin',     name: 'Skincare',       emoji: '✨',  serviceCount: 10),
      AdminCategory(id: 'laser',    name: 'Laser Removal',  emoji: '⚡',  serviceCount: 6),
      AdminCategory(id: 'spa',      name: 'Spa',            emoji: '🌸',  serviceCount: 9),
      AdminCategory(id: 'makeup',   name: 'Makeup',         emoji: '💄',  serviceCount: 7),
      AdminCategory(id: 'medical',  name: 'Medical Consult',emoji: '🩺',  serviceCount: 4),
      AdminCategory(id: 'products', name: 'Products',       emoji: '🛍️', serviceCount: 24),
    ]);

    services.addAll([
      // Hair
      AdminService(id: 's1', name: 'Haircut & Style',      categoryId: 'hair',  price: 180, durationMins: 60,  description: 'Professional cut and blowdry styling session.', benefits: ['Wash included', 'Blowdry', 'Style advice'],         isActive: true, bookingsPerWeek: 12),
      AdminService(id: 's2', name: 'Trim & Refresh',       categoryId: 'hair',  price: 90,  durationMins: 25,  description: 'Quick trim to remove split ends and refresh shape.', benefits: ['Quick service', 'Blowdry', ''],               isActive: true, bookingsPerWeek: 12),
      AdminService(id: 's3', name: 'Full Hair Coloring',   categoryId: 'hair',  price: 420, durationMins: 120, description: 'Root-to-tip full color treatment with protection.', benefits: ['Root coverage', 'Color protection', 'Shine boost'], isActive: true, bookingsPerWeek: 12),
      AdminService(id: 's4', name: 'Highlights / Balayage',categoryId: 'hair',  price: 580, durationMins: 180, description: 'Soft balayage highlights for a natural sun-kissed look.', benefits: ['Natural look', 'Long lasting', 'Low maintenance'], isActive: true, bookingsPerWeek: 12),
      AdminService(id: 's5', name: 'Keratin Treatment',    categoryId: 'hair',  price: 750, durationMins: 150, description: 'Smoothing keratin treatment for frizz-free hair.', benefits: ['Frizz-free', '3 month effect', 'Shine'],         isActive: true, bookingsPerWeek: 12),
      // Nails
      AdminService(id: 's6', name: 'Classic Manicure',     categoryId: 'nails', price: 80,  durationMins: 45,  description: 'Classic nail care with shape, file, and polish.', benefits: ['Shape & file', 'Cuticle care', 'Polish'],         isActive: true, bookingsPerWeek: 8),
      AdminService(id: 's7', name: 'Gel Nails',            categoryId: 'nails', price: 160, durationMins: 60,  description: 'Long-lasting UV gel for chip-free nails.', benefits: ['2–3 week wear', 'No chipping', 'UV cured'],             isActive: true, bookingsPerWeek: 8),
      AdminService(id: 's8', name: 'Nail Art',             categoryId: 'nails', price: 200, durationMins: 75,  description: 'Custom nail art with gems, foils, and designs.', benefits: ['Custom design', 'Gems available', 'Foils'],         isActive: true, bookingsPerWeek: 8),
      AdminService(id: 's9', name: 'Pedicure',             categoryId: 'nails', price: 120, durationMins: 50,  description: 'Relaxing foot care and polish treatment.', benefits: ['Foot soak', 'Exfoliation', 'Polish'],                   isActive: true, bookingsPerWeek: 8),
      // Skincare
      AdminService(id: 's10', name: 'Hydra Facial',        categoryId: 'skin',  price: 350, durationMins: 60,  description: 'Multi-step facial for deep cleansing and hydration.', benefits: ['Cleanse & extract', 'Hydrate', 'Glow'],      isActive: true, bookingsPerWeek: 10),
      AdminService(id: 's11', name: 'Chemical Peel',       categoryId: 'skin',  price: 280, durationMins: 45,  description: 'Skin resurfacing to remove dead cells and even tone.', benefits: ['Remove dead cells', 'Even skin tone', 'Anti-aging'], isActive: true, bookingsPerWeek: 10),
      AdminService(id: 's12', name: 'Facial Treatment',    categoryId: 'skin',  price: 220, durationMins: 60,  description: 'Classic deep-cleanse facial for glowing skin.', benefits: ['Deep cleanse', 'Mask', 'Moisturise'],               isActive: true, bookingsPerWeek: 10),
      // Laser
      AdminService(id: 's13', name: 'Laser Hair Removal',  categoryId: 'laser', price: 300, durationMins: 45,  description: 'Safe IPL laser for permanent hair reduction.', benefits: ['Long-lasting', 'Painless', 'FDA approved'],          isActive: true, bookingsPerWeek: 6),
      AdminService(id: 's14', name: 'Skin Rejuvenation',   categoryId: 'laser', price: 450, durationMins: 60,  description: 'Laser treatment for fine lines and texture.', benefits: ['Anti-aging', 'Even tone', 'Collagen boost'],          isActive: true, bookingsPerWeek: 6),
      // Spa
      AdminService(id: 's15', name: 'Swedish Massage',     categoryId: 'spa',   price: 250, durationMins: 60,  description: 'Full-body relaxation massage with essential oils.', benefits: ['Full body', 'Relaxation', 'Essential oils'],    isActive: true, bookingsPerWeek: 9),
      AdminService(id: 's16', name: 'Hot Stone Massage',   categoryId: 'spa',   price: 320, durationMins: 75,  description: 'Deep tissue massage with heated basalt stones.', benefits: ['Deep tissue', 'Heated stones', 'Circulation'],    isActive: true, bookingsPerWeek: 9),
      AdminService(id: 's17', name: 'Body Wrap',           categoryId: 'spa',   price: 280, durationMins: 90,  description: 'Detoxifying body wrap with nourishing minerals.', benefits: ['Detox', 'Skin softening', 'Nourishing'],         isActive: true, bookingsPerWeek: 9),
      // Makeup
      AdminService(id: 's18', name: 'Bridal Makeup',       categoryId: 'makeup',price: 600, durationMins: 90,  description: 'Flawless bridal look for your special day.', benefits: ['Long-lasting', 'HD finish', 'Trial included'],       isActive: true, bookingsPerWeek: 7),
      AdminService(id: 's19', name: 'Party Makeup',        categoryId: 'makeup',price: 280, durationMins: 60,  description: 'Glamorous party makeup for any occasion.', benefits: ['Smoky eye', 'Contour', 'Lashes'],                      isActive: true, bookingsPerWeek: 7),
      AdminService(id: 's20', name: 'Natural Glow Look',   categoryId: 'makeup',price: 200, durationMins: 45,  description: 'Fresh, dewy no-makeup makeup look.', benefits: ['Natural finish', 'Skin prep', 'SPF included'],              isActive: true, bookingsPerWeek: 7),
    ]);

    bookings.addAll([
      AdminBooking(id: 'b1', clientName: 'Sara Mansour',  serviceName: 'Balayage',    specialistName: 'Layla', dateTime: 'Today · 14:30',      amount: 580, status: 'confirmed'),
      AdminBooking(id: 'b2', clientName: 'Fatima Hashimi',serviceName: 'Pedicure',    specialistName: 'Maya',  dateTime: 'Today · 15:00',      amount: 160, status: 'confirmed'),
      AdminBooking(id: 'b3', clientName: 'Hala Tariq',    serviceName: 'Facial',      specialistName: 'Sofia', dateTime: 'Today · 16:00',      amount: 280, status: 'pending'),
      AdminBooking(id: 'b4', clientName: 'Lina Khalil',   serviceName: 'Haircut',     specialistName: 'Layla', dateTime: 'Tomorrow · 10:00',   amount: 180, status: 'confirmed'),
      AdminBooking(id: 'b5', clientName: 'Reem Najjar',   serviceName: 'Keratin',     specialistName: 'Layla', dateTime: 'Tomorrow · 13:00',   amount: 750, status: 'confirmed'),
      AdminBooking(id: 'b6', clientName: 'Yasmin Adel',   serviceName: 'Manicure',    specialistName: 'Maya',  dateTime: 'May 17 · 11:30',     amount: 140, status: 'cancelled'),
    ]);

    // Pre-populate some availability slots
    availability.addAll({
      '0_11': 'booked',   // today 11:00
      '0_14': 'booked',   // today 14:00
      '1_10': 'booked',   // tomorrow 10:00
      '1_12': 'blocked',
      '1_13': 'blocked',
      '2_10': 'blocked',
      '2_11': 'blocked',
      '3_10': 'booked',
      '3_11': 'booked',
      '4_16': 'booked',
      '5_15': 'blocked',
    });
  }

  // ── Category CRUD ────────────────────────────────────────────────────────────
  void addCategory(String name, String emoji) {
    final id = 'cat_${categories.length + 1}';
    categories.add(AdminCategory(id: id, name: name, emoji: emoji));
  }

  void editCategory(String id, String name, String emoji) {
    final idx = categories.indexWhere((c) => c.id == id);
    if (idx != -1) {
      categories[idx].name = name;
      categories[idx].emoji = emoji;
      categories.refresh();
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
  }

  // ── Service CRUD ─────────────────────────────────────────────────────────────
  void addService(AdminService s) {
    services.add(s);
    final catIdx = categories.indexWhere((c) => c.id == s.categoryId);
    if (catIdx != -1) {
      categories[catIdx].serviceCount++;
      categories.refresh();
    }
  }

  void editService(AdminService updated) {
    final idx = services.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      services[idx] = updated;
      services.refresh();
    }
  }

  void deleteService(String id) {
    final svc = services.firstWhereOrNull((s) => s.id == id);
    if (svc != null) {
      final catIdx = categories.indexWhere((c) => c.id == svc.categoryId);
      if (catIdx != -1 && categories[catIdx].serviceCount > 0) {
        categories[catIdx].serviceCount--;
        categories.refresh();
      }
      services.remove(svc);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String categoryNameById(String id) =>
      categories.firstWhereOrNull((c) => c.id == id)?.name ?? id;

  String newServiceId() => 'svc_${DateTime.now().millisecondsSinceEpoch}';
}
