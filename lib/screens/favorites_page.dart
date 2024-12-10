import 'package:astro_office/config/officeApi/error_handler.dart';
import 'package:astro_office/screens/office_details.dart';
import 'package:astro_office/widgets/mini_office_card.dart';
import 'package:astro_office/widgets/search_bar_without_icons.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesPage extends StatefulWidget {
  final bool isUserLoggedIn;


  const FavoritesPage({super.key, required this.isUserLoggedIn,});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool isSharedSelected = false;
  bool isPrivateSelected = false;
  bool hasError = false;
  String errorMessage = '';

  List<Map<String, dynamic>> favoriteOffices = [];
  bool isLoading = true; // Para mostrar un indicador de carga

  @override
  void initState() {
    super.initState();
    if (widget.isUserLoggedIn) {
      fetchFavoriteOffices();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Si hubo un error, mostrar el SnackBar
    if (hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      });
    }
  }

  // Método para obtener las oficinas favoritas del usuario actual
  Future<void> fetchFavoriteOffices() async {
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

      final response = await Supabase.instance.client
    .from('favoritos')
    .select('''
      oficina_id,
      oficinas (
        *,
        oficinas_imagenes (url),
        oficinas_extras (
          extras (
            nombre,
            icono
          )
        )
      )
    ''')
    .eq('usuario_id', usuarioResponse['id']); // Relaciona con el usuario actual

      final data = response as List<dynamic>;
      favoriteOffices =
          data.map((e) => e['oficinas'] as Map<String, dynamic>).toList();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = ErrorHandler.handleError(e);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Guardados'),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: SearchBarWithoutIcons(),
          ),
          widget.isUserLoggedIn
              ? isLoading
                  ? const Expanded(
                      child: Center(
                        child:
                            CircularProgressIndicator(), // Indicador de carga
                      ),
                    )
                  : favoriteOffices.isEmpty
                      ? const Center(
                          child: Text(
                            'No tienes favoritos aún. ¡Agrega tus oficinas favoritas para verlas aquí!',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: favoriteOffices.length,
                            itemBuilder: (context, index) {
                              final office = favoriteOffices[index];
                              return GestureDetector(
                                onTap: () async {
                                  final result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => OfficeDetailScreen(
                                        isUserLoggedIn: widget.isUserLoggedIn,
                                        officeDetails: office,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    // Regresar a la pantalla anterior
                                    if (context.mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  }
                                },
                                child: OfficeCardMini(
                                  officeData: office,
                                  onFavoriteChanged: fetchFavoriteOffices,
                                ),
                              );
                            },
                          ),
                        )
              : const Center(
                  child: Text(
                    'Por favor, inicia sesión para ver tus oficinas favoritas.',
                    textAlign: TextAlign.center,
                  ),
                ),
        ],
      ),
    );
  }
}
