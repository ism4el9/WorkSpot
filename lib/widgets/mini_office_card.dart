import 'package:astro_office/config/officeApi/error_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfficeCardMini extends StatefulWidget {
  final officeData;
  final VoidCallback? onFavoriteChanged;

  const OfficeCardMini(
      {super.key, required this.officeData, this.onFavoriteChanged});

  @override
  State<OfficeCardMini> createState() => _OfficeCardMiniState();
}

class _OfficeCardMiniState extends State<OfficeCardMini> {
  bool isFavorite = true;
  bool isLoading = false;

  Future<void> toggleFavorite() async {
    if (isLoading) return; // Evitar múltiples clics
    setState(() {
      isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      final usuarioResponse = await Supabase.instance.client
          .from('usuarios')
          .select('id')
          .eq('auth_user_id', user.id)
          .single();

      if (isFavorite) {
        // Eliminar de favoritos
        await Supabase.instance.client.from('favoritos').delete().match({
          'usuario_id': usuarioResponse[
              'id'], // Obtén el usuario_id desde la tabla usuarios
          'oficina_id': widget.officeData['id'],
        });
        if (widget.onFavoriteChanged != null) {
          widget.onFavoriteChanged!();
        }
      } else {
        // Agregar a favoritos
        await Supabase.instance.client.from('favoritos').insert({
          'usuario_id': usuarioResponse[
              'id'], // Obtén el usuario_id desde la tabla usuarios
          'oficina_id': widget.officeData['id'],
        });
      }

      setState(() {
        isFavorite = !isFavorite; // Alternar estado de favorito
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.handleError(e))),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen en miniatura
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.officeData['oficinas_imagenes'][0]['url'],
                width: 80,
                height: 80,
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
            const SizedBox(width: 10),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.officeData['nombre'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.officeData['tipo'] == 'Privado'
                        ? '${widget.officeData['capacidad']} personas max.'
                        : '${widget.officeData['capacidad']} puestos.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${widget.officeData['precio_por_hora'].round()}/h',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Chip y botón favorito
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.officeData['tipo'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  onPressed: toggleFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
