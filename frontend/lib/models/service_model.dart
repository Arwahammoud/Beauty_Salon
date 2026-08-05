import 'package:belle_beauty_salon/models/specialist_model.dart';

class ServiceModel {
  final String categoryName;
  final String serviceName;
  final String duration;
  final int durationMins;
  final double rating;
  final int reviewsCount;
  final double price;
  final String image;
  final String about;
  final List<String> benefits;
  final Specialist specialist;

  ServiceModel({
    required this.categoryName,
    required this.serviceName,
    required this.duration,
    required this.durationMins,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.image,
    required this.about,
    required this.benefits,
    required this.specialist,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      categoryName: json['category'] ?? json['categoryName'] ?? '',
      serviceName: json['name'] ?? json['serviceName'] ?? '',
      duration: json['duration'] ?? '',
      durationMins: json['durationMins'] ?? 60,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
      about: json['about'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
      specialist: Specialist.fromJson(json['specialist'] ?? {}),
    );
  }
}
