import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/vehicle.dart';

class DatabaseService {
  static const String _usersKey = 'app_users';
  static const String _sessionKey = 'current_user_session';

  // --- INICIALIZACIÓN Y SESIÓN ---

  Future<void> _initDefaultUsers() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_usersKey)) {
      // Creamos el administrador por defecto
      final admin = AppUser(
        username: 'admin',
        password: 'admin123',
        role: 'admin',
        vehicles: [],
      );
      final users = [admin];
      await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    await _initDefaultUsers();
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_usersKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((u) => AppUser.fromJson(u)).toList();
  }

  Future<void> saveAllUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<AppUser?> login(String username, String password) async {
    final users = await getAllUsers();
    try {
      final user = users.firstWhere((u) => u.username == username && u.password == password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, username); // Guardamos quién está en sesión
      return user;
    } catch (e) {
      return null; // No lo encontró
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_sessionKey);
    if (username == null) return null;
    
    final users = await getAllUsers();
    try {
      return users.firstWhere((u) => u.username == username);
    } catch (e) {
      return null;
    }
  }

  // --- CRUD DE USUARIOS (Solo Admin) ---

  Future<bool> registerUser(String username, String password) async {
    final users = await getAllUsers();
    if (users.any((u) => u.username == username)) return false; // Ya existe

    users.add(AppUser(username: username, password: password, role: 'user', vehicles: []));
    await saveAllUsers(users);
    return true;
  }

  Future<void> deleteUser(String username) async {
    final users = await getAllUsers();
    users.removeWhere((u) => u.username == username);
    await saveAllUsers(users);
  }

  // --- CRUD DE VEHÍCULOS (Por Usuario) ---

  Future<List<Vehicle>> getUserVehicles(String username) async {
    final users = await getAllUsers();
    final user = users.firstWhere((u) => u.username == username);
    return user.vehicles;
  }

  Future<void> addVehicleToUser(String username, Vehicle vehicle) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.username == username);
    if (index != -1) {
      users[index].vehicles.add(vehicle);
      await saveAllUsers(users);
    }
  }

  Future<void> updateVehicleOfUser(String username, Vehicle vehicle) async {
    final users = await getAllUsers();
    final uIndex = users.indexWhere((u) => u.username == username);
    if (uIndex != -1) {
      final vIndex = users[uIndex].vehicles.indexWhere((v) => v.id == vehicle.id);
      if (vIndex != -1) {
        users[uIndex].vehicles[vIndex] = vehicle;
        await saveAllUsers(users);
      }
    }
  }

  Future<void> deleteVehicleOfUser(String username, String vehicleId) async {
    final users = await getAllUsers();
    final uIndex = users.indexWhere((u) => u.username == username);
    if (uIndex != -1) {
      users[uIndex].vehicles.removeWhere((v) => v.id == vehicleId);
      await saveAllUsers(users);
    }
  }
}