import '../models/telemetry_point.dart';
import '../models/classification_result.dart';

abstract class AiClassifier {
  Future<void> load();
  ClassificationResult classify(List<TelemetryPoint> window);
  void dispose();
}

class HeuristicClassifier implements AiClassifier {
  /// Si la precisión es peor que esto (metros), la muestra es basura.
  static const double _badAccuracy = 30;

  /// Velocidad mínima promedio para considerarse en movimiento (km/h).
  static const double _minMovingKmh = 3;

  @override
  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  ClassificationResult classify(List<TelemetryPoint> window) {
    if (window.isEmpty) return ClassificationResult.unknown;

    final current = window.last;

    // 1) Si la precisión es pésima, no podemos confiar.
    if (current.accuracy > _badAccuracy) {
      return const ClassificationResult(
        state: DrivingState.unknown,
        riskScore: 0,
        label: 'Señal débil',
      );
    }

    // 2) Exceso de velocidad → anomalía clara.
    if (current.speedKmh > 100) {
      final score = (current.speedKmh / 160).clamp(0.0, 1.0);
      return ClassificationResult(
        state: DrivingState.anomaly,
        riskScore: score,
        label: 'Exceso de velocidad',
      );
    }

    // 3) Promedio móvil de las últimas 3 muestras para filtrar ruido.
    final recent = window.length >= 3
        ? window.sublist(window.length - 3)
        : window;
    final avgSpeed =
        recent.map((p) => p.speedKmh).reduce((a, b) => a + b) /
            recent.length;

    // 4) Si el promedio es bajo, está detenido (aunque haya ruido).
    if (avgSpeed < _minMovingKmh) {
      return const ClassificationResult(
        state: DrivingState.stopped,
        riskScore: 0.05,
        label: 'Detenido',
      );
    }

    // 5) Aceleración estimada (últimas dos muestras).
    double accel = 0;
    if (window.length >= 2) {
      final prev = window[window.length - 2];
      final dt =
          current.timestamp.difference(prev.timestamp).inMilliseconds /
              1000.0;
      if (dt > 0) accel = (current.speed - prev.speed) / dt;
    }
    final accelAbs = accel.abs();

    final speedScore = (current.speedKmh / 120).clamp(0.0, 1.0);
    final accelScore = (accelAbs / 5.0).clamp(0.0, 1.0);
    final score = (speedScore * 0.4 + accelScore * 0.6).clamp(0.0, 1.0);

    if (score > 0.65) {
      return ClassificationResult(
        state: DrivingState.anomaly,
        riskScore: score,
        label: 'Conducción agresiva',
      );
    }
    return ClassificationResult(
      state: DrivingState.normal,
      riskScore: score,
      label: 'Normal',
    );
  }

  @override
  void dispose() {}
}