import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const TelemetriaApp());

class TelemetriaApp extends StatelessWidget {
  const TelemetriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telemetría GPS + IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}