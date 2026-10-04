import 'package:shared_preferences/shared_preferences.dart';

/// Guarda y recupera la configuración de la simulación.
class SettingsService {
  static const _kSpeed = 'sim_speed';
  static const _kAggressive = 'sim_aggressive';
  static const _kRadius = 'sim_radius';

  Future<double> loadSpeed() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_kSpeed) ?? 30.0;
  }

  Future<void> saveSpeed(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kSpeed, v);
  }

  Future<bool> loadAggressive() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kAggressive) ?? false;
  }

  Future<void> saveAggressive(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAggressive, v);
  }

  Future<double> loadRadius() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_kRadius) ?? 30.0;
  }

  Future<void> saveRadius(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kRadius, v);
  }
}