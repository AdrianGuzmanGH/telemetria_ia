import 'package:flutter/material.dart';
import 'screens/real_gps_screen.dart';
import 'screens/garage_screen.dart';
import 'screens/simulation_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_vehicles_screen.dart'; // Asegúrate de tener este archivo creado
import 'services/database_service.dart';
import 'models/user.dart';

void main() => runApp(const TelemetriaApp());

class TelemetriaApp extends StatelessWidget {
  const TelemetriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlotaSmart IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const MainMenuScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: DatabaseService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data != null) return const MainMenuScreen();
        return const LoginScreen();
      },
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await DatabaseService().getCurrentUser();
    setState(() => _currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    bool isAdmin = _currentUser!.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Panel de Administrador' : 'Mi Flota'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await DatabaseService().logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${_currentUser!.username}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(isAdmin ? 'Tienes acceso total al sistema' : 'Gestiona tus vehículos aquí', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            // SOLO EL ADMIN VE ESTOS DOS BOTONES
            if (isAdmin) ...[
              _buildMenuCard(context, 'Gestión de Usuarios', 'Crear y eliminar cuentas', Icons.people, const AdminUsersScreen(), Colors.purple),
              _buildMenuCard(context, 'Flota Global (Vehículos)', 'Ver y editar vehículos de todos', Icons.fact_check, const AdminVehiclesScreen(), Colors.teal),
            ],

            // ESTOS MÓDULOS LOS VEN TODOS (ADMIN Y USUARIOS)
            _buildMenuCard(context, 'GPS en Tiempo Real', 'Rastreo satelital', Icons.my_location, const RealGpsScreen(), Colors.blue),
            _buildMenuCard(context, 'Mi Garaje', isAdmin ? 'Tus vehículos personales' : 'Administra tus vehículos', Icons.garage, const GarageScreen(), Colors.orange),
            _buildMenuCard(context, 'Simulación IA', 'Prueba los modelos predictivos', Icons.smart_toy, const SimulationScreen(), Colors.green),
            _buildMenuCard(context, 'Centro de Alertas', 'Estado de mantenimiento', Icons.warning_amber, const AlertsScreen(), Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Widget screen, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)).then((_) => _loadUser()), // Recarga por si cambió algo
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}