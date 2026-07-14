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
  // --- NUEVO: Variable para controlar el mes seleccionado ---
  int _mesSeleccionado = DateTime.now().month;
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

     // Filtramos ingresos y gastos comparando el mes de la fecha con el mes seleccionado
      final ingresos = (resultados[0] as List<Ingreso>).where((i) => i.fecha.month == _mesSeleccionado).toList();
      final gastos = (resultados[1] as List<Gasto>).where((g) => g.fecha.month == _mesSeleccionado).toList();
      
      // Las deudas no se filtran por mes, porque una deuda pendiente siempre debe mostrarse
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

              // --- NUEVO: SELECTOR DE MES ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3)),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _mesSeleccionado,
                    isExpanded: true,
                    icon: const Icon(Icons.calendar_month, color: Colors.blue),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Enero')),
                      DropdownMenuItem(value: 2, child: Text('Febrero')),
                      DropdownMenuItem(value: 3, child: Text('Marzo')),
                      DropdownMenuItem(value: 4, child: Text('Abril')),
                      DropdownMenuItem(value: 5, child: Text('Mayo')),
                      DropdownMenuItem(value: 6, child: Text('Junio')),
                      DropdownMenuItem(value: 7, child: Text('Julio')),
                      DropdownMenuItem(value: 8, child: Text('Agosto')),
                      DropdownMenuItem(value: 9, child: Text('Septiembre')),
                      DropdownMenuItem(value: 10, child: Text('Octubre')),
                      DropdownMenuItem(value: 11, child: Text('Noviembre')),
                      DropdownMenuItem(value: 12, child: Text('Diciembre')),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() { 
                          _mesSeleccionado = valor; 
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --- FIN SELECTOR DE MES ---
              
              // --- TARJETA DE BALANCE ---
              
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