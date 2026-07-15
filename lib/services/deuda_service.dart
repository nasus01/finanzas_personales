import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/deuda.dart';

// Servicio que consulta y modifica las deudas almacenadas mediante la API.
class DeudaService {
  final String baseUrl = 'http://10.0.2.2:5282/api/deudas';

  // Método GET para consultar las deudas.
  // Recibe el ID del usuario y devuelve su lista de deudas.
  Future<List<Deuda>> obtenerDeudas(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?usuarioId=$usuarioId'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Deuda.fromJson(data)).toList();
      } else {
        throw Exception('Error al cargar las deudas');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Método POST para registrar una nueva deuda.
  // Recibe el objeto Deuda que se enviará a la API y devuelve si se guardó.
  Future<bool> crearDeuda(Deuda deuda) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(deuda.toJson()),
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
  // Método PUT para actualizar una deuda (registrar un pago).
  // Recibe la deuda modificada y devuelve si la API aceptó la actualización.
  Future<bool> actualizarDeuda(Deuda deuda) async {
    try {
      // Usamos el ID en la URL, asumiendo que tu API usa la ruta estándar: /api/deudas/5
      final response = await http.put(
        Uri.parse('$baseUrl/${deuda.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(deuda.toJson()),
      );
      
      // .NET suele responder con 200 (OK) o 204 (No Content) cuando un PUT es exitoso
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true; 
      } else {
        return false;
      }
    } catch (e) {
      return false; 
    }
  }
  // Método DELETE para eliminar una deuda.
  // Recibe el identificador de la deuda y devuelve si se eliminó correctamente.
  Future<bool> eliminarDeuda(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
