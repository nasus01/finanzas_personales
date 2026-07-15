import 'package:flutter/material.dart';
// Importamos AMBOS servicios
import '../services/ingreso_service.dart';
import '../services/gasto_service.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../models/user_session.dart';

// Pantalla que reúne y permite administrar los ingresos y gastos del usuario.
class MovimientosScreen extends StatefulWidget {
  // Constructor sin parámetros obligatorios para crear el historial de movimientos.
  const MovimientosScreen({super.key});

  @override
  // Crea el estado que carga, edita y elimina los movimientos.
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

// Estado privado que combina los movimientos obtenidos de los servicios de ingresos y gastos.
class _MovimientosScreenState extends State<MovimientosScreen> {
  // Función para obtener y mezclar ingresos y gastos
  Future<List<Map<String, dynamic>>> _obtenerTodosLosMovimientos() async {
    final ingresoService = IngresoService();
    final gastoService = GastoService();

    try {
      // Future.wait hace que ambas peticiones se ejecuten al mismo tiempo (más rápido)
      final resultados = await Future.wait([
        ingresoService.obtenerIngresos(UserSession.idUsuario),
        gastoService.obtenerGastos(UserSession.idUsuario),
      ]);

      final ingresos = resultados[0] as List<Ingreso>;
      final gastos = resultados[1] as List<Gasto>;

      List<Map<String, dynamic>> movimientosCombinados = [];

      // Convertimos los Ingresos al formato de la lista
      for (var ingreso in ingresos) {
        movimientosCombinados.add({
          'id': ingreso.id,
          'tipo': 'ingreso',
          'descripcion': ingreso.descripcion,
          'monto': ingreso.monto,
          'fecha': ingreso.fecha,
        });
      }

      // Convertimos los Gastos al formato de la lista
      for (var gasto in gastos) {
        movimientosCombinados.add({
          'id': gasto.id,
          'tipo': 'gasto',
          'descripcion': gasto.descripcion,
          'monto': gasto.monto,
          'fecha': gasto.fecha,
        });
      }

      // Ordenamos la lista por fecha (del más reciente al más antiguo)
      movimientosCombinados.sort((a, b) => b['fecha'].compareTo(a['fecha']));

      return movimientosCombinados;
    } catch (e) {
      throw Exception('Error al cargar los datos: $e');
    }
  }
  // Función para abrir la ventana de edición.
  // Recibe el mapa de un movimiento y guarda sus cambios en el servicio correspondiente.
  void _mostrarDialogoEditar(Map<String, dynamic> mov) {
    // Precargamos los datos actuales en los controladores
    final descripcionController = TextEditingController(text: mov['descripcion']);
    final montoController = TextEditingController(text: mov['monto'].toStringAsFixed(0));
    final bool esIngreso = mov['tipo'] == 'ingreso';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(esIngreso ? 'Editar Ingreso' : 'Editar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción', prefixIcon: Icon(Icons.description)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto', prefixIcon: Icon(Icons.attach_money)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
              onPressed: () async {
                if (montoController.text.isNotEmpty && descripcionController.text.isNotEmpty) {
                  bool exito = false;
                  
                  if (esIngreso) {
                    final ingresoEditado = Ingreso(
                      id: mov['id'],
                      descripcion: descripcionController.text,
                      monto: double.parse(montoController.text),
                      fecha: mov['fecha'], // Mantenemos la fecha original
                       usuarioId: UserSession.idUsuario,
                    );
                    exito = await IngresoService().actualizarIngreso(ingresoEditado);
                  } else {
                    final gastoEditado = Gasto(
                      id: mov['id'],
                      descripcion: descripcionController.text,
                      monto: double.parse(montoController.text),
                      fecha: mov['fecha'], // Mantenemos la fecha original
                      usuarioId: UserSession.idUsuario,
                    );
                    exito = await GastoService().actualizarGasto(gastoEditado);
                  }

                  if (exito && mounted) {
                    Navigator.pop(context); // Cierra la ventana
                    setState(() {}); // Recarga la lista para ver los cambios
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Actualizado correctamente'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  

  @override
  // Construye el historial y muestra los resultados obtenidos de forma asíncrona.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Historial de Movimientos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _obtenerTodosLosMovimientos(), // Llamamos a nuestra función combinada
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error de conexión:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay movimientos registrados.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final movimientos = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: movimientos.length,
            itemBuilder: (context, index) {
              final mov = movimientos[index];
              final esIngreso = mov['tipo'] == 'ingreso'; // Verificamos qué tipo es

              return Dismissible(
                // Le damos una clave única usando el tipo y el ID
                key: Key('${mov['tipo']}-${mov['id']}'),
                direction: DismissDirection.endToStart, // Solo se desliza de derecha a izquierda
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // Esta función se ejecuta cuando el usuario termina de deslizar
                onDismissed: (direction) async {
                  bool exito = false;
                  if (mov['tipo'] == 'ingreso') {
                    exito = await IngresoService().eliminarIngreso(mov['id']);
                  } else {
                    exito = await GastoService().eliminarGasto(mov['id']);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(exito ? 'Movimiento eliminado' : 'Error al eliminar'),
                        backgroundColor: exito ? Colors.green : Colors.red,
                      ),
                    );
                    // Forzamos la recarga de la pantalla para actualizar el balance global
                    setState(() {});
                  }
                },
                child: GestureDetector(
                  onTap: () => _mostrarDialogoEditar(mov), // Abrimos la ventana al tocar
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: esIngreso ? Colors.green[100] : Colors.red[100],
                        child: Icon(
                          esIngreso ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: esIngreso ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(mov['descripcion'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(mov['fecha'].toString().substring(0, 10)),
                      trailing: Text(
                        '${esIngreso ? '+' : '-'}\$${mov['monto'].toStringAsFixed(0)}',
                        style: TextStyle(
                          color: esIngreso ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ), // <-- Aquí cerramos correctamente el GestureDetector
              ); // <-- Aquí cerramos correctamente el Dismissible con su punto y coma
            },
          );
        },
      ),
    );
  }
}
