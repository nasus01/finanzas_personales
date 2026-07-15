import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingreso.dart';

// Servicio que realiza las operaciones de consulta y mantenimiento de ingresos en la API.
class IngresoService {
  // ATENCIÓN AQUÍ: 
  // Cuando usas el emulador de Android, 'localhost' se refiere al propio celular.
  // Para que el emulador se comunique con tu API en .NET que corre en tu computadora,
  // Google exige usar la IP especial '10.0.2.2'.
  
  // Reemplaza el '5000' por el puerto exacto que usa tu API de .NET (ej. 5001, 7123, etc.)
  final String baseUrl = 'https://underfed-stitch-endearing.ngrok-free.dev/api/ingresos';

  // Método GET para consultar ingresos.
  // Recibe el ID del usuario y devuelve la lista de ingresos que le pertenece.
  Future<List<Ingreso>> obtenerIngresos(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?usuarioId=$usuarioId'),
      headers: {'ngrok-skip-browser-warning': 'true'},
      
      );

      if (response.statusCode == 200) {
        // Si el servidor devuelve un OK (200), decodificamos el JSON
        List jsonResponse = json.decode(response.body);
        
        // Mapeamos el JSON usando la POO que creamos en el modelo Ingreso
        return jsonResponse.map((data) => Ingreso.fromJson(data)).toList();
      } else {
        throw Exception('Error del servidor al cargar los ingresos');
      }
    } catch (e) {
      throw Exception('Error de red o conexión: $e');
    }
  }
  // --- AGREGA ESTE BLOQUE AQUÍ ---
  
  // Método POST para guardar un nuevo ingreso.
  // Recibe el objeto Ingreso y devuelve si la API lo registró correctamente.
  Future<bool> crearIngreso(Ingreso ingreso) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        // Le decimos a tu API en .NET que le estamos enviando un JSON
        headers: {'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'},
        // Convertimos tu objeto Dart a JSON usando la POO
        body: json.encode(ingreso.toJson()),
      );

      // Si .NET responde 200 (OK) o 201 (Creado), fue un éxito
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      } else {
        return false;
      }
    } catch (e) {
      return false; // Si hay error de red
    }
  }
  // Método DELETE para eliminar un ingreso mediante su identificador.
  Future<bool> eliminarIngreso(int id) async {
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
  // Método PUT para actualizar un ingreso.
  // Recibe el ingreso modificado y devuelve si la API confirmó el cambio.
  Future<bool> actualizarIngreso(Ingreso ingreso) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${ingreso.id}'),
        headers: {'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true'},
        body: json.encode(ingreso.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
  
}
