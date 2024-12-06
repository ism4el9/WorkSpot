import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_card.dart';

class AddCardScreen extends StatefulWidget {
  final PaymentCard? existingCard;

  const AddCardScreen({super.key, this.existingCard});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  String? _selectedProvider;

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      _nameController.text = card.holderName;
      _cardNumberController.text = card.cardNumber;
      _selectedProvider = card.provider;
      final expiryParts = card.expiryDate.split('/');
      _monthController.text = expiryParts[0];
      _yearController.text = '20${expiryParts[1]}';
    }
  }

  // Método para guardar la tarjeta
  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final newCard = PaymentCard(
        provider: _selectedProvider!,
        cardNumber: _cardNumberController.text,
        expiryDate: "${_monthController.text}/${_yearController.text.substring(2)}",
        holderName: _nameController.text,
      );
      Navigator.pop(context, newCard);
    }
  }

  // Método para generar decoración neumórfica
  BoxDecoration _neumorphicDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.7),
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
        elevation: 0,
        title: Text(
          widget.existingCard != null ? 'Editar Tarjeta' : 'Añadir Tarjeta',
          style: GoogleFonts.firaSans(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo Proveedor
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: _neumorphicDecoration(),
                  child: DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    items: ['Visa', 'MasterCard', 'AmEx']
                        .map((provider) => DropdownMenuItem(value: provider, child: Text(provider)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedProvider = value;
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Proveedor',
                      border: InputBorder.none,
                    ),
                    validator: (value) => value == null ? 'Selecciona un proveedor' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre del Titular
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: _neumorphicDecoration(),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Titular',
                      prefixIcon: Icon(Icons.person),
                      border: InputBorder.none,
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Número de Tarjeta
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: _neumorphicDecoration(),
                  child: TextFormField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    decoration: const InputDecoration(
                      labelText: 'Número de Tarjeta',
                      hintText: '1234 5678 9012 3456',
                      prefixIcon: Icon(Icons.credit_card),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.length != 16) {
                        return 'Ingresa un número de tarjeta válido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Fecha de Caducidad (Mes y Año)
                const Text(
                  "Fecha de Caducidad",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Campo Mes
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: _neumorphicDecoration(),
                        child: TextFormField(
                          controller: _monthController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: const InputDecoration(
                            labelText: "Mes",
                            hintText: "MM",
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value)! > 12 ||
                                int.tryParse(value)! < 1) {
                              return "Mes inválido";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Campo Año
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: _neumorphicDecoration(),
                        child: TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          decoration: const InputDecoration(
                            labelText: "Año",
                            hintText: "AA",
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || int.tryParse(value)! < 0) {
                              return "Año inválido";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón Guardar
                Center(
                  child: ElevatedButton(
                    onPressed: _saveCard,
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text("Guardar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}