import 'package:aplicacion_taller/entities/service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ServiceEditScreen extends StatelessWidget {
  static const String name = 'editar-servicio-screen';
  final Service service;

  const ServiceEditScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar servicio'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: _RegistroServicioView(service: service),
        ),
      ),
    );
  }
}

class _RegistroServicioView extends StatefulWidget {
  final Service service;

  const _RegistroServicioView({required this.service});

  @override
  _RegistroServicioViewState createState() => _RegistroServicioViewState();
}

class _RegistroServicioViewState extends State<_RegistroServicioView> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _diasAproximadosController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _priceController =
        TextEditingController(text: widget.service.price.toString());
    _diasAproximadosController =
        TextEditingController(text: widget.service.diasAproximados.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _diasAproximadosController.dispose();
    super.dispose();
  }

  bool _isValidPrice(String price) {
    // Validar que el precio sea un número positivo
    final priceDouble = double.tryParse(price);
    return priceDouble != null && priceDouble > 0;
  }

  bool _isValidDays(String days) {
    // Validar que los días aproximados sean un entero positivo
    final daysInt = int.tryParse(days);
    return daysInt != null && daysInt > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nombre del servicio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del servicio';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: 'Precio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el precio';
                  }
                  if (!_isValidPrice(value)) {
                    return 'Ingrese un precio válido (positivo)';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _diasAproximadosController,
                decoration: const InputDecoration(
                  hintText: 'Días aproximados',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese los días aproximados';
                  }
                  if (!_isValidDays(value)) {
                    return 'Ingrese un número válido de días (positivo)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String name = _nameController.text;
                    double price = double.parse(_priceController.text);
                    int diasAproximados =
                        int.parse(_diasAproximadosController.text);

                    // Actualizar el documento en Firestore
                    await _firestore
                        .collection('services')
                        .doc(widget.service.id)
                        .update({
                      'name': name,
                      'price': price,
                      'diasAproximados': diasAproximados,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Servicio editado correctamente.'),
                      ),
                    );

                    // Volver a la pantalla anterior
                    context.pop();
                    context.pop();
                  }
                },
                child: const Text('Editar servicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
