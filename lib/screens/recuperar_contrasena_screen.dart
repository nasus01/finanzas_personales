import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() => _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final _correoController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  bool _estaCargando = false;
  final _authService = AuthService();

  void _procesarRecuperacion() async {
    if (_correoController.text.isEmpty || _nuevaContrasenaController.text.isEmpty || _confirmarContrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, llena todos los campos')));
      return;
    }

    if (_nuevaContrasenaController.text != _confirmarContrasenaController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.orange)
      );
      return;
    }

    setState(() { _estaCargando = true; });

    // Esta función la crearemos en el próximo paso en auth_service.dart
    bool exito = await _authService.recuperarContrasena(
      _correoController.text.trim(),
      _nuevaContrasenaController.text,
    );

    setState(() { _estaCargando = false; });

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada con éxito'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Devuelve al usuario a la pantalla de Login
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: El correo no existe o hubo un problema'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_reset_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 30),
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nuevaContrasenaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva Contraseña', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmarContrasenaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Contraseña', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _estaCargando ? null : _procesarRecuperacion,
                child: _estaCargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Actualizar Contraseña', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}