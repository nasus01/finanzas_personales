import 'package:flutter/material.dart';
import '../models/deuda.dart';
import '../widgets/deuda_card.dart';
import '../services/deuda_service.dart';
import '../models/user_session.dart';
import '../models/gasto.dart';
import '../services/gasto_service.dart';

// Pantalla que permite consultar, pagar, editar y eliminar las deudas del usuario.
class DeudasScreen extends StatefulWidget {
  // Constructor sin parámetros obligatorios para crear la pantalla de deudas.
  const DeudasScreen({super.key});

  @override
  // Crea el estado que administra las acciones realizadas sobre cada deuda.
  State<DeudasScreen> createState() => _DeudasScreenState();
}

// Estado privado que obtiene las deudas y controla sus diálogos de pago y edición.
class _DeudasScreenState extends State<DeudasScreen> {
  final deudaService = DeudaService();

  // Esta función crea una ventanita emergente para ingresar el pago.
  // Recibe la deuda seleccionada, registra el abono y actualiza sus datos en la API.
  void _mostrarDialogoPago(Deuda deuda) {
    final montoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Abonar a ${deuda.nombre}'),
          content: TextField(
            controller: montoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto a pagar',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cierra la ventana
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
              onPressed: () async {
                if (montoController.text.isNotEmpty) {
                  double montoAbono = double.parse(montoController.text);
                  
                  // Usamos el método de tu clase POO para registrar el pago lógicamente
                  deuda.registrarPago(montoAbono);
                  
                  // Enviamos la actualización a la base de datos
                  bool exito = await deudaService.actualizarDeuda(deuda);
                  if (exito) {
                    final gastoAutomatico = Gasto(
                      monto: montoAbono,
                      descripcion: 'Abono a deuda: ${deuda.nombre}',
                      fecha: DateTime.now(),
                      usuarioId: UserSession.idUsuario,
                    );
                    await GastoService().crearGasto(gastoAutomatico);
                  }

                  if (exito && mounted) {
                    Navigator.pop(context); // Cerramos el cuadro de diálogo
                    setState(() {}); // Recargamos la pantalla para ver la barra moverse
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pago registrado correctamente'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Pagar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  // Función para editar el nombre y total de una deuda.
  // Recibe la deuda seleccionada y guarda en la API los datos modificados.
  void _mostrarDialogoEditarDeuda(Deuda deuda) {
    final nombreController = TextEditingController(text: deuda.nombre);
    final totalController = TextEditingController(text: deuda.total.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Deuda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.edit)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: totalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total de la deuda', prefixIcon: Icon(Icons.attach_money)),
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
                if (nombreController.text.isNotEmpty && totalController.text.isNotEmpty) {
                  // Creamos una copia de la deuda con los datos modificados
                  final deudaEditada = Deuda(
                    id: deuda.id,
                    nombre: nombreController.text,
                    total: double.parse(totalController.text),
                    pagado: deuda.pagado, // Respetamos lo que ya se ha pagado
                    fecha: deuda.fecha,
                    fechaPago: deuda.fechaPago,
                  );

                  bool exito = await deudaService.actualizarDeuda(deudaEditada);

                  if (exito && mounted) {
                    Navigator.pop(context); // Cierra la ventana
                    setState(() {}); // Recarga la lista
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deuda actualizada'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  // Construye la lista de deudas y muestra los estados de carga, error o lista vacía.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gestión de Deudas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Deuda>>(
        future: deudaService.obtenerDeudas(UserSession.idUsuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay deudas registradas.', style: TextStyle(color: Colors.grey)));
          }

          final misDeudas = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: misDeudas.length,
            itemBuilder: (context, index) {
              final deuda = misDeudas[index];
           // Envolvemos todo en el Dismissible para poder deslizar y borrar
              return Dismissible(
                key: Key('deuda-${deuda.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  bool exito = await deudaService.eliminarDeuda(deuda.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(exito ? 'Deuda eliminada' : 'Error al eliminar'),
                        backgroundColor: exito ? Colors.green : Colors.red,
                      ),
                    );
                    setState(() {}); // Recargamos para que desaparezca
                  }
                },
                child: GestureDetector(
                  // Toque normal: Abre ventana de pago
                  onTap: () {
                    if (deuda.restante > 0) {
                      _mostrarDialogoPago(deuda);
                    }
                  },
                  // Mantener presionado: Abre ventana de edición
                  onLongPress: () => _mostrarDialogoEditarDeuda(deuda),
                  child: DeudaCard(deuda: deuda),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
