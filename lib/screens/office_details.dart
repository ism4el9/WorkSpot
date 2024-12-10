import 'package:astro_office/config/officeApi/error_handler.dart';
import 'package:astro_office/screens/login_page.dart';
import 'package:astro_office/screens/pay.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//API DE GOOGLE
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfficeDetailScreen extends StatefulWidget {
  const OfficeDetailScreen(
      {super.key,
      required this.officeDetails,
      required this.isUserLoggedIn,
      this.onFavoriteChanged});

  final VoidCallback? onFavoriteChanged;
  final Map<String, dynamic> officeDetails;
  final bool isUserLoggedIn;

  @override
  State<OfficeDetailScreen> createState() => _OfficeDetailScreenState();
}

class _OfficeDetailScreenState extends State<OfficeDetailScreen> {
  final Map<String, IconData> iconMap = {
    'print': Icons.print,
    'local_cafe': Icons.work,
    'wifi': Icons.wifi,
    'meeting_room': Icons.meeting_room,
    'ac_unit': Icons.ac_unit,
    'security': Icons.security,
    'local_parking': Icons.local_parking,
    // Añade más iconos según sea necesario
  };
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
          .eq('oficina_id', widget.officeDetails['id'])
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
    if (widget.isUserLoggedIn) {
      checkIfFavorite();
    } // Comprobar si la oficina está en favoritos
  }

  Future<void> toggleFavorite() async {
    if (widget.isUserLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Inicia Sesión para guardar un Favorito!!')),
      );
    }
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
          'oficina_id': widget.officeDetails['id'],
        });
        if (widget.onFavoriteChanged != null) {
          widget.onFavoriteChanged!();
        }
      } else {
        // Agregar a favoritos
        await Supabase.instance.client.from('favoritos').insert({
          'usuario_id': usuarioResponse[
              'id'], // Obtén el usuario_id desde la tabla usuarios
          'oficina_id': widget.officeDetails['id'],
        });
        if (widget.onFavoriteChanged != null) {
          widget.onFavoriteChanged!();
        }
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

  int numAttendees = 1;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedEntryTime = const TimeOfDay(hour: 11, minute: 0);
  TimeOfDay selectedExitTime = const TimeOfDay(hour: 12, minute: 0);
  final TextEditingController nameController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectEntryTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEntryTime,
    );
    if (picked != null && picked != selectedEntryTime) {
      setState(() {
        selectedEntryTime = picked;
      });
    }
  }

  Future<void> _selectExitTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedExitTime,
    );
    if (picked != null && picked != selectedExitTime) {
      setState(() {
        selectedExitTime = picked;
      });
    }
  }

  Future<void> _validateAndReserve(num total) async {
    // Verificar que la fecha no sea menor al día actual
    if (selectedDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La fecha seleccionada no puede ser anterior al día de hoy.')),
      );
      return;
    }

    // Verificar que la hora de entrada sea menor que la hora de salida
    final selectedStart =
        selectedEntryTime.hour + selectedEntryTime.minute / 60;
    final selectedEnd = selectedExitTime.hour + selectedExitTime.minute / 60;

    if (selectedStart >= selectedEnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La hora de entrada debe ser menor que la hora de salida.')),
      );
      return;
    }

    String removeDiacritics(String input) {
      const withDiacritics = 'áéíóúüñÁÉÍÓÚÜÑ';
      const withoutDiacritics = 'aeiouunAEIOUUN';

      return input.split('').map((char) {
        final index = withDiacritics.indexOf(char);
        return index != -1 ? withoutDiacritics[index] : char;
      }).join('');
    }

    final selectedDay = removeDiacritics(
      DateFormat('EEEE', 'es_ES').format(selectedDate).toLowerCase(),
    );
    print('selectedDay: $selectedDay');
    final disponibilidad =
        widget.officeDetails['disponibilidad'] as Map<String, dynamic>;

    // Verificar si el día tiene horarios disponibles
    if (!disponibilidad.containsKey(selectedDay)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('La oficina no está disponible el día seleccionado.')),
      );
      return;
    }

    // Verificar los horarios disponibles
    final horarios = disponibilidad[selectedDay] as List<dynamic>;
    bool isTimeAvailable = horarios.any((horario) {
      final start = TimeOfDay(
            hour: int.parse(horario['inicio'].split(':')[0]),
            minute: int.parse(horario['inicio'].split(':')[1]),
          ).hour +
          TimeOfDay(
                hour: int.parse(horario['inicio'].split(':')[0]),
                minute: int.parse(horario['inicio'].split(':')[1]),
              ).minute /
              60;

      final end = TimeOfDay(
            hour: int.parse(horario['fin'].split(':')[0]),
            minute: int.parse(horario['fin'].split(':')[1]),
          ).hour +
          TimeOfDay(
                hour: int.parse(horario['fin'].split(':')[0]),
                minute: int.parse(horario['fin'].split(':')[1]),
              ).minute /
              60;

      return horario['estado'] == 'disponible' &&
          start <= selectedStart &&
          end >= selectedEnd;
    });

    if (!isTimeAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El horario seleccionado no está disponible.')),
      );
      return;
    }

    // Verificar la cantidad de asistentes
    if (numAttendees > widget.officeDetails['capacidad']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La cantidad de asistentes excede la capacidad disponible.')),
      );
      return;
    }

    if (nameController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor ingrese a nombre de quién sera hecha la reserva')),
      );
      return;
    }

    final reservation = Reservation(
      fechaReserva: selectedDate,
      horaEntrada: selectedEntryTime,
      horaSalida: selectedExitTime,
      cantidadAsistentes: numAttendees,
      nombreReserva: nameController.text.trim(),
      total: total.toDouble(),
      oficinaId: widget.officeDetails['id'],
    );

    // Si todo está disponible, proceder con la reserva
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => widget.isUserLoggedIn
            ? PaymentPage(reservation: reservation)
            : LoginPage(reservation: reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el total según las horas seleccionadas
    final int totalHours = selectedExitTime.hour - selectedEntryTime.hour;
    final num totalPrice = widget.officeDetails['precio_por_hora'] * totalHours;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            const Text('Detalle de la Oficina'),
            const Spacer(),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              onPressed: toggleFavorite,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Imagen destacada con neumorfismo
          Container(
            decoration: _neumorphicDecoration(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.officeDetails['oficinas_imagenes'][0]['url'],
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
          ),
          const SizedBox(height: 32),

          // Detalles principales
          _buildNeumorphicContainer(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.officeDetails['nombre'],
                  style: GoogleFonts.firaSans(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.officeDetails['ubicacion']),
                const SizedBox(height: 16),
                Text(
                  '${widget.officeDetails['tipo']}',
                  style: TextStyle(
                    color: widget.officeDetails['tipo'] == 'Privado'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text('${widget.officeDetails['capacidad']} personas max.'),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // Descripción
          _buildNeumorphicContainer(
            context,
            child: Text(
              widget.officeDetails['descripcion'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),

          // Precio
          _buildNeumorphicContainer(
            context,
            child: Text(
              "Precio: \$${widget.officeDetails['precio_por_hora'].toStringAsFixed(2)}/h",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 2),

          // Servicios
          _buildNeumorphicContainer(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lo que esta oficina ofrece',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.officeDetails['oficinas_extras'].map((service) {
                  return Row(
                    children: [
                      Icon(
                        iconMap[service['extras']['icono']] ?? Icons.extension,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(service['extras']['nombre']),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // Ubicación
          _buildNeumorphicContainer(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget
                            .officeDetails['latitud'], // Coordenada de latitud
                        widget.officeDetails[
                            'longitud'], // Coordenada de longitud
                      ),
                      zoom: 15, // Nivel de zoom
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('office_location'),
                        position: LatLng(
                          widget.officeDetails['latitud'],
                          widget.officeDetails['longitud'],
                        ),
                        infoWindow: InfoWindow(
                          title: widget.officeDetails['nombre'],
                          snippet: widget.officeDetails['ubicacion'],
                        ),
                      ),
                    },
                    onMapCreated: (GoogleMapController controller) {
                      // Puedes guardar el controlador si deseas realizar acciones más adelante
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),
          _buildNeumorphicContainer(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Disponibilidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.officeDetails['disponibilidad'].entries.map((entry) {
                  final day = entry.key; // Día de la semana
                  final horarios = entry.value as List<dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(
                            day), // Capitalizar el día (e.g., "lunes" → "Lunes")
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...horarios.map((horario) {
                        final inicio = horario['inicio'];
                        final fin = horario['fin'];
                        final estado = horario['estado'];

                        return Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                estado == 'disponible'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: estado == 'disponible'
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$inicio - $fin',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                estado,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: estado == 'disponible'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Detalles de reserva
          _buildNeumorphicContainer(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalles de la reserva',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text("Fecha de reserva"),
                  subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  onTap: () => _selectDate(context),
                ),
                ListTile(
                  title: const Text("Hora de entrada"),
                  subtitle: Text(selectedEntryTime.format(context)),
                  trailing: Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  onTap: () => _selectEntryTime(context),
                ),
                ListTile(
                  title: const Text("Hora de salida"),
                  subtitle: Text(selectedExitTime.format(context)),
                  trailing: Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  onTap: () => _selectExitTime(context),
                ),
                const SizedBox(height: 4),
                ListTile(
                  title: const Text("Cantidad de asistentes"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (numAttendees > 0) numAttendees--; // Disminuir
                          });
                        },
                        icon: const Icon(Icons.remove_circle),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Abre un diálogo para ingresar el número de asistentes
                          final input = await showDialog<int>(
                            context: context,
                            builder: (BuildContext context) {
                              final TextEditingController inputController =
                                  TextEditingController(text: "$numAttendees");
                              return AlertDialog(
                                title: const Text(
                                    "Ingresar cantidad de asistentes"),
                                content: TextField(
                                  controller: inputController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "Escribe el número de asistentes",
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final value = int.tryParse(
                                          inputController.text.trim());
                                      Navigator.of(context).pop(value);
                                    },
                                    child: const Text("Aceptar"),
                                  ),
                                ],
                              );
                            },
                          );

                          // Si el usuario ingresó un número válido, actualiza la cantidad
                          if (input != null && input >= 0) {
                            setState(() {
                              numAttendees = input;
                            });
                          }
                        },
                        child: Text(
                          "$numAttendees",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            numAttendees++; // Aumentar
                          });
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '¿A nombre de quién?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 120,
        color: Theme.of(context).colorScheme.primary.withOpacity(1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total y botón de Reservar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: \$${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _validateAndReserve(totalPrice);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.tertiary),
                      foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onTertiary),
                      elevation: WidgetStateProperty.all(8),
                    ),
                    child: const Text('Reservar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Fecha y horas seleccionadas
              Row(
                children: [
                  Text(
                    '${'${selectedDate.toLocal()}'.split(' ')[0]}  |  ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    '${selectedEntryTime.format(context)} - ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    selectedExitTime.format(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para crear un contenedor neumórfico reutilizable
  Widget _buildNeumorphicContainer(BuildContext context,
      {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _neumorphicDecoration(context),
      child: child,
    );
  }

  BoxDecoration _neumorphicDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(5, 5),
          blurRadius: 10,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.7),
          offset: const Offset(-5, -5),
          blurRadius: 10,
        ),
      ],
    );
  }
}

String _capitalize(String text) =>
    text[0].toUpperCase() + text.substring(1).toLowerCase();

class Reservation {
  final DateTime fechaReserva;
  final TimeOfDay horaEntrada;
  final TimeOfDay horaSalida;
  final int cantidadAsistentes;
  final String nombreReserva;
  final double total;
  final int oficinaId;

  Reservation({
    required this.fechaReserva,
    required this.horaEntrada,
    required this.horaSalida,
    required this.cantidadAsistentes,
    required this.nombreReserva,
    required this.total,
    required this.oficinaId,
  });
}
