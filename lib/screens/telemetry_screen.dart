import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/telemetry_point.dart';
import '../models/classification_result.dart';
import '../services/location_service.dart';
import '../services/ai_classifier.dart';
import '../widgets/telemetry_panel.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final AiClassifier _classifier = HeuristicClassifier();

  StreamSubscription<Position>? _positionSub;
  final List<TelemetryPoint> _points = [];
  ClassificationResult _result = ClassificationResult.unknown;
  bool _tracking = false;
  String? _error;
  double _totalDistance = 0;

  @override
  void initState() {
    super.initState();
    _classifier.load();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _classifier.dispose();
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    if (_tracking) {
      await _stopTracking();
    } else {
      await _startTracking();
    }
  }

  Future<void> _startTracking() async {
    final ok = await _locationService.ensurePermission();
    if (!ok) {
      setState(() => _error = 'Permisos de ubicación denegados');
      return;
    }
    setState(() {
      _tracking = true;
      _error = null;
      _points.clear();
      _totalDistance = 0;
      _result = ClassificationResult.unknown;
    });

    _positionSub = _locationService.positionStream().listen(
      _onPosition,
      onError: (e) => setState(() => _error = e.toString()),
    );
  }

  Future<void> _stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    setState(() => _tracking = false);
  }

  void _onPosition(Position pos) {
    final point = TelemetryPoint.fromPosition(pos);

    if (_points.isNotEmpty) {
      final prev = _points.last;
      _totalDistance += _locationService.distanceBetween(
        prev.latitude,
        prev.longitude,
        point.latitude,
        point.longitude,
      );
    }

    setState(() {
      _points.add(point);
      _result = _classifier.classify(_points);
    });

    _followCamera(point.latLng);
  }

  Future<void> _followCamera(LatLng target) async {
    await _mapController.move(target, _mapController.camera.zoom);
  }

  List<Marker> get _markers {
    if (_points.isEmpty) return [];
    return [
      Marker(
        point: _points.last.latLng,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
      ),
    ];
  }

  List<Polyline> get _polylines {
    if (_points.length < 2) return [];
    return [
      Polyline(
        points: _points.map((p) => p.latLng).toList(),
        color: Colors.blueAccent,
        strokeWidth: 5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final initial = _points.isNotEmpty ? _points.last.latLng : const LatLng(4.6533, -74.0836);

    return Scaffold(
      appBar: AppBar(title: const Text('Telemetría GPS + IA')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initial,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.telemetria_ia',
              ),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_error != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TelemetryPanel(
              current: _points.isEmpty ? null : _points.last,
              result: _result,
              totalDistanceMeters: _totalDistance,
              samples: _points.length,
              tracking: _tracking,
              onToggle: _toggleTracking,
            ),
          ),
        ],
      ),
    );
  }
}