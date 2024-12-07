import 'package:flutter/material.dart';
import 'add_card_screen.dart';
import 'payment_card.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentCard> paymentCards = [];

  void _navigateToAddCardScreen([PaymentCard? card]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCardScreen(existingCard: card),
      ),
    );

    if (result is PaymentCard) {
      setState(() {
        if (card != null) {
          // Si es una edición, reemplaza la tarjeta existente
          final index = paymentCards.indexOf(card);
          paymentCards[index] = result;
        } else {
          // Si es una nueva tarjeta, la agrega
          paymentCards.add(result);
        }
      });
    }
  }

  void _removeCard(PaymentCard card) {
    setState(() {
      paymentCards.remove(card);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Métodos de Pago'),
      ),
      body: paymentCards.isEmpty
          ? Center(
              child: Container(
                decoration: _neumorphicDecoration(),
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'No hay métodos de pago agregados.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: paymentCards.length,
              itemBuilder: (context, index) {
                final card = paymentCards[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: _neumorphicDecoration(),
                  child: ListTile(
                    leading: Icon(
                      card.provider == 'Visa' ? Icons.credit_card : Icons.payment,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      '${card.provider} **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    subtitle: Text(
                      'Vence: ${card.expiryDate}\nTitular: ${card.holderName}',
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToAddCardScreen(card);
                        } else if (value == 'delete') {
                          _removeCard(card);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCardScreen(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
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
}