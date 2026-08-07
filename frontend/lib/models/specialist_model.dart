class Specialist {
  final String name;
  final String role;
  final double rating;
  final int experienceYears;
  final String image;

  Specialist({
    required this.name,
    required this.role,
    required this.rating,
    required this.experienceYears,
    required this.image,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      experienceYears: json['experienceYears'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}