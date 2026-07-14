import 'package:flutter/material.dart';
// Importamos las pantallas que va a controlar
import 'dashboard_screen.dart';
import 'agregar_screen.dart';
import 'deudas_screen.dart';
import 'movimientos_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Esta variable guarda el número de la pestaña activa (0 = Inicio, 2 = Agregar)
  int _indiceActual = 0;

  // Lista de las pantallas a mostrar según el índice
  final List<Widget> _pantallas = [
    const DashboardScreen(), // Índice 0
    const MovimientosScreen(), // Índice 1
    const AgregarScreen(), // Índice 2
    const DeudasScreen(), // Índice 3 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El body cambia dinámicamente según la pantalla seleccionada
      body: _pantallas[_indiceActual], 
      
      // Aquí trajimos tu barra de navegación
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        currentIndex: _indiceActual, // Le decimos cuál está activa
        onTap: (index) {
          // setState avisa a Flutter que la pantalla debe recargarse con el nuevo índice
          setState(() {
            _indiceActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_rounded), label: 'Movimientos'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_rounded), label: 'Deudas'),
        ],
      ),
    );
  }
}