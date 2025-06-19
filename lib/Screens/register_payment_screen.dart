import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterPaymentScreen extends StatefulWidget {
  final String serviceTitle;
  final double amount;

  const RegisterPaymentScreen({
    super.key,
    required this.serviceTitle,
    required this.amount,
  });

  @override
  State<RegisterPaymentScreen> createState() => _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState extends State<RegisterPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmar Pago',
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Servicio: ${widget.serviceTitle}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Valor: ${NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(widget.amount)} COP',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _nameController,
                label: 'Nombre del acudiente',
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Dirección',
                validator: (value) => value == null || value.isEmpty
                    ? 'Este campo es obligatorio'
                    : null,
              ),
              _buildTextField(
                controller: _cardNumberController,
                label: 'Número de tarjeta',
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.length < 16
                    ? 'Número de tarjeta inválido'
                    : null,
              ),
              _buildTextField(
                controller: _expiryController,
                label: 'Fecha de expiración (MM/AA)',
                validator: (value) => value == null ||
                        !RegExp(r'^(0[1-9]|1[0-2])/([0-9]{2})$').hasMatch(value)
                    ? 'Formato inválido'
                    : null,
              ),
              _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.length < 3
                    ? 'CVV inválido'
                    : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Pago realizado con éxito')),
                    );

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirmar pago', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }
}
