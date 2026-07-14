class Deuda {
  final int? id;
  final String nombre;
  final double total;
  double pagado; 
  final DateTime fecha;
  final DateTime fechaPago;
  final int? usuarioId;

  Deuda({
    this.id,
    required this.nombre,
    required this.total,
    this.pagado = 0.0, // Por defecto inicia en 0
    required this.fecha,
    required this.fechaPago,
    this.usuarioId,
  });

  // --- LÓGICA DE NEGOCIO (POO) ---
  
  // Calcula cuánto falta por pagar automáticamente
  double get restante => total - pagado;

  // Calcula el porcentaje pagado (ideal para tu barra de progreso: 0.0 a 1.0)
  double get porcentajePagado => (total > 0) ? (pagado / total) : 0.0;

  // Método para registrar un pago
  void registrarPago(double montoPago) {
    pagado += montoPago;
    if (pagado > total) pagado = total; // Evita que se pague más del total
  }

  // --- CONVERSIÓN PARA TU API .NET ---
  factory Deuda.fromJson(Map<String, dynamic> json) {
    return Deuda(
      id: json['id'],
      nombre: json['nombre'],
      total: (json['total'] as num).toDouble(),
      pagado: (json['pagado'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha']),
      fechaPago: DateTime.parse(json['fechaPago']),
      usuarioId: json['usuarioId'] ?? 0 ,
    );
  }

Map<String, dynamic> toJson() {
    // Creamos un mapa base con los datos
    final mapa = <String, dynamic>{
      'nombre': nombre,
      'total': total,
      'pagado': pagado,
      'fecha': fecha.toIso8601String(),
      'fechaPago': fechaPago.toIso8601String(),
      'usuarioId': usuarioId,
    };
    
    // Si la deuda ya tiene un ID (es decir, viene de la base de datos), lo incluimos
    if (id != null) {
      mapa['id'] = id;
    }
    
    return mapa;
  }
}