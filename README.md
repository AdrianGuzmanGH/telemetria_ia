# Telemetría GPS + IA con Flutter

Aplicación de demostración que captura telemetría GPS en tiempo real, la visualiza en un mapa y clasifica el comportamiento de conducción usando un clasificador heurístico (fácilmente reemplazable por un modelo TFLite on-device).

![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-Educational-green)

---

## ✨ Características

- **Telemetría real:** Captura posiciones GPS del dispositivo con `geolocator`.
- **Modo simulación:** Genera telemetría sintética para probar la IA sin necesidad de desplazarse.
- **Mapa interactivo:** Renderiza la ruta y el marcador con `flutter_map` + OpenFreeMap (sin API Key).
- **Clasificador IA desacoplado:** Interfaz `AiClassifier` que permite cambiar entre heurística y TensorFlow Lite sin tocar la UI.
- **Persistencia:** Guarda la configuración de simulación con `shared_preferences`.
- **Detección de anomalías:** Clasifica en tiempo real como `Detenido`, `Normal`, `Conducción agresiva` o `Exceso de velocidad`.

---

## 📸 Capturas de pantalla

Aquí puedes ver la aplicación en funcionamiento:

### 1. Pantalla de inicio
> Selección entre los dos modos: Telemetría real y Modo simulación.

<img width="1366" height="768" alt="Pantalla de inicio" src="https://github.com/user-attachments/assets/507a9881-04e6-48c5-8dec-b85e0a3e70f6" />

### 2. Telemetría real — Detenido
> GPS capturando la posición con el clasificador mostrando "Detenido" (filtra el ruido del GPS).

<img width="571" height="1280" alt="Telemetría real detenido" src="https://github.com/user-attachments/assets/f2903481-7f0f-4bcc-a6cf-d397f81739b8" />

### 3. Configuración de simulación
> Sliders de velocidad y radio del recorrido. Los valores se guardan automáticamente.

<img width="1366" height="768" alt="Configuración simulación" src="https://github.com/user-attachments/assets/af3a77fe-d0b7-49fa-a63e-12b4da25f17c" />

### 4. Simulación en curso — Normal
> El marcador da vueltas dibujando la ruta. Estado "Normal" con riesgo bajo.

<img width="1366" height="768" alt="Simulación normal" src="https://github.com/user-attachments/assets/f350c991-beb5-4ce0-8d31-0a6d4a2723d8" />

### 5. Simulación — Exceso de velocidad
> Modo agresivo activo: 120 km/h y alerta "Exceso de velocidad" en rojo.

<img width="1366" height="768" alt="Simulación agresiva" src="https://github.com/user-attachments/assets/599ea2c6-1c6a-4b08-b4aa-617b8054896a" />

---

## 🛠️ Requisitos previos

Antes de ejecutar el proyecto, asegúrate de tener instalado:

| Herramienta | Versión mínima | Cómo verificar |
|---|---|---|
| **Flutter SDK** | 3.22 o superior | `flutter --version` |
| **Dart** | 3.3 o superior | `dart --version` |
| **Git** | Cualquiera reciente | `git --version` |
| **Android Studio** | Última estable | — |
| **Android SDK** | API 23+ | SDK Manager |
| **Java JDK** | 17 | `java -version` |

Verifica que todo esté correcto con:

```bash
flutter doctor
```

Debes ver ✅ al menos en **Flutter** y **Android toolchain**. Si aparece ❌, sigue las instrucciones que el propio comando te da.

---

## 🚀 Cómo ejecutar el proyecto

### 1. Clonar el repositorio

```bash
git clone https://github.com/AdrianGuzmanGH/telemetria_ia.git
cd telemetria_ia
```

### 2. Instalar dependencias

```bash
flutter pub get
```

Esto descarga todas las librerías declaradas en el `pubspec.yaml` (`geolocator`, `flutter_map`, `flutter_map_vector_tiles`, `shared_preferences`, `permission_handler`, etc.).

Si algo falla, prueba:

