import '../models/vehicle.dart';

class AiClassifier {
  // Devuelve un texto con el estado general
  String evaluateRisk(double speedKmh, Vehicle vehicle) {
    if (speedKmh < 5) return 'Vehículo Detenido / Seguro';

    int riskPoints = _calculateRiskPoints(vehicle);
    bool isSpeeding = speedKmh > 80;
    bool isReckless = speedKmh > 120;

    if (isReckless && riskPoints >= 3) return '¡PELIGRO CRÍTICO! Exceso de velocidad y vehículo en mal estado.';
    if (isReckless) return '¡ALTO RIESGO! Conducción temeraria.';
    if (isSpeeding && riskPoints >= 2) return 'Advertencia: Exceso de velocidad + Fallas mecánicas.';
    if (isSpeeding) return 'Advertencia: Exceso de velocidad.';
    if (riskPoints >= 4) return 'Alerta: Vehículo requiere mantenimiento URGENTE.';
    if (riskPoints >= 2) return 'Aviso: Mantenimiento preventivo recomendado.';

    return 'Normal - Conducción y vehículo en buen estado.';
  }

  // Devuelve una lista de alertas específicas para el Centro de Alertas
  List<String> getSpecificAlerts(Vehicle vehicle) {
    List<String> alerts = [];
    int currentYear = DateTime.now().year;

    // 1. Alerta de Frenos (si tiene más de 2 años)
    if (_getYearsPassed(vehicle.brakeChangeDate, currentYear) >= 2) {
      alerts.add('🛑 Frenos desgastados (Cambio en ${vehicle.brakeChangeDate}).');
    }
    // 2. Alerta de Aceite (si tiene más de 1 año)
    if (_getYearsPassed(vehicle.oilChangeDate, currentYear) >= 1) {
      alerts.add('🛢️ Aceite vencido (Cambio en ${vehicle.oilChangeDate}).');
    }
    // 3. Alerta de Llantas
    if (vehicle.tireCondition == 'Malo') {
      alerts.add('🛞 Llantas en MAL estado. Riesgo de reventón.');
    } else if (vehicle.tireCondition == 'Regular') {
      alerts.add('🛞 Llantas regulares. Revisar presión.');
    }
    // 4. Alerta de Revisión Técnica
    if (_getYearsPassed(vehicle.technicalReviewDate, currentYear) >= 1) {
      alerts.add('📋 Revisión técnico-mecánica vencida.');
    }
    // 5. Alerta de Kilometraje
    int kms = int.tryParse(vehicle.mileage) ?? 0;
    if (kms > 100000) {
      alerts.add('⚠️ Kilometraje muy alto ($kms km). Motor desgastado.');
    }
    // 6. Alerta de Motor
    if (_getYearsPassed(vehicle.engineChangeDate, currentYear) >= 5) {
      alerts.add('⚙️ Motor sin mantenimiento mayor en más de 5 años.');
    }

    if (alerts.isEmpty) alerts.add('✅ Vehículo sin alertas pendientes.');
    return alerts;
  }

  int _calculateRiskPoints(Vehicle vehicle) {
    int points = 0;
    int currentYear = DateTime.now().year;
    
    if (_getYearsPassed(vehicle.brakeChangeDate, currentYear) >= 2) points += 2;
    if (_getYearsPassed(vehicle.oilChangeDate, currentYear) >= 1) points += 1;
    if (vehicle.tireCondition == 'Malo') points += 2;
    if (vehicle.tireCondition == 'Regular') points += 1;
    if (_getYearsPassed(vehicle.technicalReviewDate, currentYear) >= 1) points += 2;
    if ((int.tryParse(vehicle.mileage) ?? 0) > 100000) points += 2;
    if (_getYearsPassed(vehicle.engineChangeDate, currentYear) >= 5) points += 1;

    return points;
  }

  int _getYearsPassed(String dateString, int currentYear) {
    try {
      final parts = dateString.split('-');
      if (parts.length < 3) return 0;
      return currentYear - int.parse(parts[0]);
    } catch (e) {
      return 0;
    }
  }
}