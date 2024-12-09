import 'package:flutter/material.dart';
import 'package:astro_office/config/officeApi/database_service.dart';
import 'package:astro_office/config/officeApi/auth.dart';
import 'add_card_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // Cargar métodos de pago del usuario actual
  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId =
          await _authService.getUsuarioId(); // Obtén el ID del usuario
      _cards = await _databaseService
          .fetchMetodosPagoByUser(userId); // Carga las tarjetas
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar métodos de pago: $error'),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Agregar una nueva tarjeta

  // Eliminar una tarjeta
  Future<void> _deleteCard(int cardId) async {
    try {
      // Llamada al servicio para eliminar la tarjeta
      await _databaseService.deleteMetodoPago(cardId);

      // Recargar tarjetas después de eliminar
      await _loadCards();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarjeta eliminada con éxito.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar tarjeta: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de Pago'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? Center(
                  child: Text(
                    'No hay métodos de pago agregados.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCards, // Permite hacer un "pull-to-refresh"
                  child: ListView.builder(
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: Text(card['numero_enmascarado']),
                          subtitle: Text(
                            '${card['proveedor']} - ${card['fecha_vencimiento']}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _deleteCard(card['id']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCardScreen(),
            ),
          );

          if (result != null && result == true) {
            await _loadCards(); // Recargar tarjetas si se añadió una
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
