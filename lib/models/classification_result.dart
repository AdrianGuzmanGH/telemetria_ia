enum DrivingState { unknown, stopped, normal, anomaly }

class ClassificationResult {
  final DrivingState state;
  final double riskScore;
  final String label;

  const ClassificationResult({
    required this.state,
    required this.riskScore,
    required this.label,
  });

  static const unknown = ClassificationResult(
    state: DrivingState.unknown,
    riskScore: 0,
    label: 'Sin datos',
  );
}