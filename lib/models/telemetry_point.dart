import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Representa una muestra de telemetría GPS en un instante de tiempo.
class TelemetryPoint {
  final double latitude;
  final double longitude;
  final double speed;     // m/s
  final double heading;   // grados (0-360)
  final double accuracy;  // metros
  final double altitude;  // metros
  final DateTime timestamp;

  TelemetryPoint({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.accuracy,
    required this.altitude,
    required this.timestamp,
  });

  factory TelemetryPoint.fromPosition(Position p) => TelemetryPoint(
        latitude: p.latitude,
        longitude: p.longitude,
        speed: p.speed,
        heading: p.heading,
        accuracy: p.accuracy,
        altitude: p.altitude,
        timestamp: p.timestamp,
      );

  LatLng get latLng => LatLng(latitude, longitude);

  double get speedKmh => speed * 3.6;

  @override
  String toString() =>
      'TP(${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}, '
      '${speedKmh.toStringAsFixed(1)} km/h)';
}