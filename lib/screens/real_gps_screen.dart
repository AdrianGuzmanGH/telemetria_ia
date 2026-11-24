import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RealGpsScreen extends StatefulWidget {
  const RealGpsScreen({super.key});

  @override
  State<RealGpsScreen> createState() => _RealGpsScreenState();
}

class _RealGpsScreenState extends State<RealGpsScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;
  final List<LatLng> _points = [];
  Position? _currentPosition;
  bool _isTracking = false;

  void _toggleTracking() async {
    if (_isTracking) {
      _positionSub?.cancel();
      setState(() => _isTracking = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    setState(() {
      _isTracking = true;
      _points.clear();
    });

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _points.add(LatLng(position.latitude, position.longitude));
      });
      _mapController.move(LatLng(position.latitude, position.longitude), _mapController.camera.zoom);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPS Tiempo Real')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null 
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude) 
                  : const LatLng(4.6533, -74.0836),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.telemetria_ia',
              ),
              if (_points.length > 1)
                PolylineLayer(polylines: [
                  Polyline(points: _points, color: Colors.blue, strokeWidth: 5)
                ]),
              if (_currentPosition != null)
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    width: 40, height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  )
                ]),
            ],
          ),
          // Panel de datos técnicos
          if (_currentPosition != null)
            Positioned(
              top: 10, left: 10, right: 10,
              child: Card(
                color: Colors.black87,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      Text('Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      Text('Velocidad: ${(_currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h', style: const TextStyle(color: Colors.white)),
                      Text('Precisión: ${_currentPosition!.accuracy.toStringAsFixed(1)} m', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleTracking,
        backgroundColor: _isTracking ? Colors.red : Colors.blue,
        icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
        label: Text(_isTracking ? 'Detener' : 'Iniciar'),
      ),
    );
  }
}