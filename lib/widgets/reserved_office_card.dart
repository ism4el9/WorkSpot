import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ReservedOfficeCard extends StatelessWidget {
  final reserveDetails; // Nuevo: "Privado" o "Compartido"

  const ReservedOfficeCard({super.key, required this.reserveDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-4, -4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: CachedNetworkImage(
              imageUrl: reserveDetails['oficina_imagen'][0]['url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child:
                    CircularProgressIndicator(), // Indicador mientras se carga
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error,
                    color: Colors.red), // Ícono cuando falla la carga
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reserveDetails['oficina_nombre'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Etiqueta de tipo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: reserveDetails['oficina_tipo'] == 'Privado'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reserveDetails['oficina_tipo'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text('${reserveDetails['puestos']} asistentes'),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hora: ${reserveDetails['hora_inicio']} - ${reserveDetails['hora_fin']}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary)),
                    Text(
                      'Estado: ${reserveDetails['estado']}',
                      style:
                          TextStyle(color: reserveDetails['estado'] == 'cancelado'
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.tertiary,),
                    ),
                  ],
                ),
                
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Día: ${reserveDetails['fecha_reserva']}'),
                    Text(
                      'A nombre de: ${reserveDetails['nombre_reserva']}',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
