import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';
import '../services/ai_classifier.dart';
import 'alerts_screen.dart';

class SimulatedCar {
  final Vehicle vehicle;
  double speed;
  String aiResult;
  LatLng position;
  double angle;
  List<LatLng> routeHistory;
  Color alertColor;

  SimulatedCar({required this.vehicle, this.speed = 0, this.aiResult = 'Detenido', required this.position, this.angle = 0, List<LatLng>? routeHistory, this.alertColor = Colors.grey}) : routeHistory = routeHistory ?? [];
}

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final DatabaseService _db = DatabaseService();
  final AiClassifier _ai = AiClassifier();
  final MapController _mapController = MapController();
  
  List<Vehicle> _allVehicles = [];
  List<SimulatedCar> _activeCars = [];
  Timer? _simulationTimer;
  bool _isSimulating = false;
  final LatLng _center = const LatLng(4.6533, -74.0836);

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() async {
    final user = await _db.getCurrentUser();
    if (user != null) {
      final vehicles = await _db.getUserVehicles(user.username);
      setState(() => _allVehicles = vehicles);
    }
  }

  void _toggleVehicle(Vehicle v) {
    setState(() {
      final index = _activeCars.indexWhere((c) => c.vehicle.id == v.id);
      if (index != -1) {
        _activeCars.removeAt(index);
      } else {
        final random = Random();
        final startAngle = random.nextDouble() * 2 * pi;
        final startRadius = 0.001 + random.nextDouble() * 0.002;
        final startPos = LatLng(_center.latitude + cos(startAngle) * startRadius, _center.longitude + sin(startAngle) * startRadius);
        _activeCars.add(SimulatedCar(vehicle: v, position: startPos, angle: startAngle, routeHistory: [startPos]));
      }
    });
  }

  void _toggleSimulation() {
    if (_isSimulating) {
      _simulationTimer?.cancel();
      setState(() => _isSimulating = false);
    } else {
      if (_activeCars.isEmpty) return;
      setState(() => _isSimulating = true);
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          for (var car in _activeCars) {
            if (car.speed > 0) {
              car.angle += (Random().nextDouble() - 0.5) * 0.4; 
              final moveDistance = (car.speed / 3600) * 0.0004; 
              final newPos = LatLng(car.position.latitude + cos(car.angle) * moveDistance, car.position.longitude + sin(car.angle) * moveDistance);
              car.position = newPos;
              car.routeHistory.add(newPos); 
              if (car.routeHistory.length > 80) car.routeHistory.removeAt(0);
            }
            car.aiResult = _ai.evaluateRisk(car.speed, car.vehicle);
            
            if (car.aiResult.contains('CRÍTICO') || car.aiResult.contains('URGENTE')) car.alertColor = Colors.red;
            else if (car.aiResult.contains('Advertencia') || car.aiResult.contains('ALTO RIESGO') || car.aiResult.contains('Aviso')) car.alertColor = Colors.orange;
            else if (car.speed > 10) car.alertColor = Colors.green;
            else car.alertColor = Colors.grey;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulación IA'),
        backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(_isSimulating ? Icons.pause_circle : Icons.play_circle, size: 32, color: _isSimulating ? Colors.red : Colors.green), onPressed: _toggleSimulation),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 65,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: _center, initialZoom: 15),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.telemetria_ia'),
                    PolylineLayer(polylines: _activeCars.map((car) => Polyline(points: car.routeHistory, color: car.alertColor.withOpacity(0.7), strokeWidth: 5.0)).toList()),
                    MarkerLayer(markers: _activeCars.map((car) => Marker(point: car.position, width: 45, height: 45, child: Icon(Icons.directions_car, color: car.alertColor, size: 45))).toList()),
                  ],
                ),
                Positioned(
                  top: 10, left: 10,
                  child: Card(color: Colors.black87, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Text(_isSimulating ? 'En vivo' : 'Pausado', style: TextStyle(color: _isSimulating ? Colors.greenAccent : Colors.white, fontSize: 12)))),
                ),
                Positioned(
                  top: 10, right: 10,
                  child: FloatingActionButton.small(
                    heroTag: 'btnAlertas',
                    backgroundColor: Colors.redAccent,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertsScreen())),
                    child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 35,
            child: Container(
              color: Colors.grey.shade100,
              child: _allVehicles.isEmpty 
                ? const Center(child: Text('No tienes vehículos registrados.'))
                : Column(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10), color: Colors.blueGrey.shade800, child: const Row(children: [Icon(Icons.tune, color: Colors.white, size: 16), SizedBox(width: 6), Text('Controles de Flota', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))])),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          itemCount: _allVehicles.length,
                          itemBuilder: (context, index) {
                            final v = _allVehicles[index];
                            final activeCar = _activeCars.firstWhere((c) => c.vehicle.id == v.id, orElse: () => SimulatedCar(vehicle: v, position: LatLng(0,0)));
                            final isSelected = _activeCars.any((c) => c.vehicle.id == v.id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                leading: SizedBox(width: 30, child: Checkbox(value: isSelected, onChanged: (val) => _toggleVehicle(v))),
                                title: Text('${v.brand} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                subtitle: isSelected 
                                  ? Text(activeCar.aiResult, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: activeCar.alertColor), maxLines: 1, overflow: TextOverflow.ellipsis)
                                  : const Text('Inactivo', style: TextStyle(fontSize: 9)),
                                trailing: isSelected
                                  ? SizedBox(width: 100, child: Slider(value: activeCar.speed, min: 0, max: 160, divisions: 16, activeColor: activeCar.alertColor, label: '${activeCar.speed.toStringAsFixed(0)}', onChanged: (val) => setState(() => activeCar.speed = val)))
                                  : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}