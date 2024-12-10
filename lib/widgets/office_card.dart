import 'package:astro_office/config/officeApi/error_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfficeCard extends StatefulWidget {
  final officeData;

  const OfficeCard({super.key, required this.officeData});

  @override
  State<OfficeCard> createState() => _OfficeCardState();
}

class _OfficeCardState extends State<OfficeCard> {
  bool isFavorite = false;
  bool isLoading = false;

  Future<void> checkIfFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado.');
    }

    try {
      // Obtener usuario_id desde la tabla usuarios
      final usuarioResponse = await Supabase.instance.client
          .from('usuarios')
          .select('id')
          .eq('auth_user_id', user.id)
          .single();

      // Verificar si la oficina está en favoritos
      final favoriteResponse = await Supabase.instance.client
          .from('favoritos')
          .select('usuario_id') // Solo necesitamos saber si existe un registro
          .eq('usuario_id', usuarioResponse['id'])
          .eq('oficina_id', widget.officeData['id'])
          .maybeSingle();

      if (favoriteResponse != null) {
        setState(() {
          isFavorite = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.handleError(e))),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfFavorite(); // Comprobar si la oficina está en favoritos
  }

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
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.officeData['oficinas_imagenes'][0]['url'],
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: toggleFavorite,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white, // Fondo blanco
                        borderRadius: BorderRadius.circular(20),
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
                      child: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.officeData['nombre'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(widget.officeData['tipo'] == 'Privado'
                    ? '${widget.officeData['capacidad']} personas max.'
                    : '${widget.officeData['capacidad']} puestos.'),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${widget.officeData['precio_por_hora'].round()}/h',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.officeData['tipo'] == 'Privado'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.officeData['tipo'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
