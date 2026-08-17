class UserModel {
  String? id;
  String name;
  String email;
  String phone;
  String password;
  String? birthDate;
  int loyaltyPoints;
  int freeSessions;
  String? avatar;
  String role;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.birthDate,
    this.loyaltyPoints = 0,
    this.freeSessions = 0,
    this.avatar,
    this.role = 'CUSTOMER',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      password: '',
      birthDate: json['birthDate'],
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      freeSessions: json['freeSessions'] ?? 0,
      avatar: json['avatar'],
      role: json['role'] ?? 'CUSTOMER',
    );
  }
}