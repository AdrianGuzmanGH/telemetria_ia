import 'package:geolocator/geolocator.dart';

/// Encapsula los permisos y el stream de posiciones GPS.
class LocationService {
  /// Verifica y solicita permisos. Devuelve true si se puede usar el GPS.
  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Stream de posiciones con filtro de distancia de 5 m.
  Stream<Position> positionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Distancia entre dos puntos en metros.
  double distanceBetween(double lat1, double lon1, double lat2, double lon2) =>
      Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
}