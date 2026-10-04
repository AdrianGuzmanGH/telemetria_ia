import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class SimulationService {
  final _controller = StreamController<Position>.broadcast();
  Timer? _ticker;

  double _angle = 0;
  double _speedKmh = 0;
  double _radiusMeters = 30;
  double _baseLat = 4.6533;
  double _baseLng = -74.0836;

  /// Velocidad antes de entrar en modo agresivo.
  double? _speedBeforeAggressive;
  bool _aggressive = false;

  /// Velocidad fija del modo agresivo.
  static const double _aggressiveSpeed = 120;

  static const Duration _interval = Duration(seconds: 1);

  Stream<Position> get stream => _controller.stream;
  double get speedKmh => _speedKmh;
  double get radiusMeters => _radiusMeters;
  bool get isAggressive => _aggressive;

  void start({
    required double baseLat,
    required double baseLng,
    double radius = 30,
  }) {
    _baseLat = baseLat;
    _baseLng = baseLng;
    _radiusMeters = radius;
    _angle = 0;
    _ticker?.cancel();
    _ticker = Timer.periodic(_interval, (_) => _emit());
  }

  void setSpeed(double kmh) {
    _speedKmh = kmh.clamp(0, 160);
    if (_aggressive) {
      // Si el usuario mueve el slider mientras el agresivo está activo,
      // actualizamos la velocidad a restaurar.
      _speedBeforeAggressive = _speedKmh;
    }
  }

  void setRadius(double meters) {
    _radiusMeters = meters.clamp(10, 200);
  }

  /// Salta a velocidad alta y se queda ahí. No alterna.
  void startAggressive() {
    if (_aggressive) return;
    _aggressive = true;
    _speedBeforeAggressive = _speedKmh;
    _speedKmh = _aggressiveSpeed;
  }

  void stopAggressive() {
    if (!_aggressive) return;
    _aggressive = false;
    if (_speedBeforeAggressive != null) {
      _speedKmh = _speedBeforeAggressive!;
      _speedBeforeAggressive = null;
    }
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    stopAggressive();
    _speedKmh = 0;
  }

  void _emit() {
    final v = _speedKmh / 3.6;
    _angle += (v / _radiusMeters) * (_interval.inMilliseconds / 1000.0);

    final dLat = (_radiusMeters * cos(_angle)) / 111320.0;
    final dLng = (_radiusMeters * sin(_angle)) /
        (111320.0 * cos(_baseLat * pi / 180));

    _controller.add(Position(
      latitude: _baseLat + dLat,
      longitude: _baseLng + dLng,
      timestamp: DateTime.now(),
      accuracy: 4,
      altitude: 2600,
      altitudeAccuracy: 1,
      heading: (_angle * 180 / pi) % 360,
      headingAccuracy: 1,
      speed: _speedKmh / 3.6,
      speedAccuracy: 0.5,
    ));
  }

  void dispose() {
    stop();
    _controller.close();
  }
}