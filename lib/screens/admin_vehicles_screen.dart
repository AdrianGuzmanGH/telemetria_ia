import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';
import '../services/ai_classifier.dart';
import 'vehicle_form_screen.dart';

class AdminVehiclesScreen extends StatefulWidget {
  const AdminVehiclesScreen({super.key});

  @override
  State<AdminVehiclesScreen> createState() => _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState extends State<AdminVehiclesScreen> {
  final DatabaseService _db = DatabaseService();
  final AiClassifier _ai = AiClassifier();
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final users = await _db.getAllUsers();
    setState(() {
      _users = users.where((u) => u.role != 'admin').toList(); // Solo conductores
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Flota Global de Usuarios'), backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No hay usuarios registrados aún.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue)),
                        title: Text('Usuario: ${user.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Vehículos: ${user.vehicles.length}'),
                        children: user.vehicles.isEmpty
                            ? [const Padding(padding: EdgeInsets.all(16.0), child: Text('Este usuario no tiene vehículos.'))]
                            : user.vehicles.map((v) => _buildVehicleTile(v, user.username)).toList(),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildVehicleTile(Vehicle v, String ownerUsername) {
    final alerts = _ai.getSpecificAlerts(v);
    final hasAlerts = alerts.any((a) => !a.contains('✅'));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasAlerts ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasAlerts ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: hasAlerts ? Colors.red : Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text('${v.brand} ${v.model} (${v.plate})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: hasAlerts ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(10)),
                child: Text(hasAlerts ? 'ALERTAS' : 'ÓPTIMO', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Km: ${v.mileage} | Llantas: ${v.tireCondition}', style: const TextStyle(fontSize: 12)),
          const Divider(),
          ...alerts.take(2).map((a) => Text(a, style: const TextStyle(fontSize: 12))).toList(),
          
          // BOTONES DE ACCIÓN PARA EL ADMIN
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16, color: Colors.orange),
                label: const Text('Editar', style: TextStyle(color: Colors.orange)),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleFormScreen(vehicleToEdit: v, ownerUsername: ownerUsername)));
                  _loadData(); // Recargar al volver
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  await _db.deleteVehicleOfUser(ownerUsername, v.id);
                  _loadData(); // Recargar al volver
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}