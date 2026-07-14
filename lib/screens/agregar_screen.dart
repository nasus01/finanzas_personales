import 'package:flutter/material.dart';
import '../models/ingreso.dart';
import '../services/ingreso_service.dart';
import '../models/gasto.dart';
import '../services/gasto_service.dart';
import '../models/deuda.dart';
import '../services/deuda_service.dart';
import '../models/user_session.dart';

class AgregarScreen extends StatefulWidget {
  const AgregarScreen({super.key});

  @override
  State<AgregarScreen> createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  // 1. Controladores para capturar lo que el usuario escribe
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  String _tipoSeleccionado = 'ingreso'; // Por defecto seleccionado
  bool _estaGuardando = false; // Para el circulito de carga
  
  final _ingresoService = IngresoService();
  final _gastoService = GastoService();
  final _deudaService = DeudaService();

  // 2. Función que se ejecuta al presionar el botón Guardar
  Future<void> _guardarTransaccion() async {
    // Validamos que no envíen campos vacíos
    if (_montoController.text.isEmpty || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }
    // ---> INICIO DEL FILTRO DE SEGURIDAD <---
    // 1. Cambiamos comas por puntos automáticamente
    String montoTexto = _montoController.text.replaceAll(',', '.');
    
    // 2. Intentamos convertirlo de forma segura (tryParse no explota si falla, solo devuelve null)
    double? montoValidado = double.tryParse(montoTexto);

    // 3. Si el usuario escribió letras o símbolos extraños, lanzamos el aviso rojo y detenemos el proceso
    if (montoValidado == null || montoValidado <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monto inválido. Ingresa solo números enteros o decimales con punto.'),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }
    // ---> FIN DEL FILTRO DE SEGURIDAD <---

    setState(() { _estaGuardando = true; });

    if (_tipoSeleccionado == 'ingreso') {
      // Instanciamos tu clase Ingreso con los datos del formulario
      final nuevoIngreso = Ingreso(
        monto: montoValidado,
        descripcion: _descripcionController.text,
        fecha: DateTime.now(), // Fecha actual automática
        usuarioId: UserSession.idUsuario, 
      );

      // Enviamos a la API de .NET
      final exito = await _ingresoService.crearIngreso(nuevoIngreso);
      

      if (exito) {
        _montoController.clear();
        _descripcionController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Ingreso guardado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar en la base de datos.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (_tipoSeleccionado == 'gasto'){
      final nuevoGasto = Gasto(
        monto: montoValidado,
        descripcion: _descripcionController.text,
        fecha: DateTime.now(),
        usuarioId: UserSession.idUsuario, 
      );

      final exito = await _gastoService.crearGasto(nuevoGasto);

      if (exito) {
        _montoController.clear();
        _descripcionController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Gasto guardado exitosamente!'),
              backgroundColor: Colors.green, // Puedes ponerlo Colors.red si prefieres diferenciarlo
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar el gasto.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }else if (_tipoSeleccionado == 'deuda') {
      final nuevaDeuda = Deuda(
        nombre: _descripcionController.text,
        total: double.parse(_montoController.text),
        pagado: 0.0,
        fecha: DateTime.now(),
        fechaPago: DateTime.now().add(const Duration(days: 30)),
        usuarioId: UserSession.idUsuario, 
      );

      final exito = await _deudaService.crearDeuda(nuevaDeuda);
      if (exito) {
        _montoController.clear();
        _descripcionController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Deuda registrada exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar la deuda.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } // <--- AQUÍ TERMINA EL NUEVO BLOQUE DE DEUDA
    setState(() { _estaGuardando = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Nueva Transacción', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView( // Permite hacer scroll si el teclado tapa la pantalla
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Registrar Movimiento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de transacción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.swap_vert_rounded),
              ),
              items: const [
                DropdownMenuItem(value: 'ingreso', child: Text('Ingreso (+)')),
                DropdownMenuItem(value: 'gasto', child: Text('Gasto (-)')),
                DropdownMenuItem(value: 'deuda', child: Text('Nueva Deuda')),
              ],
              onChanged: (value) {
                setState(() { _tipoSeleccionado = value!; });
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _montoController, // Conectado al controlador
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto',
                hintText: 'Ej. 150000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money_rounded),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _descripcionController, // Conectado al controlador
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Venta, Bono, Quincena...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_rounded),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              // Si está guardando, el botón no hace nada; si no, ejecuta la función
              onPressed: _estaGuardando ? null : _guardarTransaccion,
              child: _estaGuardando 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Guardar Transacción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}