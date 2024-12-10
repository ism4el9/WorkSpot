import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:astro_office/screens/office_details.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  // Valores del rango de precios
  double _minPrice = 5;
  double _maxPrice = 100;

  // IDs de instalaciones seleccionadas
  final List<int> _selectedFacilityIds = [];

  // Instalaciones cargadas desde Supabase
  List<Map<String, dynamic>> facilitiesFromDatabase = [];

  // Oficinas cargadas desde Supabase
  List<Map<String, dynamic>> allOffices = [];
  List<Map<String, dynamic>> filteredOffices = [];

  @override
  void initState() {
    super.initState();
    _fetchFacilities();
    _fetchOffices();
  }

  // Cargar instalaciones desde la tabla "extras" en Supabase
  Future<void> _fetchFacilities() async {
    try {
      final response =
          await Supabase.instance.client.from('extras').select('id, nombre');
      setState(() {
        facilitiesFromDatabase = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error al cargar instalaciones: $e');
    }
  }

  // Cargar oficinas desde Supabase
  Future<void> _fetchOffices() async {
    try {
      final response = await Supabase.instance.client
          .from('oficinas')
          .select('*, oficinas_extras(extra_id)');
      setState(() {
        allOffices = List<Map<String, dynamic>>.from(response);
        filteredOffices = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error al cargar oficinas: $e');
    }
  }

  // Alternar selección de una instalación
  void _toggleSelection(int facilityId) {
    setState(() {
      if (_selectedFacilityIds.contains(facilityId)) {
        _selectedFacilityIds.remove(facilityId);
      } else {
        _selectedFacilityIds.add(facilityId);
      }
      _filterOffices();
    });
  }

  // Filtrar oficinas en tiempo real según instalaciones y rango de precios
  void _filterOffices() {
    setState(() {
      filteredOffices = allOffices.where((office) {
        final officePrice = office['precio_por_hora'] as double;
        final isWithinPriceRange =
            officePrice >= _minPrice && officePrice <= _maxPrice;

        if (_selectedFacilityIds.isEmpty) {
          return isWithinPriceRange;
        }

        final officeExtras = office['oficinas_extras'] as List<dynamic>;
        final extraIds = officeExtras.map((e) => e['extra_id'] as int).toList();
        final matchesFacilities =
            _selectedFacilityIds.every((id) => extraIds.contains(id));

        return isWithinPriceRange && matchesFacilities;
      }).toList();
    });
  }

  // Resetear los filtros a sus valores predeterminados
  void _resetFilters() {
    setState(() {
      _minPrice = 5;
      _maxPrice = 100;
      _selectedFacilityIds.clear();
      filteredOffices = List<Map<String, dynamic>>.from(allOffices);
    });
  }

  BoxDecoration _neumorphicDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Filtros",
          style: GoogleFonts.firaSans(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rango de Precio
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Precio por Hora",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _neumorphicDecoration(),
                  child: Column(
                    children: [
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 5,
                        max: 100,
                        divisions: 19,
                        labels: RangeLabels(
                          '\$${_minPrice.round()}',
                          '\$${_maxPrice.round()}',
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                          _filterOffices();
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mínimo: \$${_minPrice.round()}'),
                          Text('Máximo: \$${_maxPrice.round()}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Instalaciones
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Instalaciones",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration:
                      _neumorphicDecoration(), // Aplicar decoración neumórfica
                  child: facilitiesFromDatabase.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Wrap(
                          spacing: 8.0,
                          children: facilitiesFromDatabase.map((facility) {
                            final isSelected =
                                _selectedFacilityIds.contains(facility['id']);
                            return FilterChip(
                              label: Text(facility['nombre']),
                              selected: isSelected,
                              selectedColor:
                                  Theme.of(context).colorScheme.tertiary,
                              onSelected: (_) =>
                                  _toggleSelection(facility['id']),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Oficinas filtradas
          Expanded(
            child: filteredOffices.isEmpty
                ? const Center(
                    child:
                        Text('No hay oficinas que coincidan con los filtros.'),
                  )
                : ListView.builder(
                    itemCount: filteredOffices.length,
                    itemBuilder: (context, index) {
                      final office = filteredOffices[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OfficeDetailScreen(
                                officeDetails: office,
                                isUserLoggedIn: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: _neumorphicDecoration(),
                          child: ListTile(
                            title: Text(
                              office['nombre'],
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              office['descripcion'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Text(
                              '\$${office['precio_por_hora']}/h',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetFilters,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
