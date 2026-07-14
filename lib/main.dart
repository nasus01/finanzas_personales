import 'package:flutter/material.dart';
//import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MiAppFinanzas());
}

class MiAppFinanzas extends StatelessWidget {
  const MiAppFinanzas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Inteligente de Finanzas',
      debugShowCheckedModeBanner: false, // Quita la etiqueta de "DEBUG" en la esquina
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(
        
      ),
    );
  }
}