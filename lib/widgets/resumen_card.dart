import 'package:flutter/material.dart';

class ResumenCard extends StatelessWidget {
  // 1. Definimos qué datos necesita esta tarjeta para funcionar
  final String titulo;
  final double monto;
  final IconData icono;
  final Color colorIcono;

  // 2. El constructor que recibe esos datos
  const ResumenCard({
    super.key,
    required this.titulo,
    required this.monto,
    required this.icono,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    // 3. Estilizamos la tarjeta con Material Design 3
    return Card(
      elevation: 4, // Sombra suave para dar profundidad
      margin: const EdgeInsets.all(10), // Espacio alrededor de la tarjeta
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Espacio interno
        child: Row(
          children: [
            // Contenedor circular para el icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorIcono.withOpacity(0.15), // Color suave de fondo
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: colorIcono,
                size: 30,
              ),
            ),
            const SizedBox(width: 20), // Separación
            // Textos de título y monto
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alineado a la izquierda
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5), // Pequeña separación
                Text(
                  // Formateo básico de moneda (para mock data)
                  '\$${monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}