```bash
flutter clean
flutter pub get
```

### 3. Conectar el dispositivo

**Opción A: Dispositivo Android físico**

1. En el celular: **Ajustes → Acerca del teléfono → Número de compilación** (toca 7 veces para activar las opciones de desarrollador).
2. Ve a **Ajustes → Opciones de desarrollador → Depuración USB** y actívala.
3. Conecta el celular al PC por USB.
4. Acepta el mensaje *"¿Permitir depuración USB?"* que aparece en el celular.

**Opción B: Emulador de Android**

1. Abre **Android Studio**.
2. Ve a **Device Manager → Create Device**.
3. Elige un dispositivo (por ejemplo, Pixel 6) y una imagen del sistema (API 34).
4. Arranca el emulador.

### 4. Verificar dispositivos disponibles

```bash
flutter devices
```

Deberías ver algo como:

```
Found 2 connected devices:
  GFY LX3 (mobile)  • AF5MCP4C11413859 • android-arm64 • Android 14 (API 34)
  sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 14 (API 34)
```

### 5. Ejecutar la app

```bash
flutter run
```

Si tienes varios dispositivos conectados, especifica el ID:

```bash
flutter run -d <ID_DISPOSITIVO>
```

Por ejemplo:

```bash
flutter run -d AF5MCP4C11413859
```

> ⏳ **La primera ejecución puede tardar 3-5 minutos** porque Gradle descarga las dependencias de compilación por primera vez. Las siguientes veces será mucho más rápido.

### 6. Aceptar permisos en el dispositivo

Cuando abras la pantalla de **Telemetría real**, la app pedirá permiso de ubicación. Selecciona **"Permitir mientras la app está en uso"**.

Si por error lo denegaste, ve a **Ajustes → Apps → telemetria_ia → Permisos → Ubicación** y actívalo manualmente.

---

## 🧭 Cómo usar la aplicación

### 🛰️ Modo Telemetría real

1. En la pantalla de inicio, toca **"Telemetría real"**.
2. Presiona **"Iniciar telemetría"**.
3. Acepta los permisos de ubicación.
4. En 1-3 segundos verás tu ubicación en el mapa.
5. El panel inferior muestra: estado IA, velocidad, distancia y número de muestras.
6. Si te mueves, la ruta se dibuja en el mapa y el estado cambia de **Detenido → Normal**.
7. Presiona **"Detener telemetría"** para finalizar.

### 🎮 Modo Simulación

1. En la pantalla de inicio, toca **"Modo simulación"**.
2. Ajusta los parámetros:
   - **Velocidad:** slider de 0 a 160 km/h (con presets: Detenido, Ciudad, Carretera, Acelerón).
   - **Radio del recorrido:** slider de 10 a 200 metros.
3. Presiona **"Iniciar simulación"**.
4. Observa el marcador rojo dar vueltas dibujando la ruta sintética.
5. Presiona **"Agresivo"** para simular un exceso de velocidad a 120 km/h.
6. Presiona **"Detener"** para volver a la pantalla de configuración.

> 💾 La configuración se guarda automáticamente con `shared_preferences` y se recupera la próxima vez que entres.

---

## 🔧 Comandos útiles

```bash
# Ver versión de Flutter
flutter --version

# Ver dispositivos conectados
flutter devices

# Ver emuladores disponibles
flutter emulators

# Lanzar un emulador específico
flutter emulators --launch <id_emulador>

# Limpiar todo y reinstalar
flutter clean
flutter pub get

# Ejecutar con logs detallados (útil para depurar)
flutter run --verbose

# Actualizar dependencias
flutter pub upgrade

# Revisar dependencias desactualizadas
flutter pub outdated

# Analizar el código en busca de problemas
flutter analyze

# Ejecutar los tests
flutter test

# Actualizar el proyecto desde GitHub
git pull
```

---

## 🐛 Solución de problemas

