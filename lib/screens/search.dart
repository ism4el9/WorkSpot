import 'package:astro_office/config/officeApi/auth.dart';
import 'package:astro_office/screens/home_page.dart';
import 'package:astro_office/screens/office_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OfficeSearchPage extends StatefulWidget {
  const OfficeSearchPage({super.key});

  @override
  State<OfficeSearchPage> createState() => _OfficeSearchPageState();
}

class _OfficeSearchPageState extends State<OfficeSearchPage> {
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  bool? isPrivateSelected;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int attendees = 0;
  final TextEditingController _sectorController = TextEditingController();

  final List<Map<String, String>> nearbyOffices = [
    {
      "direccion": "Av. Amazonas y Naciones Unidas",
      "edificio": "Edificio World Trade Center",
      "personas": "Capacidad: 15 personas",
      "tipo": "Privado",
    },
    {
      "direccion": "Av. República y Shyris",
      "edificio": "Edificio República Plaza",
      "personas": "Capacidad: 10 personas",
      "tipo": "Compartido",
    },
    {
      "direccion": "Calle Eloy Alfaro y 6 de Diciembre",
      "edificio": "Edificio Metropolitan",
      "personas": "Capacidad: 8 personas",
      "tipo": "Privado",
    },
  ];

  List<Map<String, String>> get filteredOffices {
    if (isPrivateSelected == null) {
      return nearbyOffices;
    }
    String tipo = isPrivateSelected! ? "Privado" : "Compartido";
    return nearbyOffices.where((office) => office["tipo"] == tipo).toList();
  }

  void _resetFilters() {
    setState(() {
      isPrivateSelected = null;
      _sectorController.clear();
      selectedDate = null;
      startTime = null;
      endTime = null;
      attendees = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Búsqueda",
          style: GoogleFonts.firaSans(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNeumorphicToggleButton("Privado", true),
                  const SizedBox(width: 8),
                  _buildNeumorphicToggleButton("Compartido", false),
                ],
              ),
              const SizedBox(height: 16),
              _buildNeumorphicTextField(),
              const SizedBox(height: 16),
              const Text(
                "Recomendaciones",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildNeumorphicOfficeList(),
              const SizedBox(height: 16),
              const Text(
                "Fecha de Reserva",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildNeumorphicDatePicker(context),
              const SizedBox(height: 16),
              const Text(
                "Horas de Reserva",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildNeumorphicTimePicker(context),
              const SizedBox(height: 24),
              const Text(
                "Número de Asistentes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildNeumorphicAttendeesCounter(),
              const SizedBox(height: 24),
              _buildNeumorphicActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicToggleButton(String text, bool isPrivate) {
    bool isSelected = isPrivateSelected == isPrivate;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                offset: const Offset(4, 4),
                blurRadius: 10,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              isPrivateSelected = isSelected ? null : isPrivate;
            });
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicTextField() {
    return Container(
      decoration: _neumorphicDecoration(false),
      child: TextField(
        controller: _sectorController,
        decoration: const InputDecoration(
          labelText: '¿En qué sector o edificio?',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }

  Widget _buildNeumorphicOfficeList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredOffices.length,
      itemBuilder: (context, index) {
        final office = filteredOffices[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: _neumorphicDecoration(false),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OfficeDetailScreen(
                    isUserLoggedIn:AuthService().isLoggedIn(),
                    officeDetails: office, // Agrega servicios dinámicos si están disponibles
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(
                office["edificio"]!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              subtitle: Text(
                "${office["direccion"]!}\n${office["personas"]!}",
              ),
              trailing: Text(
                office["tipo"]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeumorphicDatePicker(BuildContext context) {
    return Container(
      decoration: _neumorphicDecoration(false),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(
          selectedDate == null
              ? 'Seleccione el Día'
              : 'Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2025),
          );
          if (picked != null) {
            setState(() {
              selectedDate = picked;
            });
          }
        },
      ),
    );
  }

  Widget _buildNeumorphicTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: _neumorphicDecoration(false),
            child: ListTile(
              title: Text(
                startTime == null
                    ? 'Hora de Inicio'
                    : 'Inicio: ${DateFormat('HH:mm').format(DateTime(0, 0, 0, startTime!.hour, startTime!.minute))}',
              ),
              onTap: () => _selectTime(context, true),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: _neumorphicDecoration(false),
            child: ListTile(
              title: Text(
                endTime == null
                    ? 'Hora de Fin'
                    : 'Fin: ${DateFormat('HH:mm').format(DateTime(0, 0, 0, endTime!.hour, endTime!.minute))}',
              ),
              onTap: () => _selectTime(context, false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeumorphicAttendeesCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _neumorphicDecoration(false),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Número de Asistentes:'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (attendees > 0) {
                    setState(() {
                      attendees--;
                    });
                  }
                },
              ),
              Text('$attendees'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    attendees++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _resetFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text("Borrar Filtros"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        authService: AuthService(),
                        results: true,
                      )),
              (Route<dynamic> route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text("Buscar"),
        ),
      ],
    );
  }

  // Widget _buildActionButton(String label, VoidCallback onPressed) {
  //   return Expanded(
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(horizontal: 4),
  //       decoration: _neumorphicDecoration(false),
  //       child: ElevatedButton(
  //         onPressed: onPressed,
  //         style: ElevatedButton.styleFrom(
  //           elevation: 0,
  //           backgroundColor: Colors.transparent,
  //           foregroundColor: Theme.of(context).colorScheme.onPrimary,
  //         ),
  //         child: Text(label),
  //       ),
  //     ),
  //   );
  // }

  BoxDecoration _neumorphicDecoration(bool isPressed) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: isPressed
          ? []
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
    );
  }
}
