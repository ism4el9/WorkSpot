import 'package:astro_office/config/officeApi/auth.dart';
import 'package:astro_office/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  // Valores del rango de precios
  double _minPrice = 5;
  double _maxPrice = 100;

  // Extras seleccionados
  final List<String> _selectedExtras = [];

  // Opciones disponibles
  final List<String> _extras = [
    'Wifi',
    'Impresora',
    'Café',
    'Sala de reuniones',
    'Aire acondicionado',
    'Seguridad 24/7',
    'Estacionamiento'
  ];

  @override
  void initState() {
    super.initState();
    // Restablecer los filtros en cada ingreso
    _resetFilters();
  }

  // Alternar selección de instalaciones o extras
  void _toggleSelection(List<String> selectedList, String item) {
    setState(() {
      selectedList.contains(item)
          ? selectedList.remove(item)
          : selectedList.add(item);
    });
  }

  // Resetear los filtros a sus valores predeterminados
  void _resetFilters() {
    setState(() {
      _minPrice = 5;
      _maxPrice = 100;
      _selectedExtras.clear();
    });
  }

  // Aplicar los filtros y navegar a MyHomePage
  void _applyFilters() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          authService: AuthService(),
          results: true,
          selectedFacilityIds:
              _selectedExtras, // Pasar instalaciones seleccionadas
          minPrice: _minPrice, // Pasar rango de precios
          maxPrice: _maxPrice,
        ),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rango de Precio
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
            const SizedBox(height: 16),

            // Instalaciones
            const Text(
              "Instalaciones",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _extras.map((extra) {
                final isSelected = _selectedExtras.contains(extra);
                return Container(
                  decoration: _neumorphicDecoration(),
                  child: FilterChip(
                    label: Text(extra),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.tertiary,
                    onSelected: (_) => _toggleSelection(_selectedExtras, extra),
                  ),
                );
              }).toList(),
            ),
            const Spacer(), // Empuja los botones hacia abajo

            // Botones de Limpiar Filtros y Aplicar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4E78), // Color azul
                    foregroundColor: Colors.white, // Texto blanco
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _resetFilters,
                  child: const Text("Limpiar Filtros"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4E78), // Color azul
                    foregroundColor: Colors.white, // Texto blanco
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _applyFilters,
                  child: const Text("Aplicar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}