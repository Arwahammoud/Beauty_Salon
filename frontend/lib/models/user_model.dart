class UserModel {
  String name;
  String email;
  String phone;
  String password;
  String? birthDate; 
  int loyaltyPoints; 

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.birthDate, 
    this.loyaltyPoints = 0, 
  });
}