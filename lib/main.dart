import 'package:flutter/material.dart';
//import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

// Punto de entrada de la aplicación. Inicia Flutter y muestra el widget raíz.
void main() {
  runApp(const MiAppFinanzas());
}

// Widget raíz de la aplicación, encargado de configurar el tema y la pantalla inicial.
class MiAppFinanzas extends StatelessWidget {
  // Constructor sin parámetros obligatorios; key permite identificar el widget.
  const MiAppFinanzas({super.key});

  @override
  // Construye la configuración global de Material Design y define LoginScreen como inicio.
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
