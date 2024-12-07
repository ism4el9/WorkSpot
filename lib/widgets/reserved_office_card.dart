import 'package:flutter/material.dart';

class ReservedOfficeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String asistants;
  final String time;
  final String day;
  final String name;
  final String type; // Nuevo: "Privado" o "Compartido"

  const ReservedOfficeCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.asistants,
    required this.time,
    required this.day,
    required this.name,
    required this.type,
  });

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
  child: Image.asset(
    imageUrl,
    width: double.infinity,
    height: 200,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      // Fallback si la imagen no se encuentra o falla al cargar
      return Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: 200,
        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    },
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
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Etiqueta de tipo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: type == 'Privado'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
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
                Text(asistants),
                const SizedBox(height: 5),
                Text(time, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                const SizedBox(height: 5),
                Text(day),
                const SizedBox(height: 5),
                Text(
                  'Reservado por: $name',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
