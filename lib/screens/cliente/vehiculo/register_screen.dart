import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VehicleRegisterScreen extends StatelessWidget {
  static const String name = 'registro-vehiculo-screen';
  const VehicleRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro auto'),
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: _RegistroAutoView(),
        ),
      ),
    );
  }
}

class _RegistroAutoView extends StatefulWidget {
  const _RegistroAutoView();

  @override
  _RegistroAutoViewState createState() => _RegistroAutoViewState();
}

class _RegistroAutoViewState extends State<_RegistroAutoView> {
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _patenteController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userSesionID = FirebaseAuth.instance.currentUser?.uid ?? '';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bool _isValidYear(String year) {
      // Validar que sea un año válido (entre 1900 y el año actual)
      final currentYear = DateTime.now().year;
      final yearInt = int.tryParse(year);
      return yearInt != null && yearInt >= 1900 && yearInt <= currentYear;
    }

    bool _isValidPatent(String patent) {
      // Validar que sea una patente válida
      final regex = RegExp(r'^([A-Z]{2}\d{3}[A-Z]{2}|[A-Z]{3}\d{3})$');
      return regex.hasMatch(patent);
    }

    bool _isValidModelAndBrand(String value) {
      // Validar que la marca y el modelo tengan al menos 3 caracteres
      return value.length >= 3;
    }

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
                controller: _marcaController,
                decoration: const InputDecoration(
                  hintText: 'Marca',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la marca';
                  }
                  if (!_isValidModelAndBrand(value)) {
                    return 'La marca debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(
                  hintText: 'Modelo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el modelo';
                  }
                  if (!_isValidModelAndBrand(value)) {
                    return 'El modelo debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _patenteController,
                decoration: const InputDecoration(
                  hintText: 'Patente',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la patente';
                  }
                  if (!_isValidPatent(value)) {
                    return 'Ingrese una patente válida (Ejemplo: AA123BB o ACB123)';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  hintText: 'Año',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el año';
                  }
                  if (!_isValidYear(value)) {
                    return 'Ingrese un año válido (entre 1900 y el año actual)';
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
                    String modelo = _modeloController.text;
                    String marca = _marcaController.text;
                    String patente = _patenteController.text;
                    String year = _yearController.text;

                    if (userSesionID.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario no registrado')),
                      );
                    } else {
                      try {
                        // Continuar con el registro del vehículo
                        await _firestore.collection('vehiculos').add({
                          'model': modelo,
                          'brand': marca,
                          'licensePlate': patente,
                          'userID': userSesionID,
                          'year': year,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Auto registrado correctamente.'),
                          ),
                        );

                        setState(() {});

                        // Volver a la pantalla anterior
                        context.pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al registrar el vehículo: $e'),
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Agregar auto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
