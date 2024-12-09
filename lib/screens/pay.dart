import 'package:astro_office/config/officeApi/auth.dart';
import 'package:astro_office/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'add_card_screen.dart'; // Pantalla para añadir tarjetas
import 'payment_card.dart';   // Modelo de tarjeta de pago

class PaymentPage extends StatefulWidget {
  final double totalPrice;

  const PaymentPage({super.key, this.totalPrice = 0.0});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final List<PaymentCard> _paymentMethods = []; // Lista de métodos de pago

  void _addPaymentMethod() async {
    // Navega a la pantalla AddCardScreen y espera la tarjeta añadida
    final newCard = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCardScreen(),
      ),
    );

    if (newCard != null && newCard is PaymentCard) {
      setState(() {
        _paymentMethods.add(newCard);
      });
    }
  }

  void _processPayment() {
    if (_paymentMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un método de pago')),
      );
      return;
    }

    // Mostrar diálogo de pago exitoso
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pago Exitoso"),
        content: const Text("¡Tu Oficina está Reservada!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el diálogo
              Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(
                                  authService: AuthService(),
                                  results: false,
                                  initialIndex: 1, // Usar el índice recibido
                                ),
                              ),
                              (Route<dynamic> route) => false,
                            ); // Regresa a la pantalla anterior
            },
            child: const Text("Perfecto!"),
          ),
        ],
      ),
    );
  }

  BoxDecoration _neumorphicDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Métodos de Pago"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: _neumorphicDecoration(),
              child: Text(
                "Total a Pagar: \$${widget.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Lista de métodos de pago
            Expanded(
              child: _paymentMethods.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: _neumorphicDecoration(),
                        child: const Text(
                          'No hay métodos de pago guardados',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _paymentMethods.length,
                      itemBuilder: (context, index) {
                        final card = _paymentMethods[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: _neumorphicDecoration(),
                          child: ListTile(
                            leading: Icon(
                              card.provider == "Visa"
                                  ? Icons.credit_card
                                  : card.provider == "MasterCard"
                                      ? Icons.credit_card_outlined
                                      : Icons.card_membership,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              '${card.provider} - **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
                            ),
                            subtitle: Text('Vence: ${card.expiryDate}'),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () {
                                setState(() {
                                  _paymentMethods.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Botón para añadir métodos de pago
            TextButton.icon(
              onPressed: _addPaymentMethod,
              icon: const Icon(Icons.add),
              label: const Text("Agregar Método de Pago"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Confirmar Pago",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}