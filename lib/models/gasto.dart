// Modelo que representa un gasto registrado por un usuario.
class Gasto {
  final int? id;
  final double monto;
  final String descripcion;
  final DateTime fecha;
  final int? usuarioId;

  // Constructor que recibe el monto, la descripción, la fecha y el usuario del gasto.
  Gasto({
    this.id,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    this.usuarioId,
  });

  // Crea un Gasto con los datos del mapa JSON devuelto por la API.
  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'],
      monto: (json['monto'] as num).toDouble(),
      descripcion: json['descripcion'],
      fecha: DateTime.parse(json['fecha']),
      usuarioId: json['usuarioId'] ?? 0,
    );
  }

  // Convierte el gasto actual en un mapa JSON apto para enviar a la API.
Map<String, dynamic> toJson() {
    final mapa = <String, dynamic>{
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'usuarioId': usuarioId,
    };
    if (id != null) {
      mapa['id'] = id;
    }
    return mapa;
  }
}
