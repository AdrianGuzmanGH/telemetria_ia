import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class AiLlmService {
  // Configuración de la API 
  final String _apiKey = 'sk-proj-TuTokenSecretoAqui1234567890abcdef';
  final String _endpoint = 'https://api.openai.com/v1/chat/completions';
  
  // Bandera de seguridad: Si está en false, no se hacen peticiones reales a la red.
  // Esto evita consumir tokens o generar errores en la demo.
  final bool _enableRealApiCalls = false; 

  /// Genera un reporte predictivo usando IA Generativa (LLM).
  /// Analiza el estado del vehículo y la velocidad actual para dar un diagnóstico.
  Future<String> generatePredictiveReport(Vehicle vehicle, double currentSpeed) async {
    // 1. Construimos el prompt con los datos de telemetría
    final prompt = '''
      Eres un ingeniero experto en flotas vehiculares.
      Analiza los siguientes datos del vehículo y genera un diagnóstico breve y profesional.
      Vehículo: ${vehicle.brand} ${vehicle.model} (${vehicle.year})
      Kilometraje: ${vehicle.mileage} km
      Estado de llantas: ${vehicle.tireCondition}
      Último cambio de frenos: ${vehicle.brakeChangeDate}
      Velocidad actual: $currentSpeed km/h
      
      Si la velocidad supera los 100 km/h, advierte sobre conducción temeraria.
      Si el vehículo tiene más de 100,000 km, sugiere mantenimiento mayor.
    ''';

    // 2. Verificamos si las llamadas reales están habilitadas
    if (!_enableRealApiCalls) {
      // Retornamos una respuesta simulada de alta calidad para la demo.
      await Future.delayed(const Duration(milliseconds: 800));
      if (currentSpeed > 100) {
        return "ALERTA: El vehículo ${vehicle.brand} ${vehicle.model} está circulando a $currentSpeed km/h. "
               "Con un kilometraje de ${vehicle.mileage} km y llantas en estado ${vehicle.tireCondition}, "
               "el riesgo de accidente aumenta un 85%. Se recomienda reducir la velocidad inmediatamente.";
      }
      return "DIAGNÓSTICO: El vehículo ${vehicle.brand} ${vehicle.model} se encuentra estable. "
             "Sin embargo, se recomienda revisar los frenos (último cambio: ${vehicle.brakeChangeDate}).";
    }

    // 3. Código real de producción (se ejecutaría si _enableRealApiCalls es true)
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'Error en la API: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error de conexión con el servicio de IA: $e';
    }
  }
}