import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_session.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:5282/api/auth/login';

  Future<bool> iniciarSesion(String correo, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );

      if (response.statusCode == 200) {
        // Decodificamos el JSON de respuesta
        final data = json.decode(response.body);

        // Guardamos el id y nombre en la sesión global
        UserSession.idUsuario = data['id'];
        UserSession.nombreUsuario = data['nombre'];

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Método POST para registrar un nuevo usuario
  Future<bool> registrarUsuario(String nombre, String correo, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5282/api/auth/registro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'correo': correo,
          'contrasena': contrasena,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
// funcion para recuperar contraseña
  Future<bool> recuperarContrasena(String correo, String nuevaContrasena) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5282/api/auth/recuperar'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'correo': correo, 'nuevaContrasena': nuevaContrasena}),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
}