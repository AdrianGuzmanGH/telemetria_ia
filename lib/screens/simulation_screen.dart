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
import '../services/simulation_service.dart';
import '../services/settings_service.dart';
import '../widgets/telemetry_panel.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  static const int _maxPoints = 500;
  static const _defaultCenter = LatLng(4.6533, -74.0836);

  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final AiClassifier _classifier = HeuristicClassifier();
  final SimulationService _simService = SimulationService();
  final SettingsService _settings = SettingsService();

  StreamSubscription<Position>? _sub;
  final List<TelemetryPoint> _points = [];
  ClassificationResult _result = ClassificationResult.unknown;

  bool _running = false;
  bool _aggressive = false;
  double _speed = 30;
  double _radius = 30;
  double _totalDistance = 0;
  int _tick = 0;

  // Para el estilo vectorial de OpenFreeMap
  vt.Style? _style;
  bool _styleLoaded = false;

  @override
  void initState() {
    super.initState();
    _classifier.load();
    _loadSettings();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
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
    _simService.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final speed = await _settings.loadSpeed();
    final radius = await _settings.loadRadius();
    if (!mounted) return;
    setState(() {
      _speed = speed;
      _radius = radius;
    });
  }

  Future<void> _saveSettings() async {
    await _settings.saveSpeed(_speed);
    await _settings.saveRadius(_radius);
  }

  void _start() {
    _points.clear();
    _totalDistance = 0;
    _result = ClassificationResult.unknown;
    _tick = 0;
    _aggressive = false;

    _simService.start(
      baseLat: _defaultCenter.latitude,
      baseLng: _defaultCenter.longitude,
      radius: _radius,
    );
    _simService.setSpeed(_speed);

    _sub = _simService.stream.listen(_onPosition);

    setState(() => _running = true);
  }

  void _stop() {
    _sub?.cancel();
    _sub = null;
    _simService.stop();
    setState(() {
      _running = false;
      _aggressive = false;
    });
    _saveSettings();
  }

  void _toggleAggressive() {
    if (_aggressive) {
      _simService.stopAggressive();
      setState(() => _aggressive = false);
    } else {
      _simService.startAggressive();
      setState(() => _aggressive = true);
    }
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
            color: Colors.indigoAccent,
            strokeWidth: 5,
          ),
        ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_running ? 'Simulación en curso' : 'Configurar simulación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_running) _stop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _running ? _buildRunning() : _buildConfig(),
    );
  }

  Widget _buildConfig() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Ajusta los parámetros de la simulación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Los valores se guardan automáticamente para tu próxima sesión.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Velocidad: ${_speed.toStringAsFixed(0)} km/h',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _speed.clamp(0, 160),
                      min: 0,
                      max: 160,
                      divisions: 32,
                      label: '${_speed.toStringAsFixed(0)} km/h',
                      onChanged: (v) => setState(() => _speed = v),
                      onChangeEnd: (_) => _saveSettings(),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _preset('🛑 Detenido', 0),
                        _preset('🚗 Ciudad', 30),
                        _preset('🛣️ Carretera', 80),
                        _preset('⚡ Acelerón', 110),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Radio del recorrido: ${_radius.toStringAsFixed(0)} m',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _radius.clamp(10, 200),
                      min: 10,
                      max: 200,
                      divisions: 19,
                      label: '${_radius.toStringAsFixed(0)} m',
                      onChanged: (v) => setState(() => _radius = v),
                      onChangeEnd: (_) => _saveSettings(),
                    ),
                    const Text(
                      'Un radio mayor hace que el recorrido sea más amplio y visible en el mapa.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _start,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar simulación'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preset(String label, double value) {
    return OutlinedButton(
      onPressed: () {
        setState(() => _speed = value);
        _saveSettings();
      },
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildRunning() {
    final initial =
        _points.isNotEmpty ? _points.last.latLng : _defaultCenter;

    return Stack(
      children: [
        if (_styleLoaded && _style != null)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initial,
              initialZoom: 17,
              maxZoom: 21,
            ),
            children: [
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

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TelemetryPanel(
              current: _points.isEmpty ? null : _points.last,
              result: _result,
              totalDistanceMeters: _totalDistance,
              samples: _points.length,
              tracking: true,
              onToggle: _stop,
              compact: true,
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
              child: _buildBottomBar(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _stop,
              icon: const Icon(Icons.stop,
                  color: Colors.redAccent, size: 20),
              label: const Text(
                'Detener',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(width: 1, height: 22, color: Colors.grey.shade300),
            TextButton.icon(
              onPressed: _toggleAggressive,
              icon: Icon(
                _aggressive ? Icons.bolt : Icons.bolt_outlined,
                color: _aggressive ? Colors.orange : Colors.indigo,
                size: 20,
              ),
              label: Text(
                _aggressive ? 'Agresivo ON' : 'Agresivo',
                style: TextStyle(
                  color: _aggressive ? Colors.orange : Colors.indigo,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}