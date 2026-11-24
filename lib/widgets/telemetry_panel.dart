import 'package:flutter/material.dart';
import '../models/classification_result.dart';
import '../models/telemetry_point.dart';

class TelemetryPanel extends StatelessWidget {
  final TelemetryPoint? current;
  final ClassificationResult result;
  final double totalDistanceMeters;
  final int samples;
  final bool tracking;
  final VoidCallback onToggle;

  const TelemetryPanel({
    super.key,
    required this.current,
    required this.result,
    required this.totalDistanceMeters,
    required this.samples,
    required this.tracking,
    required this.onToggle,
  });

  Color _stateColor(DrivingState s) {
    switch (s) {
      case DrivingState.anomaly:
        return Colors.redAccent;
      case DrivingState.normal:
        return Colors.green;
      case DrivingState.stopped:
        return Colors.orange;
      case DrivingState.unknown:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: _stateColor(result.state)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _stateColor(result.state),
                    ),
                  ),
                ),
                Text('Riesgo: ${(result.riskScore * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('Velocidad', '${(current?.speedKmh ?? 0).toStringAsFixed(1)} km/h'),
                _stat('Distancia', '${(totalDistanceMeters / 1000).toStringAsFixed(2)} km'),
                _stat('Muestras', '$samples'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onToggle,
                icon: Icon(tracking ? Icons.stop : Icons.play_arrow),
                label: Text(tracking ? 'Detener telemetría' : 'Iniciar telemetría'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}