import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:aplicacion_taller/entities/user.dart';
import 'package:aplicacion_taller/entities/vehicle.dart';

class PerfilesScreen extends StatefulWidget {
  const PerfilesScreen({super.key});

  @override
  _PerfilesScreenState createState() => _PerfilesScreenState();
}

class _PerfilesScreenState extends State<PerfilesScreen> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference vehiclesRef =
      FirebaseFirestore.instance.collection('vehiculos');
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfiles'),
        automaticallyImplyLeading: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, marca o modelo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: usersRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
          if (userSnapshot.hasError) {
            print("Error: ${userSnapshot.error}");
            return Center(
                child: Text('Algo ha salido mal: ${userSnapshot.error}'));
          }

          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = userSnapshot.data!.docs
              .map((doc) => User.fromFirestore(doc))
              .toList();

          return StreamBuilder(
            stream: vehiclesRef.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> vehicleSnapshot) {
              if (vehicleSnapshot.hasError) {
                print("Error: ${vehicleSnapshot.error}");
                return Center(
                    child:
                        Text('Algo ha salido mal: ${vehicleSnapshot.error}'));
              }

              if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final vehicles = vehicleSnapshot.data!.docs
                  .map((doc) => Vehicle.fromFirestore(doc))
                  .toList();

              final filteredUsers = users.where((user) {
                final userName = user.name.toLowerCase();
                final userVehicles =
                    vehicles.where((vehicle) => vehicle.userID == user.id);
                final vehicleMatch = userVehicles.any((vehicle) {
                  final brand = vehicle.brand.toLowerCase();
                  final model = vehicle.model.toLowerCase();
                  return brand.contains(searchText) ||
                      model.contains(searchText);
                });
                return userName.contains(searchText) || vehicleMatch;
              }).toList();

              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text(user.phone),
                      trailing:
                          const Icon(Icons.person), // Icono de usuario a la derecha
                      onTap: () {
                        // Navigate to profile page using go_router
                        context.push('/administrador/perfiles/profile',
                            extra: user);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
