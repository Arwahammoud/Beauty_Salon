import 'package:get/get.dart';
import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:belle_beauty_salon/views/home/home_controller/home_controller.dart';

class FavoriteController extends GetxController {
  var favoriteServices = <ServiceModel>[].obs;
  var favoriteCategories = <String>[].obs;
  final _categoryFilter = 'All'.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      final data = await ApiService.get('/users/me/favorites/services', auth: true);
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      favoriteServices.value = items.map((s) => ServiceModel.fromJson(s)).toList();

      final catData = await ApiService.get('/users/me/favorites/categories', auth: true);
      final catItems = (catData['items'] as List).cast<Map<String, dynamic>>();
      favoriteCategories.value = catItems.map((c) => c['title'] as String).toList();
    } catch (_) {
      favoriteServices.value = [];
    }
    isLoading.value = false;
  }

  // ── Service favorites ────────────────────────────────────────────────────────

  bool isFavorite(String serviceName) =>
      favoriteServices.any((s) => s.serviceName == serviceName);

  Future<void> toggleFavorite(ServiceModel service) async {
    final wasFavorite = isFavorite(service.serviceName);
    if (wasFavorite) {
      favoriteServices.removeWhere((s) => s.serviceName == service.serviceName);
    } else {
      favoriteServices.add(service);
    }

    try {
      if (wasFavorite) {
        await ApiService.delete('/users/me/favorites/services/${service.id}', auth: true);
      } else {
        await ApiService.put('/users/me/favorites/services/${service.id}', auth: true);
      }
    } catch (_) {
      // Revert on failure.
      if (wasFavorite) {
        favoriteServices.add(service);
      } else {
        favoriteServices.removeWhere((s) => s.serviceName == service.serviceName);
      }
    }
  }

  // ── Category favorites ───────────────────────────────────────────────────────

  bool isFavoriteCategory(String categoryName) =>
      favoriteCategories.contains(categoryName);

  Future<void> toggleFavoriteCategory(String categoryName) async {
    final wasFavorite = favoriteCategories.contains(categoryName);
    if (wasFavorite) {
      favoriteCategories.remove(categoryName);
    } else {
      favoriteCategories.add(categoryName);
    }

    // Categories are already loaded by HomeController — resolve the id
    // locally instead of asking the widget tree to thread it through.
    String? categoryId;
    try {
      final home = Get.find<HomeController>();
      categoryId = home.categories
          .firstWhereOrNull((c) => c['title'] == categoryName)?['id'];
    } catch (_) {}

    if (categoryId == null) return;

    try {
      if (wasFavorite) {
        await ApiService.delete('/users/me/favorites/categories/$categoryId', auth: true);
      } else {
        await ApiService.put('/users/me/favorites/categories/$categoryId', auth: true);
      }
    } catch (_) {
      if (wasFavorite) {
        favoriteCategories.add(categoryName);
      } else {
        favoriteCategories.remove(categoryName);
      }
    }
  }

  // ── Filter (Saved screen) ────────────────────────────────────────────────────

  String get selectedCategoryFilter => _categoryFilter.value;

  void setFilter(String category) => _categoryFilter.value = category;

  List<String> get availableFilters {
    final cats =
        favoriteServices.map((s) => s.categoryName).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<ServiceModel> get filteredByCategory {
    if (_categoryFilter.value == 'All') return favoriteServices;
    return favoriteServices
        .where((s) => s.categoryName == _categoryFilter.value)
        .toList();
  }
}
