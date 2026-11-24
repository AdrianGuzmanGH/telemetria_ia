import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';
import '../services/ai_classifier.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final DatabaseService _db = DatabaseService();
  final AiClassifier _ai = AiClassifier();
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

    void _loadAlerts() async {
    final user = await _db.getCurrentUser();
    if (user != null) {
      if (user.role == 'admin') {
        // Si es admin, carga TODOS los vehículos del sistema
        final allUsers = await _db.getAllUsers();
        List<Vehicle> allVehicles = [];
        for (var u in allUsers) {
          allVehicles.addAll(u.vehicles);
        }
        setState(() => _vehicles = allVehicles);
      } else {
        // Si es conductor, solo los suyos
        final v = await _db.getUserVehicles(user.username);
        setState(() => _vehicles = v);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Centro de Alertas'), backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
      body: _vehicles.isEmpty
          ? const Center(child: Text('No hay vehículos registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final v = _vehicles[index];
                final alerts = _ai.getSpecificAlerts(v);
                final criticalCount = alerts.where((a) => a.contains('🛑') || a.contains('🛞') || a.contains('📋') || a.contains('⚠️')).length;
                final isCritical = criticalCount > 0;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isCritical ? Colors.red.shade300 : Colors.green.shade300, width: 1.5)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: isCritical ? Colors.red.shade100 : Colors.green.shade100, child: Icon(isCritical ? Icons.warning : Icons.check_circle, color: isCritical ? Colors.red : Colors.green)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${v.brand} ${v.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Placa: ${v.plate} | Año: ${v.year}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isCritical ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(12)), child: Text('${alerts.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                        ...alerts.map((alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.arrow_right, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(alert, style: TextStyle(fontSize: 13, color: alert.contains('✅') ? Colors.green.shade700 : Colors.black87, fontWeight: alert.contains('✅') ? FontWeight.normal : FontWeight.w500))),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}