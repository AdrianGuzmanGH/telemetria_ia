import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicleToEdit;
  final String? ownerUsername; // A quién le pertenece este coche (para el admin)

  const VehicleFormScreen({super.key, this.vehicleToEdit, this.ownerUsername});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandCtrl, _modelCtrl, _plateCtrl, _yearCtrl, _mileageCtrl;
  late TextEditingController _engineCtrl, _brakeCtrl, _tireCtrl, _oilDateCtrl, _techCtrl;
  late TextEditingController _oilBrandCtrl, _tireBrandCtrl;
  String _tireCondition = 'Bueno';
  
  final DatabaseService _dbService = DatabaseService();
  bool get isEditing => widget.vehicleToEdit != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;
    _brandCtrl = TextEditingController(text: v?.brand ?? '');
    _modelCtrl = TextEditingController(text: v?.model ?? '');
    _plateCtrl = TextEditingController(text: v?.plate ?? '');
    _yearCtrl = TextEditingController(text: v?.year ?? '');
    _mileageCtrl = TextEditingController(text: v?.mileage ?? '');
    _engineCtrl = TextEditingController(text: v?.engineChangeDate ?? '');
    _brakeCtrl = TextEditingController(text: v?.brakeChangeDate ?? '');
    _tireCtrl = TextEditingController(text: v?.tireChangeDate ?? '');
    _oilDateCtrl = TextEditingController(text: v?.oilChangeDate ?? '');
    _techCtrl = TextEditingController(text: v?.technicalReviewDate ?? '');
    _oilBrandCtrl = TextEditingController(text: v?.oilBrand ?? '');
    _tireBrandCtrl = TextEditingController(text: v?.tireBrand ?? '');
    if (v != null) _tireCondition = v.tireCondition;
  }

  void _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final newVehicle = Vehicle(
        id: isEditing ? widget.vehicleToEdit!.id : const Uuid().v4(),
        brand: _brandCtrl.text, model: _modelCtrl.text, plate: _plateCtrl.text,
        year: _yearCtrl.text, mileage: _mileageCtrl.text,
        engineChangeDate: _engineCtrl.text, brakeChangeDate: _brakeCtrl.text,
        tireChangeDate: _tireCtrl.text, oilChangeDate: _oilDateCtrl.text,
        technicalReviewDate: _techCtrl.text, tireCondition: _tireCondition,
        oilBrand: _oilBrandCtrl.text, tireBrand: _tireBrandCtrl.text,
      );

      // Determinamos a qué usuario asignarlo
      String targetUsername = widget.ownerUsername ?? '';
      if (targetUsername.isEmpty) {
        final currentUser = await _dbService.getCurrentUser();
        targetUsername = currentUser?.username ?? '';
      }
      
      if (targetUsername.isNotEmpty) {
        if (isEditing) {
          await _dbService.updateVehicleOfUser(targetUsername, newVehicle);
        } else {
          await _dbService.addVehicleToUser(targetUsername, newVehicle);
        }
      }
      if (mounted) Navigator.pop(context);
    }
  }

  void _fillRandom() {
    final random = Random();
    final marcas = ['Toyota', 'Mazda', 'Chevrolet', 'Renault', 'Kia', 'Nissan'];
    final modelos = ['Corolla', 'CX-5', 'Spark', 'Logan', 'Rio', 'Sentra'];
    final aceites = ['Mobil 1', 'Castrol', 'Shell Helix', 'Valvoline'];
    final llantas = ['Michelin', 'Goodyear', 'Pirelli', 'Bridgestone'];
    final estadosLlanta = ['Bueno', 'Regular', 'Malo'];
    
    setState(() {
      _brandCtrl.text = marcas[random.nextInt(marcas.length)];
      _modelCtrl.text = modelos[random.nextInt(modelos.length)];
      _plateCtrl.text = 'ABC${random.nextInt(900) + 100}';
      _yearCtrl.text = (2010 + random.nextInt(14)).toString();
      _mileageCtrl.text = '${random.nextInt(200000) + 10000}';
      _engineCtrl.text = '${2020 + random.nextInt(5)}-0${random.nextInt(9) + 1}-15';
      _brakeCtrl.text = '${2021 + random.nextInt(4)}-0${random.nextInt(9) + 1}-10';
      _tireCtrl.text = '${2022 + random.nextInt(3)}-0${random.nextInt(9) + 1}-20';
      _oilDateCtrl.text = '${2022 + random.nextInt(3)}-0${random.nextInt(9) + 1}-05';
      _techCtrl.text = '${2021 + random.nextInt(4)}-0${random.nextInt(9) + 1}-11';
      _oilBrandCtrl.text = aceites[random.nextInt(aceites.length)];
      _tireBrandCtrl.text = llantas[random.nextInt(llantas.length)];
      _tireCondition = estadosLlanta[random.nextInt(estadosLlanta.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Vehículo' : 'Registrar Vehículo'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!isEditing)
                ElevatedButton.icon(
                  onPressed: _fillRandom,
                  icon: const Icon(Icons.casino), 
                  label: const Text('Autocompletar Datos (Aleatorio)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, 
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12)
                  ),
                ),
              const SizedBox(height: 16),
              _buildSectionTitle('Información Básica'),
              TextFormField(controller: _brandCtrl, decoration: _inputDeco('Marca'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _modelCtrl, decoration: _inputDeco('Modelo'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _plateCtrl, decoration: _inputDeco('Placa'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _yearCtrl, decoration: _inputDeco('Año'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Req' : null)),
                const SizedBox(width: 10),
                Expanded(child: TextFormField(controller: _mileageCtrl, decoration: _inputDeco('Kilometraje'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Req' : null)),
              ]),
              
              const SizedBox(height: 20),
              _buildSectionTitle('Mantenimiento'),
              TextFormField(controller: _engineCtrl, decoration: _inputDeco('Último cambio motor (AAAA-MM-DD)'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _brakeCtrl, decoration: _inputDeco('Último cambio frenos (AAAA-MM-DD)'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _tireCtrl, decoration: _inputDeco('Último cambio llantas (AAAA-MM-DD)'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _oilDateCtrl, decoration: _inputDeco('Último cambio de aceite (AAAA-MM-DD)'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _techCtrl, decoration: _inputDeco('Última revisión técnica (AAAA-MM-DD)'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              
              const SizedBox(height: 20),
              _buildSectionTitle('Detalles de Repuestos'),
              TextFormField(controller: _oilBrandCtrl, decoration: _inputDeco('Marca del aceite'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _tireBrandCtrl, decoration: _inputDeco('Marca de las llantas'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _tireCondition,
                decoration: _inputDeco('Estado de las llantas'),
                items: ['Bueno', 'Regular', 'Malo'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _tireCondition = val!),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveVehicle, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: Text(isEditing ? 'GUARDAR CAMBIOS' : 'REGISTRAR VEHÍCULO', style: const TextStyle(fontWeight: FontWeight.bold))
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
    );
  }
}