import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gasto.dart';

// Servicio que gestiona en la API las operaciones relacionadas con gastos.
class GastoService {
  final String baseUrl = 'https://underfed-stitch-endearing.ngrok-free.dev/api/gastos';

  // Método GET para consultar gastos.
  // Recibe el ID del usuario y devuelve todos sus gastos.
 Future<List<Gasto>> obtenerGastos(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?usuarioId=$usuarioId'),
      headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Gasto.fromJson(data)).toList();
      } else {
        throw Exception('Error al cargar los gastos');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Método POST para guardar un nuevo gasto.
  // Recibe el objeto Gasto y devuelve si se registró correctamente.
  Future<bool> crearGasto(Gasto gasto) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'},
        body: json.encode(gasto.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      } else {
        return false;
      }
    } catch (e) {
      return false; 
    }
  }
  // Método DELETE para eliminar un gasto por su identificador.
  Future<bool> eliminarGasto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
  // Método PUT para actualizar un gasto.
  // Recibe el gasto con sus cambios y devuelve si la actualización fue exitosa.
  Future<bool> actualizarGasto(Gasto gasto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${gasto.id}'),
        headers: {'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'},
        body: json.encode(gasto.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
