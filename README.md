# Telemetría GPS + IA con Flutter

Aplicación de demostración que captura telemetría GPS en tiempo real, la visualiza en un mapa y clasifica el comportamiento de conducción usando un clasificador heurístico (fácilmente reemplazable por un modelo TFLite on-device).

## ✨ Características

- **Telemetría real:** Captura posiciones GPS del dispositivo con `geolocator`.
- **Modo simulación:** Genera telemetría sintética para probar la IA sin necesidad de desplazarse.
- **Mapa interactivo:** Renderiza la ruta y el marcador con `flutter_map` + OpenFreeMap (sin API Key).
- **Clasificador IA desacoplado:** Interfaz `AiClassifier` que permite cambiar entre heurística y TensorFlow Lite sin tocar la UI.
- **Persistencia:** Guarda la configuración de simulación con `shared_preferences`.

## 🛠️ Requisitos previos

- Flutter 3.22 o superior.
- Dart 3.3 o superior.
- Dispositivo Android (API 23+) o emulador.
- Permisos de ubicación activados en el dispositivo.

## 🚀 Cómo ejecutar el proyecto

1. **Clonar el repositorio:**

   ```bash
   git clone https://github.com/TU_USUARIO/telemetria_ia.git
   cd telemetria_ia