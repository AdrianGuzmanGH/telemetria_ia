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
  final bool compact;

  const TelemetryPanel({
    super.key,
    required this.current,
    required this.result,
    required this.totalDistanceMeters,
    required this.samples,
    required this.tracking,
    required this.onToggle,
    this.compact = false,
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

  IconData _stateIcon(DrivingState s) {
    switch (s) {
      case DrivingState.anomaly:
        return Icons.warning_amber_rounded;
      case DrivingState.normal:
        return Icons.check_circle_outline;
      case DrivingState.stopped:
        return Icons.pause_circle_outline;
      case DrivingState.unknown:
      default:
        return Icons.sensors_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: compact ? _compactBody() : _fullBody(),
      ),
    );
  }

  Widget _compactBody() {
    final color = _stateColor(result.state);
    final speed = (current?.speedKmh ?? 0).toStringAsFixed(0);
    final dist = (totalDistanceMeters / 1000).toStringAsFixed(2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_stateIcon(result.state), color: color, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: color.withOpacity(0.4)),
  ),
  child: Text(
    'Riesgo ${(result.riskScore * 100).toStringAsFixed(0)}%',
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: color,
    ),
  ),
),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric(Icons.speed, 'Velocidad', '$speed km/h'),
            ),
            Expanded(
              child: _metric(Icons.route, 'Distancia', '$dist km'),
            ),
            Expanded(
              child: _metric(Icons.timeline, 'Muestras', '$samples'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metric(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.grey.shade600),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _fullBody() {
    return Column(
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
            _stat('Velocidad',
                '${(current?.speedKmh ?? 0).toStringAsFixed(1)} km/h'),
            _stat('Distancia',
                '${(totalDistanceMeters / 1000).toStringAsFixed(2)} km'),
            _stat('Muestras', '$samples'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onToggle,
            icon: Icon(tracking ? Icons.stop : Icons.play_arrow),
            label: Text(
                tracking ? 'Detener telemetría' : 'Iniciar telemetría'),
          ),
        ),
      ],
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}