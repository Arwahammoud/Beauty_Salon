import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:belle_beauty_salon/services/api_service.dart';
import 'package:get/get.dart';

class OffersController extends GetxController {
  var isLoading = false.obs;

  var offers = <Map<String, dynamic>>[].obs;
  var trendingTags = <String>[].obs;

  static const _gradientCount = 3;

  @override
  void onInit() {
    super.onInit();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    isLoading.value = true;
    try {
      final data = await ApiService.get('/offers');
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      offers.value = List.generate(items.length, (i) {
        final o = items[i];
        return {
          'badge': o['badge'],
          'title': o['title'],
          'date': '${o['startDate']} – ${o['endDate']}',
          'discount': o['discountLabel'],
          'image': o['image'],
          'serviceId': o['serviceId'].toString(),
          'gradientIndex': i % _gradientCount,
        };
      });
      trendingTags.value = List<String>.from(data['trendingTags'] ?? []);
    } catch (_) {
      offers.value = [];
      trendingTags.value = [];
    }
    isLoading.value = false;
  }

  Future<void> onGetOfferTap(Map<String, dynamic> offer) async {
    final serviceId = offer['serviceId'] as String;
    try {
      final data = await ApiService.get('/services/$serviceId');
      Get.toNamed(AppRoutes.serviceDetails, arguments: ServiceModel.fromJson(data));
    } catch (_) {
      Get.snackbar('Error', 'Could not load this service.');
    }
  }
}
