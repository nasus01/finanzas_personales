import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'registro_screen.dart';
import 'recuperar_contrasena_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _estaCargando = false;
  final _authService = AuthService();

  void _procesarLogin() async {
    if (_correoController.text.isEmpty || _contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tus datos completos')),
      );
      return;
    }

    setState(() { _estaCargando = true; });

    // Llamamos al servicio para validar con la API en .NET
    bool loginExitoso = await _authService.iniciarSesion(
      _correoController.text.trim(),
      _contrasenaController.text,
    );

    setState(() { _estaCargando = false; });

    if (loginExitoso && mounted) {
      // pushReplacement destruye la pantalla de login para que el usuario 
      // no pueda regresar atrás con el botón del celular tras iniciar sesión.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales incorrectas o error de conexión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono principal o logo de la app
              Icon(Icons.account_balance_wallet_rounded, size: 100, color: Colors.blue[800]),
              const SizedBox(height: 20),
              Text(
                'Finanzas Personales',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              const Text(
                'Ingresa para administrar tu dinero',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Campo de Correo
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              TextFormField(
                controller: _contrasenaController,
                obscureText: true, // Oculta el texto con puntitos
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Entrar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _estaCargando ? null : _procesarLogin,
                child: _estaCargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),
              // --- NUEVO BOTÓN PARA IR A REGISTRO ---
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistroScreen()),
                  );
                },
                child: Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                ),
              ),
              // --- BOTÓN PARA RECUPERAR CONTRASEÑA ---
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecuperarContrasenaScreen()),
                  );
                },
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}