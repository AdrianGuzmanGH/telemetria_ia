import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_vector_tiles/flutter_map_vector_tiles.dart' as vt;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/telemetry_point.dart';
import '../models/classification_result.dart';
import '../services/location_service.dart';
import '../services/ai_classifier.dart';
import '../widgets/telemetry_panel.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  static const int _maxPoints = 500;
  static const _defaultCenter = LatLng(4.6533, -74.0836);

  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final AiClassifier _classifier = HeuristicClassifier();

  StreamSubscription<Position>? _sub;
  final List<TelemetryPoint> _points = [];
  ClassificationResult _result = ClassificationResult.unknown;
  bool _tracking = false;
  String? _error;
  double _totalDistance = 0;
  int _tick = 0;

  // Para el estilo vectorial de OpenFreeMap
  vt.Style? _style;
  bool _styleLoaded = false;

  @override
  void initState() {
    super.initState();
    _classifier.load();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    // Cargamos el estilo público de OpenFreeMap (sin API key).
    final style = await vt.StyleReader(
      uri: 'https://tiles.openfreemap.org/styles/liberty',
    ).read();
    if (mounted) {
      setState(() {
        _style = style;
        _styleLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _classifier.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_tracking) {
      await _sub?.cancel();
      _sub = null;
      if (mounted) setState(() => _tracking = false);
      return;
    }

    final ok = await _locationService.ensurePermission();
    if (!ok) {
      setState(() =>
          _error = 'Permisos de ubicación denegados. Actívalos en ajustes.');
      return;
    }

    setState(() {
      _tracking = true;
      _error = null;
      _points.clear();
      _totalDistance = 0;
      _result = ClassificationResult.unknown;
    });

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) _onPosition(last);
    } catch (_) {}

    _sub = _locationService.positionStream().listen(
      _onPosition,
      onError: (e) => setState(() => _error = e.toString()),
    );

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      if (mounted) _onPosition(pos);
    } catch (_) {}
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

    _points.add(point);
    if (_points.length > _maxPoints) _points.removeAt(0);

    final result = _classifier.classify(_points);

    _tick++;
    setState(() {
      _result = result;
    });

    if (_tick % 3 == 0) {
      _mapController.move(point.latLng, _mapController.camera.zoom);
    }
  }

  List<Marker> get _markers => _points.isEmpty
      ? []
      : [
          Marker(
            point: _points.last.latLng,
            width: 50,
            height: 50,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ];

  List<Polyline> get _polylines => _points.length < 2
      ? []
      : [
          Polyline(
            points: _points.map((p) => p.latLng).toList(),
            color: Colors.blueAccent,
            strokeWidth: 5,
          ),
        ];

  @override
  Widget build(BuildContext context) {
    final initial =
        _points.isNotEmpty ? _points.last.latLng : _defaultCenter;

    return Scaffold(
      appBar: AppBar(title: const Text('Telemetría real')),
      body: Stack(
        children: [
          if (_styleLoaded && _style != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initial,
                initialZoom: 16,
                maxZoom: 21,
              ),
              children: [
                // Capa de mosaicos vectoriales de OpenFreeMap.
                vt.VectorTileLayer(
                  theme: _style!.theme,
                  tileProviders: _style!.providers,
                  rasterSources: _style!.rasterSources,
                  sprites: _style!.sprites,
                ),
                PolylineLayer(polylines: _polylines),
                MarkerLayer(markers: _markers),
              ],
            )
          else
            const Center(child: CircularProgressIndicator()),

          if (_error != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: SafeArea(
                bottom: false,
                child: Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: TelemetryPanel(
                  current: _points.isEmpty ? null : _points.last,
                  result: _result,
                  totalDistanceMeters: _totalDistance,
                  samples: _points.length,
                  tracking: _tracking,
                  onToggle: _toggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}