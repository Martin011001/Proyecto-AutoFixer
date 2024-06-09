import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:aplicacion_taller/entities/vehicle.dart';

class VehicleListScreen extends StatefulWidget {
  static const String name = 'home-screen';

  const VehicleListScreen({Key? key}) : super(key: key);

  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late final String userId; // Variable para almacenar el ID del usuario

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehiculos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehiculos')
            .where('userID', isEqualTo: userId) // Filtrar por ID de usuario
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los vehículos'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay vehículos disponibles'));
          }

          final List<Vehicle> vehicles = snapshot.data!.docs.map((doc) {
            return Vehicle.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final autoAux = vehicles[index];
              return _buildAutoCard(context, autoAux);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/cliente/vehiculo/register');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAutoCard(BuildContext context, Vehicle vehiculo) {
    return Card(
      child: ListTile(
       title: Text('🚗 ${vehiculo.brand} ${vehiculo.model}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.push('/cliente/vehiculo/details', extra: vehiculo);
        },
      ),
    );
  }
}
