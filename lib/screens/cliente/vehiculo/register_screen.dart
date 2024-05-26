import 'package:aplicacion_taller/entities/vehicle.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _marcaController,
              decoration: const InputDecoration(
                hintText: 'Marca',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _modeloController,
              decoration: const InputDecoration(
                hintText: 'Modelo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _patenteController,
              decoration: const InputDecoration(
                hintText: 'Patente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _yearController,
              decoration: const InputDecoration(
                hintText: 'Año',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                String modelo = _modeloController.text;
                String marca = _marcaController.text;
                String patente = _patenteController.text;
                String year = _yearController.text;

                // Validar campos (puedes agregar más validaciones según tus necesidades)
                if (modelo.isEmpty ||
                    marca.isEmpty ||
                    patente.isEmpty ||
                    year.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, complete todos los campos.'),
                    ),
                  );
                } else if (userSesionID.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Usuario no registrado'),
                  ));
                } else {
                  try {
                    // Crear el documento en Firestore y obtener el ID generado
                    DocumentReference docRef =
                        await _firestore.collection('vehiculos').add({
                      'model': modelo,
                      'brand': marca,
                      'licensePlate': patente,
                      'userID': userSesionID,
                      'year': year,
                    });

                    // Crear el nuevo vehículo
                    final newVehicle = Vehicle(
                      id: docRef.id, // Asignar el ID generado por Firestore
                      model: modelo,
                      brand: marca,
                      licensePlate: patente,
                      userID: userSesionID,
                      year: year,
                    );

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
              },
              child: const Text('Agregar auto'),
            ),
          ),
        ],
      ),
    );
  }
}
