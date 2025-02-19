import 'package:astro_office/config/officeApi/auth.dart';
import 'package:astro_office/screens/home_page.dart';
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

  void _applySearchFilters() {
  final filters = {
    'searchQuery': _sectorController.text.trim(),
    'date': selectedDate,
    'startTime': startTime,
    'endTime': endTime,
    'attendees': attendees,
  };

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MyHomePage(
        authService: AuthService(),
        results: true,
        searchFilters: filters, // Pasar filtros seleccionados
      ),
    ),
  );
}


  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int attendees = 0;
  final TextEditingController _sectorController = TextEditingController();

  void _resetFilters() {
    setState(() {
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
              
              const SizedBox(height: 4),
              _buildNeumorphicTextField(),
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


  Widget _buildNeumorphicTextField() {
    return Container(
      decoration: _neumorphicDecoration(false),
      child: TextField(
        controller: _sectorController,
        decoration: const InputDecoration(
          labelText: '¿Edificio, Ubicación, Descripción?',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
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
          onPressed: _applySearchFilters,
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
