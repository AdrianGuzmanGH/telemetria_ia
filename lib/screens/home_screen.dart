import 'package:flutter/material.dart';
import 'gps_screen.dart';
import 'simulation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telemetría GPS + IA')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Selecciona un modo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Puedes usar el GPS real del dispositivo o generar telemetría sintética.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              _modeCard(
                context,
                icon: Icons.gps_fixed,
                color: Colors.blue,
                title: 'Telemetría real',
                subtitle:
                    'Usa el GPS del dispositivo para capturar tu ubicación.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GpsScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _modeCard(
                context,
                icon: Icons.science,
                color: Colors.indigo,
                title: 'Modo simulación',
                subtitle:
                    'Genera movimiento sintético y prueba la IA sin desplazarte.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SimulationScreen()),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}