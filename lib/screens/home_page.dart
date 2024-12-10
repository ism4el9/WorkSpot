import 'package:astro_office/config/officeApi/auth.dart';
import 'package:astro_office/config/officeApi/error_handler.dart';
import 'package:astro_office/config/theme/theme_provider.dart';
import 'package:astro_office/screens/favorites_page.dart';
import 'package:astro_office/screens/login_page.dart';
import 'package:astro_office/screens/office_details.dart';
import 'package:astro_office/screens/reservation_details.dart';
import 'package:astro_office/screens/filters.dart';
import 'package:astro_office/screens/payment_methods_screen.dart';
import 'package:astro_office/screens/search.dart';
import 'package:astro_office/widgets/bottom_navigation_bar.dart';
import 'package:astro_office/widgets/office_card.dart';
import 'package:astro_office/widgets/reserved_office_card.dart';
import 'package:astro_office/widgets/shared_private_toggle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  final AuthService authService;
  bool results;
  final int initialIndex; // Índice inicial para seleccionar la pestaña
  final List<String>?
      selectedFacilityIds; // Nuevo parámetro para instalaciones seleccionadas
  final double? minPrice; // Rango de precios mínimo
  final double? maxPrice; // Rango de precios máximo

  MyHomePage({
    super.key,
    required this.authService,
    required this.results,
    this.initialIndex = 0, // Valor predeterminado: pestaña "Home"
    this.selectedFacilityIds, // Inicializa el nuevo parámetro
    this.minPrice,
    this.maxPrice,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool isUserLoggedIn;
  late int _currentIndex;
  List<Map<String, dynamic>> reservedOffices = [];
  List<dynamic> allOffices = [];
  bool isLoadingReservations = true;
  bool isLoadingOffices = true;
  Map<String, dynamic>? userDetails;
  String userName = '';
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Inicia la variable isAuthenticated según el estado actual de AuthService
    isUserLoggedIn = widget.authService.isLoggedIn();
    _currentIndex = widget.initialIndex;

    if (isUserLoggedIn) {
      fetchReservedOffices();
      _loadUserDetails();
    }
    fetchAllOffices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Si hubo un error, mostrar el SnackBar
    if (hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //print(errorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      widget.results = false;
    });
  }

  bool isSharedSelected = false;
  bool isPrivateSelected = false;

  bool isDarkMode = false;

  Future<void> _loadUserDetails() async {
    try {
      final details = await AuthService().getUserDetails();
      //print('Hola $details');
      setState(() {
        userDetails = details;
        userName = details?['nombre'] ?? 'Usuario desconocido';
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = ErrorHandler.handleError(e);
      });
    }
  }

  Future<void> onCancel() async {
    await fetchReservedOffices();
  }

  // Obtener oficinas reservadas
  Future<void> fetchReservedOffices() async {
    setState(() {
      isLoadingReservations = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado.');

      final usuarioResponse = await Supabase.instance.client
          .from('usuarios')
          .select('id')
          .eq('auth_user_id', user.id)
          .single();

      // Consulta para obtener reservas y sus oficinas relacionadas
      final response = await Supabase.instance.client
          .from('reservas')
          .select('''
          id,
          nombre_reserva,
          fecha_reserva,
          hora_inicio,
          hora_fin,
          estado,
          cancelado,
          puestos,
          oficinas (
            nombre,
            descripcion,
            ubicacion,
            oficinas_imagenes (url),
            oficinas_extras (
              extras (
                nombre,
                icono
              )
            ),
            precio_por_hora,
            tipo,
            latitud,
            longitud
          )
        ''')
          .eq('usuario_id', usuarioResponse['id'])
          .order('fecha_reserva', ascending: false);
      //print('RESERVED $response');
      final data = response as List<dynamic>;
      //print('RESERVED DATA $data');
      // Combinar los datos de reservas con los de oficinas
      reservedOffices = data.map((reservation) {
        final office = reservation['oficinas'];
        return {
          'id': reservation['id'],
          'nombre_reserva': reservation['nombre_reserva'],
          'fecha_reserva': reservation['fecha_reserva'],
          'hora_inicio': reservation['hora_inicio'],
          'hora_fin': reservation['hora_fin'],
          'estado': reservation['estado'],
          'cancelado': reservation['cancelado'],
          'puestos': reservation['puestos'],
          'oficina_nombre': office['nombre'],
          'oficina_descripcion': office['descripcion'],
          'oficina_ubicacion': office['ubicacion'],
          'oficina_imagen': office['oficinas_imagenes'],
          'oficinas_extras': office['oficinas_extras'],
          'oficina_precio': office['precio_por_hora'],
          'oficina_tipo': office['tipo'],
          'oficina_lat': office['latitud'],
          'oficina_long': office['longitud'],
        };
      }).toList();
      //print('RESERVED DATA $reservedOffices');
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = ErrorHandler.handleError(e);
      });
    } finally {
      setState(() {
        isLoadingReservations = false;
      });
    }
  }

  // Obtener todas las oficinas disponibles para reserva
  Future<void> fetchAllOffices() async {
    setState(() {
      isLoadingOffices = true;
    });

    try {
      final today =
          DateFormat('EEEE', 'es_ES') // Obtener el día de la semana en español
              .format(DateTime.now())
              .toLowerCase(); // Ejemplo: "lunes", "martes", etc.
      //print('today $today');
      //print('currentTime $currentTime');
      final response =
          await Supabase.instance.client.from('oficinas').select('''
          *,
          oficinas_imagenes (url),
          oficinas_extras (
            extras (
              nombre,
              icono
            )
          )
        ''');

      final data = response as List<dynamic>;

      //print('All $response');
      allOffices = data.where((office) {
        // Filtrar por rango de precios
        final price = office['precio_por_hora'] as double? ?? 0.0;
        if (widget.minPrice != null && widget.maxPrice != null) {
          if (price < widget.minPrice! || price > widget.maxPrice!) {
            return false;
          }
        }

        // Filtrar por instalaciones seleccionadas
        if (widget.selectedFacilityIds != null &&
            widget.selectedFacilityIds!.isNotEmpty) {
          final officeExtras =
              office['oficinas_extras'] as List<dynamic>? ?? [];
          final extraNames =
              officeExtras.map((e) => e['extras']['nombre'] as String).toList();
          if (!widget.selectedFacilityIds!
              .every((selected) => extraNames.contains(selected))) {
            return false;
          }
        }

        final disponibilidad =
            office['disponibilidad'] as Map<String, dynamic>?;

        if (disponibilidad == null || disponibilidad.isEmpty) {
          return false; // No hay información de disponibilidad
        }

        final daysOfWeek = [
          'lunes',
          'martes',
          'miércoles',
          'jueves',
          'viernes',
          'sábado',
          'domingo'
        ];
        final todayIndex = daysOfWeek.indexOf(today); // Índice del día actual

        // Verificar disponibilidad desde hoy en adelante
        for (int i = 0; i < daysOfWeek.length; i++) {
          final dayIndex = (todayIndex + i) %
              daysOfWeek.length; // Avanzar ciclicamente en la semana
          final dayName = daysOfWeek[dayIndex];

          final horarios = disponibilidad[dayName] as List<dynamic>?;
          if (horarios == null || horarios.isEmpty) {
            continue; // No hay horarios para este día
          }

          if (i == 0) {
            // Verificar horarios disponibles para el día actual después de la hora actual
            final currentTime = DateTime.now();
            final hasAvailabilityToday = horarios.any((horario) {
              final inicio = DateFormat('HH:mm').parse(horario['inicio']);
              final estado = horario['estado'];
              return inicio.isAfter(currentTime) && estado == 'disponible';
            });

            if (hasAvailabilityToday) {
              return true;
            }
          } else {
            // Verificar horarios disponibles en días futuros
            final hasAvailabilityFuture = horarios.any((horario) {
              final estado = horario['estado'];
              return estado == 'disponible';
            });

            if (hasAvailabilityFuture) {
              return true;
            }
          }
        }

        return false; // No hay horarios disponibles desde hoy en adelante
      }).toList();
      //print('filtered $allOffices');
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = ErrorHandler.handleError(e);
      });
    } finally {
      setState(() {
        isLoadingOffices = false;
      });
    }
  }

  // Método para filtrar las oficinas según el tipo seleccionado
  List<dynamic> get filteredOffices {
    return allOffices.where((office) {
      if (isSharedSelected) return office['tipo'] == 'Compartido';
      if (isPrivateSelected) return office['tipo'] == 'Privado';
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredReservedOffices {
    return reservedOffices.where((office) {
      if (isSharedSelected) return office['oficina_tipo'] == 'Compartido';
      if (isPrivateSelected) return office['oficina_tipo'] == 'Privado';
      return true;
    }).toList();
  }

  // Filtra oficinas en función de las instalaciones seleccionadas
  List<dynamic> get filteredOfficesByFacilities {
    return allOffices.where((office) {
      if (widget.selectedFacilityIds != null &&
          widget.selectedFacilityIds!.isNotEmpty) {
        final List<dynamic> officeExtras = office['extras'] ?? [];
        return widget.selectedFacilityIds!
            .every((id) => officeExtras.contains(id));
      }
      return true;
    }).toList();
  }

  AppBar get appBar {
    if (_currentIndex == 1) return reservedAppBar();
    if (_currentIndex == 2) return profileAppBar();
    return homeAppBar();
  }

  Widget getBody(ThemeProvider themeProvider) {
    if (_currentIndex == 1) return reservedBody();
    if (_currentIndex == 2) return profileBody(themeProvider);
    return homeBody();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: appBar,
      body: getBody(themeProvider),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ), // Widget para la barra inferior
    );
  }

  Widget homeBody() {
    if (isLoadingOffices) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.green, // Color verde para el borde
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(4, 4),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.7),
                  offset: const Offset(-4, -4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navegar a la pantalla de búsqueda
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OfficeSearchPage(),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent, // Área clicable
                      child: const TextField(
                        enabled: false, // Deshabilitar teclado
                        decoration: InputDecoration(
                          hintText: 'Buscar',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    // Navegar a la pantalla de filtros
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FiltersPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        SharedPrivateToggle(
          isSharedSelected: isSharedSelected,
          isPrivateSelected: isPrivateSelected,
          onToggle: (int buttonNum) {
            setState(() {
              if (buttonNum == 1) {
                isSharedSelected = !isSharedSelected;
                if (isSharedSelected) isPrivateSelected = false;
              }
              if (buttonNum == 2) {
                isPrivateSelected = !isPrivateSelected;
                if (isPrivateSelected) isSharedSelected = false;
              }
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredOffices.length,
            itemBuilder: (context, index) {
              final office = filteredOffices[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfficeDetailScreen(
                        isUserLoggedIn: isUserLoggedIn,
                        officeDetails: office,
                        onFavoriteChanged: fetchAllOffices,
                      ),
                    ),
                  );

                  setState(() {
                    isUserLoggedIn = widget.authService.isLoggedIn();
                  });
                },
                child: OfficeCard(
                    officeData: office, authService: widget.authService),
              );
            },
          ),
        ),
      ],
    );
  }

  AppBar homeAppBar() {
    if (widget.results) {
      return AppBar(
        elevation: 0,
        title: Text(
          'Resultados',
          style: GoogleFonts.firaSans(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return AppBar(
        elevation: 0,
        title: Text(
          'WorkSpot: Reserva de Oficinas',
          style: GoogleFonts.firaSans(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      );
    }
  }

  Widget reservedBody() {
    if (!isUserLoggedIn) {
      return const Center(
        child: Text('Por favor, inicia sesión para ver tus reservas.'),
      );
    }

    if (isLoadingReservations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reservedOffices.isEmpty) {
      return const Center(
        child: Text('No tienes reservas aún. ¡Haz tu primera reserva ahora!'),
      );
    }
    return Column(
      children: [
        SharedPrivateToggle(
          isSharedSelected: isSharedSelected,
          isPrivateSelected: isPrivateSelected,
          onToggle: (int buttonNum) {
            setState(() {
              if (buttonNum == 1) {
                isSharedSelected = !isSharedSelected;
                if (isSharedSelected) isPrivateSelected = false;
              }
              if (buttonNum == 2) {
                isPrivateSelected = !isPrivateSelected;
                if (isPrivateSelected) isSharedSelected = false;
              }
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredReservedOffices.length,
            itemBuilder: (context, index) {
              final office = filteredReservedOffices[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailScreen(
                        reserveDetails: office,
                        onCancelled: fetchReservedOffices,
                      ),
                    ),
                  );
                },
                child: ReservedOfficeCard(reserveDetails: office),
              );
            },
          ),
        ),
      ],
    );
  }

  AppBar reservedAppBar() {
    return AppBar(
      elevation: 0,
      title: Text(
        'Reservas',
        style: GoogleFonts.firaSans(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      // titleSpacing: 0,
      // toolbarHeight: 105,
    );
  }

  Widget profileBody(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de perfil
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUserLoggedIn ? userName : 'Invitado',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Botones de iniciar sesión o registrarse (si el usuario no está autenticado)
            if (!isUserLoggedIn) ...[
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );

                  // Si el resultado es true, actualiza el estado de autenticación
                  setState(() {
                    isUserLoggedIn = widget.authService.isLoggedIn();
                  });
                },
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(3.0),
                  backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primary),
                  foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary),
                ),
                child: const Text('Inicia Sesión o Regístrate!'),
              ),
            ],
            const Divider(height: 30),

            // Sección de configuración
            const Text(
              'Configuración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Cambiar a Modo Oscuro
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    offset: const Offset(5, 5),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: const Offset(-5, -5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(Icons.dark_mode,
                    color: Theme.of(context).colorScheme.tertiary),
                title: const Text('Modo Oscuro'),
                trailing: Switch(
                  value: themeProvider.isDarkTheme,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ),
            ),

            // Guardados
            if (isUserLoggedIn)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(5, 5),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-5, -5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.bookmarks_rounded,
                      color: Theme.of(context).colorScheme.tertiary),
                  title: const Text('Favoritos'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FavoritesPage(isUserLoggedIn: isUserLoggedIn),
                      ),
                    );

                    setState(() {
                      isUserLoggedIn = widget.authService.isLoggedIn();
                    });
                  },
                ),
              ),

            // Métodos de Pago
            if (isUserLoggedIn)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(5, 5),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-5, -5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.payment,
                      color: Theme.of(context).colorScheme.tertiary),
                  title: const Text('Métodos de Pago'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentMethodsScreen(),
                      ),
                    );
                  },
                ),
              ),

            // Cerrar Sesión
            if (isUserLoggedIn)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(5, 5),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-5, -5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.logout,
                      color: Theme.of(context).colorScheme.error),
                  title: const Text('Cerrar Sesión'),
                  onTap: () async {
                    final error = await AuthService().logout();

                    if (error != null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cerrar sesión: $error'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesión cerrada exitosamente.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }

                    setState(() {
                      isUserLoggedIn = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  AppBar profileAppBar() {
    return AppBar(
      title: Text(
        'Perfil',
        style: GoogleFonts.firaSans(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
    );
  }
}
