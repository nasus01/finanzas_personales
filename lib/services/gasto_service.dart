import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gasto.dart';

class GastoService {
  final String baseUrl = 'http://10.0.2.2:5282/api/gastos';

  // Método GET para consultar gastos
 Future<List<Gasto>> obtenerGastos(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?usuarioId=$usuarioId'));
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

  // Método POST para guardar un nuevo gasto
  Future<bool> crearGasto(Gasto gasto) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
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
  // --- Método Delete ---
  Future<bool> eliminarGasto(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
  // Método PUT para actualizar un gasto
  Future<bool> actualizarGasto(Gasto gasto) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${gasto.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(gasto.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}