import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:get/get.dart';

class CategoryDetailsController extends GetxController {
  var allServices = <ServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var isLoading = false.obs;
  var selectedFilter = 'Popular'.obs;

  final List<String> filters = ['Popular', 'Price: Low', 'Price: High', 'Quick'];

  String categoryName = '';
  String categoryId = '';
  // Stable, language-independent identifier (backend's raw English `name`)
  // used for icon/background lookups — categoryName may be localized (Arabic).
  String categoryKey = '';

  static const Map<String, String> _sortParam = {
    'Popular': 'popular',
    'Price: Low': 'price_asc',
    'Price: High': 'price_desc',
    'Quick': 'quick',
  };

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      categoryName = args['title'] as String? ?? '';
      categoryId = args['id'] as String? ?? '';
      categoryKey = args['key'] as String? ?? categoryName;
    } else if (args is String) {
      categoryName = args;
      categoryKey = args;
    }
    fetchServices();
  }

  Future<void> fetchServices() async {
    if (categoryId.isEmpty) {
      allServices.value = [];
      filteredServices.value = [];
      return;
    }

    isLoading.value = true;
    try {
      final sort = _sortParam[selectedFilter.value] ?? 'popular';
      final data = await ApiService.get('/categories/$categoryId/services?sort=$sort');
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      allServices.value = items.map((j) => ServiceModel.fromJson(j)).toList();
      filteredServices.value = List.from(allServices);
    } catch (_) {
      allServices.value = [];
      filteredServices.value = [];
    }
    isLoading.value = false;
  }

  void applyFilter(String filter) {
    selectedFilter.value = filter;
    fetchServices();
  }
}
