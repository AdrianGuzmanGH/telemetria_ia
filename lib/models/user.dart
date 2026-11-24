import 'vehicle.dart';

class AppUser {
  final String username;
  final String password;
  final String role; // 'admin' o 'user'
  List<Vehicle> vehicles;

  AppUser({
    required this.username,
    required this.password,
    required this.role,
    required this.vehicles,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        username: json['username'],
        password: json['password'],
        role: json['role'],
        vehicles: (json['vehicles'] as List)
            .map((v) => Vehicle.fromJson(v))
            .toList(),
      );
}