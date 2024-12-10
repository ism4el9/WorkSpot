import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationDetailScreen extends StatefulWidget {
  final VoidCallback? onCancelled;
   const ReservationDetailScreen({
    super.key,
    required this.reserveDetails,
    this.onCancelled
  });

  static const Map<String, IconData> iconMap = {
    'print': Icons.print,
    'local_cafe': Icons.work,
    'wifi': Icons.wifi,
    'meeting_room': Icons.meeting_room,
    'ac_unit': Icons.ac_unit,
    'security': Icons.security,
    'local_parking': Icons.local_parking,
    // Añade más iconos según sea necesario
  };
  final Map<String, dynamic> reserveDetails;

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  bool cancelSucces = true;

  String cancelSuccesMessage = '';

  bool isCancelling = false;

  Future<void> cancelReservation(BuildContext context) async {
    if (isCancelling) return;
    setState(() {
      isCancelling = true; // Restablecer el estado
    });
  try {
    final reservaId = widget.reserveDetails['id'];

    // Obtener la hora de inicio de la reserva
    final fechaReserva = DateTime.parse(widget.reserveDetails['fecha_reserva']);
    final horaInicio = widget.reserveDetails['hora_inicio'];
    final inicioReserva = DateTime(
      fechaReserva.year,
      fechaReserva.month,
      fechaReserva.day,
      int.parse(horaInicio.split(':')[0]), // Hora
      int.parse(horaInicio.split(':')[1]), // Minutos
    );

    // Verificar si la hora actual está al menos 3 horas antes de la hora de inicio
    final now = DateTime.now();
    if (now.isAfter(inicioReserva.subtract(const Duration(hours: 3)))) {
      cancelSucces = false;
      cancelSuccesMessage = 'La reserva solo puede cancelarse hasta 3 horas antes del inicio.';
      return;
    }

    // Actualizar el estado de la reserva a 'cancelado'
    await Supabase.instance.client
        .from('reservas')
        .update({'estado': 'cancelado'})
        .eq('id', reservaId)
        ;
    if (widget.onCancelled != null) {
          widget.onCancelled!();
        }
  } catch (e) {
    cancelSucces = false;
    cancelSuccesMessage = 'Error al cancelar la reserva: $e';
  } finally {
    setState(() {
      isCancelling = false; // Restablecer el estado
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Detalles de la Reserva',
          style: GoogleFonts.firaSans(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen destacada
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 10,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: widget.reserveDetails['oficina_imagen'][0]['url'],
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
              const SizedBox(height: 16),

              // Información principal
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reserveDetails['oficina_nombre'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.reserveDetails['oficina_ubicacion'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.reserveDetails['oficina_tipo']}',
                      style: TextStyle(
                        color: widget.reserveDetails['oficina_tipo'] == 'Privado'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('${widget.reserveDetails['oficina_descripcion']}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lo que esta oficina ofrece',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...widget.reserveDetails['oficinas_extras'].map((service) {
                      return Row(
                        children: [
                          Icon(
                            ReservationDetailScreen.iconMap[service['extras']['icono']] ??
                                Icons.extension,
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            widget.reserveDetails[
                                'oficina_lat'], // Coordenada de latitud
                            widget.reserveDetails[
                                'oficina_long'], // Coordenada de longitud
                          ),
                          zoom: 15, // Nivel de zoom
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('office_location'),
                            position: LatLng(
                              widget.reserveDetails['oficina_lat'],
                              widget.reserveDetails['oficina_long'],
                            ),
                            infoWindow: InfoWindow(
                              title: widget.reserveDetails['oficina_nombre'],
                              snippet: widget.reserveDetails['oficina_ubicacion'],
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
              const SizedBox(height: 16),
              // Detalles de la reserva
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Costo Total: \$${widget.reserveDetails['oficina_precio'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      'Detalles de la Reserva',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Día: ${widget.reserveDetails['fecha_reserva']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hora: ${widget.reserveDetails['hora_inicio']} - ${widget.reserveDetails['hora_fin']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reservado a nombre de: ${widget.reserveDetails['nombre_reserva']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cantidad de asistentes: ${widget.reserveDetails['puestos']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          widget.reserveDetails['estado'] == 'cancelado'
                              ? Icons.cancel
                              : Icons.check_circle,
                          size: 20,
                          color: widget.reserveDetails['estado'] == 'cancelado'
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Estado: ${widget.reserveDetails['estado'] == 'cancelado' ? 'Cancelado' : 'Pendiente'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Mensaje final
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Text(
                  widget.reserveDetails['estado'] == 'pendiente'
                      ? 'Gracias por tu reserva. Nos alegra que hayas elegido nuestra oficina. ¡Te esperamos!'
                      : 'Gracias por tu reserva. Nos alegra que hayas elegido nuestra oficina.',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (widget.reserveDetails['estado'] == 'pendiente')
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        "Cancelar Reserva",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      content: const Text(
                        "¿Estás seguro de que deseas cancelar tu reserva?\nEsta acción no se puede deshacer.\n\n(Solo se aceptan cancelaciones hasta 3 horas antes del inicio de la reserva)",
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () async{
                            Navigator.pop(
                                context);
                                 // Cierra el diálogo sin cancelar
                          },
                          style: const ButtonStyle(
                              elevation: WidgetStatePropertyAll(5)),
                          child: const Text("No, mantener"),
                        ),
                        TextButton(
                          onPressed: () {
                            
                            Navigator.pop(
                                context);
                                 // Cierra el diálogo de confirmación
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(cancelSucces?
                                  "Reserva Cancelada con Éxito"
                                  :'No se pudo cancelar la reserva',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     Text(cancelSucces?
                                      "Lamentamos cualquier molestia"
                                      :cancelSuccesMessage,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(
                                            context);
                                            await cancelReservation(
                                            context); // Cierra el pop-up
                                         // Regresa a la pantalla anterior
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        elevation: 5,
                                      ),
                                      child: const Text("Continuar"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Sí, cancelar",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  elevation: 10,
                ),
                child: const Text('Cancelar Reserva'),
              )
          ],
        ),
      ),
    );
  }
}
