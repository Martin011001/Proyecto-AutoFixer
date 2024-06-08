import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:aplicacion_taller/entities/user.dart';

class PerfilesScreen extends StatelessWidget {
  const PerfilesScreen({super.key});

  Future<void> _deleteUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Referencia al documento del usuario
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        // Obtén los vehículos asociados al usuario
        QuerySnapshot vehiclesSnapshot = await FirebaseFirestore.instance
            .collection('vehiculos')
            .where('userID', isEqualTo: userId)
            .get();

        // Elimina los vehículos y sus turnos asociados
        for (DocumentSnapshot vehicleDoc in vehiclesSnapshot.docs) {
          // Referencia al documento del vehículo
          DocumentReference vehicleRef = vehicleDoc.reference;

          // Obtén los turnos asociados al vehículo
          QuerySnapshot turnosSnapshot = await FirebaseFirestore.instance
              .collection('turns')
              .where('vehicleId', isEqualTo: vehicleRef.id)
              .get();

          // Elimina cada turno asociado al vehículo
          for (DocumentSnapshot turnoDoc in turnosSnapshot.docs) {
            transaction.delete(turnoDoc.reference);
          }

          // Elimina el vehículo
          transaction.delete(vehicleRef);
        }

        // Elimina el usuario
        transaction.delete(userRef);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference usersRef =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfiles'),
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder(
        stream: usersRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .map((doc) => User.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.phone),
                  onTap: () {
                    // Navigate to profile page using go_router
                    context.push('/administrador/perfiles/profile',
                        extra: user);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete ${user.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Implement delete functionality
                                  await _deleteUser(context, user.id);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
