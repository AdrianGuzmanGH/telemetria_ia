import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';
import 'vehicle_form_screen.dart';
import '../models/user.dart';

class GarageScreen extends StatefulWidget {
  final String? specificUsername;
  const GarageScreen({super.key, this.specificUsername});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  final DatabaseService _db = DatabaseService();
  List<Vehicle> _vehicles = [];
  AppUser? _currentUser;
  String? _targetUsername;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = await _db.getCurrentUser();
    if (user != null) {
      _targetUsername = widget.specificUsername ?? user.username;
      final vehicles = await _db.getUserVehicles(_targetUsername!);
      setState(() {
        _currentUser = user;
        _vehicles = vehicles;
      });
    }
  }

  void _deleteVehicle(String id) async {
    if (_targetUsername != null) {
      await _db.deleteVehicleOfUser(_targetUsername!, id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.specificUsername != null ? 'Vehículos de $_targetUsername' : 'Mi Garaje'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: _vehicles.isEmpty
          ? const Center(child: Text('No hay vehículos registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                final v = _vehicles[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12), // Padding reducido
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar más pequeño
                            CircleAvatar(radius: 20, backgroundColor: Colors.blue.shade50, child: const Icon(Icons.directions_car, color: Colors.blue, size: 24)),
                            const SizedBox(width: 12),
                            // Expanded evita que el texto empuje los botones
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${v.brand} ${v.model}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Placa: ${v.plate} • Año: ${v.year}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            // Botones más compactos
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleFormScreen(vehicleToEdit: v, ownerUsername: _targetUsername)));
                                    _loadData();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Eliminar Vehículo'),
                                        content: Text('¿Eliminar el ${v.brand} ${v.model}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                          TextButton(
                                            onPressed: () { Navigator.pop(ctx); _deleteVehicle(v.id); }, 
                                            child: const Text('Eliminar', style: TextStyle(color: Colors.red))
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                        const Divider(),
                        // Los detalles también con Expanded para evitar overflow
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildDetail('Kilometraje', '${v.mileage} km')),
                            Expanded(child: _buildDetail('Llantas', v.tireCondition)),
                            Expanded(child: _buildDetail('Frenos', v.brakeChangeDate)),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleFormScreen(ownerUsername: _targetUsername)));
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildDetail(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}