import 'package:flutter/material.dart';
import '../widgets/resumen_card.dart';
// Importamos los servicios y modelos
import '../services/ingreso_service.dart';
import '../services/gasto_service.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../services/deuda_service.dart';
import '../models/deuda.dart';
import 'login_screen.dart';
import '../models/user_session.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Esta función trae los datos y calcula los totales
  Future<Map<String, double>> _obtenerResumen() async {
    final ingresoService = IngresoService();
    final gastoService = GastoService();
    final deudaService = DeudaService();

    try {
      final resultados = await Future.wait([
        ingresoService.obtenerIngresos(UserSession.idUsuario),
        gastoService.obtenerGastos(UserSession.idUsuario),
        deudaService.obtenerDeudas(UserSession.idUsuario),
      ]);

      final ingresos = resultados[0] as List<Ingreso>;
      final gastos = resultados[1] as List<Gasto>;
      final deudas = resultados[2] as List<Deuda>;

      // Sumamos todos los ingresos
      double totalIngresos = 0;
      for (var ingreso in ingresos) {
        totalIngresos += ingreso.monto;
      }

      // Sumamos todos los gastos
      double totalGastos = 0;
      for (var gasto in gastos) {
        totalGastos += gasto.monto;
      }
      // --- NUEVO: Sumamos el saldo restante de todas las deudas ---
      double totalDeudas = 0;
      for (var deuda in deudas) {
        totalDeudas += deuda.restante; 
      }

      // Calculamos el balance
      double balance = totalIngresos - totalGastos;

      // Retornamos un mapa con los tres valores listos para usar
      return {
        'ingresos': totalIngresos,
        'gastos': totalGastos,
        'balance': balance,
        'deudas': totalDeudas, // <-- NUEVO DATO ENVIADO A LA PANTALLA
      };
    } catch (e) {
      throw Exception('Error al calcular el resumen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
   appBar: AppBar(
        title: const Text('Control Inteligente', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        // --- BOTÓN DE CERRAR SESIÓN ---
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_rounded),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // pushAndRemoveUntil borra todo el historial de pantallas para que no pueda volver con la flecha de retroceso
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _obtenerResumen(),
        builder: (context, snapshot) {
          // Mientras carga, mostramos el circulito en el centro
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          // Extraemos los datos calculados
          final datos = snapshot.data ?? {'ingresos': 0.0, 'gastos': 0.0, 'balance': 0.0};

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              const Text(
              'Resumen Financiero',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                     ),
                      const SizedBox(height: 5),
                       Text(
                         '¡Hola, ${UserSession.nombreUsuario}! 👋',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                       const SizedBox(height: 20),
              
              // --- TARJETA DE BALANCE ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[800]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance Disponible',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${datos['balance']!.toStringAsFixed(0)}', // Valor real
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 36, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // --- TARJETAS DE DETALLE ---
              ResumenCard(
                titulo: 'Ingresos Totales',
                monto: datos['ingresos']!, // Valor real
                icono: Icons.arrow_upward_rounded,
                colorIcono: Colors.green,
              ),
              
              ResumenCard(
                titulo: 'Gastos del Mes',
                monto: datos['gastos']!, // Valor real
                icono: Icons.arrow_downward_rounded,
                colorIcono: Colors.red,
              ),
              
              ResumenCard(
                titulo: 'Deudas Pendientes',
                // Usamos el dato real, y le ponemos "??" por si acaso llega vacío
                monto: datos['deudas'] ?? 0.0, 
                icono: Icons.credit_card_rounded,
                colorIcono: Colors.orange,
              ),
            ],
          );
        },
      ),
    );
  }
}