| Error | Causa | Solución |
|---|---|---|
| `flutter: command not found` | Flutter no está en el PATH | Añade `C:\ruta\a\flutter\bin` a las variables de entorno |
| `Running Gradle task 'assembleDebug'...` se queda colgado | Gradle descargando por primera vez | Espera 5-10 min, es normal la primera vez |
| `Unsupported Gradle project` | Falta `android/` o está corrupto | Ejecuta `flutter create .` en la raíz del proyecto |
| `Could not find a device` | Celular no autorizado | Reconecta el cable y acepta "Depurar USB" |
| `Missing permissions` | Permisos de ubicación denegados | Acepta "Permitir mientras la app está en uso" |
| El mapa no carga | Sin conexión a internet | Conéctate a WiFi o datos móviles |
| El mapa muestra cuadros grises | Problema temporal del servidor de tiles | Espera unos segundos o reinicia la app |
| `NDK not found` | Falta el NDK en el SDK | **No es necesario para este proyecto.** Ejecuta `flutter doctor --android-licenses` o ignora la advertencia |
| `Access blocked` de OpenStreetMap | Estás usando un proveedor que ya bloquea el acceso | Este proyecto usa **OpenFreeMap**, no debería pasar |
| `API key required` en el mapa | Proveedor de tiles cambió su política | Este proyecto usa **OpenFreeMap**, no requiere API key |
| La app se cierra al iniciar | Falta declarar permisos en AndroidManifest | Verifica el archivo `android/app/src/main/AndroidManifest.xml` |
| `Execution failed for task ':app:compileFlutterBuildDebug'` | Error de sintaxis en Dart | Revisa el panel de errores que aparece en la terminal |

---

## 📚 Dependencias principales

| Paquete | Versión | Para qué se usa |
|---|---|---|
| `geolocator` | ^13.0.1 | Captura GPS y manejo de permisos de ubicación |
| `flutter_map` | ^8.3.2 | Widget de mapa interactivo |
| `latlong2` | ^0.10.1 | Tipos `LatLng` para coordenadas |
| `flutter_map_vector_tiles` | ^2.9.0 | Renderizado de tiles vectoriales de OpenFreeMap |
| `shared_preferences` | ^2.3.2 | Persistencia local de la configuración |
| `permission_handler` | ^11.3.1 | Manejo de permisos nativos Android/iOS |

---

## 🗺️ Proveedor de mapas: OpenFreeMap

Este proyecto usa **OpenFreeMap** para renderizar el mapa. ¿Por qué?

| Proveedor | API Key | Límites | Coste |
|---|---|---|---|
| Google Maps | ✅ Requiere | Sí | Freemium |
| OpenStreetMap público | ❌ | Bloquea si no envías User-Agent | Gratis |
| CartoDB | ✅ Requiere (2026) | Sí | Freemium |
| **OpenFreeMap** ✅ | ❌ **No requiere** | **Sin límites** | **Gratis** |

OpenFreeMap sirve **tiles vectoriales** con el estilo `liberty`, lo que da un mapa moderno y fluido sin necesidad de registrarse ni pagar.

---

## 👥 Autores

- **Adrian Guzman** — [@AdrianGuzmanGH](https://github.com/AdrianGuzmanGH)
- **Jaider Paredes**

---

## 📄 Licencia

Este proyecto es de **uso educativo**. Puedes reutilizarlo, modificarlo y aprender de él libremente. No se permite su uso comercial sin autorización.

---

## 🙏 Créditos

- [OpenFreeMap](https://openfreemap.org/) — Tiles vectoriales gratis sin API key.
- [OpenStreetMap](https://www.openstreetmap.org/) — Datos geográficos base.
- [flutter_map](https://pub.dev/packages/flutter_map) — Widget de mapa para Flutter.
- [geolocator](https://pub.dev/packages/geolocator) — Captura GPS multiplataforma.
- [TensorFlow Lite](https://www.tensorflow.org/lite) — IA on-device (trabajo futuro).

---

⭐ Si este proyecto te fue útil, dale una estrella en GitHub.
