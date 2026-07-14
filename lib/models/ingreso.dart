class Ingreso {
  // 1. Atributos (las propiedades que vienen de tu base de datos)
  final int? id;
  final double monto;
  final String descripcion;
  final DateTime fecha;
  final int usuarioId;

  // 2. Constructor (el molde para crear nuevos objetos Ingreso en memoria)
  Ingreso({
    this.id,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.usuarioId,
  });

  // 3. Método para convertir el JSON que llegará de tu API .NET a un Objeto Dart (POO)
  factory Ingreso.fromJson(Map<String, dynamic> json) {
    return Ingreso(
      id: json['id'],
      monto: (json['monto'] as num).toDouble(),
      descripcion: json['descripcion'],
      fecha: DateTime.parse(json['fecha']),
      usuarioId: json['usuarioId'] ?? 0,
    );
  }

  // 4. Método para enviar un Objeto Dart hacia tu API .NET como JSON (para el POST y PUT)
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