import 'package:get/get.dart';
import 'package:belle_beauty_salon/models/service_model.dart';

class FavoriteController extends GetxController {
  var favoriteServices = <ServiceModel>[].obs;
  var favoriteCategories = <String>[].obs;
  final _categoryFilter = 'All'.obs;

  // ── Service favorites ────────────────────────────────────────────────────────

  bool isFavorite(String serviceName) =>
      favoriteServices.any((s) => s.serviceName == serviceName);

  void toggleFavorite(ServiceModel service) {
    if (isFavorite(service.serviceName)) {
      favoriteServices.removeWhere((s) => s.serviceName == service.serviceName);
    } else {
      favoriteServices.add(service);
    }
  }

  // ── Category favorites ───────────────────────────────────────────────────────

  bool isFavoriteCategory(String categoryName) =>
      favoriteCategories.contains(categoryName);

  void toggleFavoriteCategory(String categoryName) {
    if (isFavoriteCategory(categoryName)) {
      favoriteCategories.remove(categoryName);
    } else {
      favoriteCategories.add(categoryName);
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
