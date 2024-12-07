import 'package:astro_office/widgets/bottom_navigation_bar.dart';
import 'package:astro_office/widgets/reserved_office_card.dart';
import 'package:astro_office/widgets/shared_private_toggle.dart';
import 'package:flutter/material.dart';

class ReservedPage extends StatefulWidget {
  const ReservedPage({super.key});

  @override
  State<ReservedPage> createState() => _ReservedPageState();
}

class _ReservedPageState extends State<ReservedPage> {
  int _currentIndex = 0;

  final List<String> _routes = ['/home', '/reserved', '/profile'];
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  bool isSharedSelected = false;
  bool isPrivateSelected = false;

  final List<Map<String, String>> allOffices = [
    {
      'imageUrl':
          'https://www.ofitipo.com/modules/dbblog/views/img/post/oficina-decorada-moderna-actual-ofitipo.jpg',
      'title': 'Carcelen, Edificio EPIQ',
      'asistants': '10 asistentes',
      'time': '09:00 AM - 03:00 PM',
      'day': '20 Oct.',
      'name': 'Astudillo',
      'type': 'Privado'
    },
    {
      'imageUrl':
          'https://www.ofitipo.com/modules/dbblog/views/img/post/oficina-decorada-moderna-actual-ofitipo.jpg',
      'title': 'La Carolina, Torre Alfa',
      'asistants': '15 asistentes',
      'time': '09:00 AM - 05:00 PM',
      'day': '29 Oct.',
      'name': 'Astudillo',
      'type': 'Compartido'
    },
    {
      'imageUrl':
          'https://www.ofitipo.com/modules/dbblog/views/img/post/oficina-decorada-moderna-actual-ofitipo.jpg',
      'title': 'Quito Centro, Edificio Centro',
      'asistants': '8 asistentes',
      'time': '08:00 AM - 01:00 PM',
      'day': '22 Oct.',
      'name': 'Astudillo',
      'type': 'Privado'
    },
    {
      'imageUrl':
          'https://www.ofitipo.com/modules/dbblog/views/img/post/oficina-decorada-moderna-actual-ofitipo.jpg',
      'title': 'Plaza Foch, Edificio Moderno',
      'asistants': '5 asistentes',
      'time': '10:00 AM - 06:00 PM',
      'day': '30 Oct.',
      'name': 'Astudillo',
      'type': 'Compartido'
    },
  ];

  // Método para filtrar las oficinas según el tipo seleccionado
  List<Map<String, String>> get filteredOffices {
    return allOffices.where((office) {
      if (isSharedSelected) return office['type'] == 'Compartido';
      if (isPrivateSelected) return office['type'] == 'Privado';
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: _buildCustomSearchBar(), // Solo incluir el buscador
        titleSpacing: 0,
        toolbarHeight: 85, // Ajustar altura si es necesario
      ),
      body: Column(
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
              itemCount: filteredOffices.length,
              itemBuilder: (context, index) {
                final office = filteredOffices[index];
                return ReservedOfficeCard(
                  imageUrl: office['imageUrl']!,
                  title: office['title']!,
                  asistants: office['asistants']!,
                  time: office['time']!,
                  day: office['day']!,
                  name: office['name']!,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }

  Widget _buildCustomSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
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
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar',
                border: InputBorder.none,
              ),
              onChanged: (query) {
                // Si necesitas lógica de búsqueda, agrégala aquí
                //print("Texto ingresado: $query");
              },
            ),
          ),
        ],
      ),
    );
  }
}
