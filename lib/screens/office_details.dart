import 'package:astro_office/screens/login_page.dart';
import 'package:astro_office/screens/pay.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//API DE GOOGLE

class OfficeDetailScreen extends StatefulWidget {
  const OfficeDetailScreen({
    super.key,
    required this.officeDetails,
    this.services = const [
      {'label': 'Wi-Fi', 'icon': Icons.wifi},
      {'label': 'Impresora', 'icon': Icons.print},
      {'label': 'Café', 'icon': Icons.coffee},
      {'label': 'Sala de Reuniones', 'icon': Icons.meeting_room},
      {'label': 'Aire Acondicionado', 'icon': Icons.ac_unit},
      {'label': 'Seguridad 24/7', 'icon': Icons.security},
    ],
    required this.isUserLoggedIn,
  });

  final Map<String, dynamic> officeDetails;
  final List<Map<String, dynamic>> services;
  final bool isUserLoggedIn;

  @override
  State<OfficeDetailScreen> createState() => _OfficeDetailScreenState();
}

class _OfficeDetailScreenState extends State<OfficeDetailScreen> {
  bool isFavorite = false;

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

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
              child: Image.asset(
                'assets/default_office.jpg',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),

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
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Descripción
          _buildNeumorphicContainer(
            context,
            child: Text(
              widget.officeDetails['descripcion'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),

          // Precio
          _buildNeumorphicContainer(
            context,
            child: Text(
              "Precio: \$${widget.officeDetails['precio_por_hora']}/h",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                ...widget.services.map((service) {
                  return Row(
                    children: [
                      Icon(
                        service['icon'],
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(service['label']),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 40,
                            color: Theme.of(context).colorScheme.tertiary),
                        const SizedBox(height: 20),
                        Text(
                          'Ubicación: ${widget.officeDetails['ubicacion']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => widget.isUserLoggedIn
                              ? PaymentPage(
                                  totalPrice: totalPrice
                                      .toDouble()) // Conversión a double
                              : LoginPage(payment: true),
                        ),
                      );

                      if (result == true) {
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      }
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
