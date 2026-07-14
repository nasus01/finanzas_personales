import 'package:flutter/material.dart';
import '../models/deuda.dart'; // Importamos tu clase POO

class DeudaCard extends StatelessWidget {
  final Deuda deuda; // El widget recibe un objeto Deuda completo

  const DeudaCard({super.key, required this.deuda});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre de la deuda y Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deuda.nombre,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${deuda.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // Barra de progreso que usa tu lógica de la clase Deuda
            LinearProgressIndicator(
              value: deuda.porcentajePagado, // Llama al "get" que hicimos en tu modelo
              backgroundColor: Colors.grey[200],
              color: Colors.orange,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 10),
            
            // Textos informativos de abajo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pagado: \$${deuda.pagado.toStringAsFixed(0)}', 
                     style: const TextStyle(color: Colors.grey)),
                Text('Resta: \$${deuda.restante.toStringAsFixed(0)}', 
                     style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}