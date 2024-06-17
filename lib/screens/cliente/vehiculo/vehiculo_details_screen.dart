import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:aplicacion_taller/entities/vehicle.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehiculo;

  const VehicleDetailsScreen({super.key, required this.vehiculo});

  Future<void> eliminarVehiculo(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Referencia al documento del vehículo
        DocumentReference vehicleRef =
            FirebaseFirestore.instance.collection('vehiculos').doc(vehiculo.id);

        // turnos asociados al vehicleId del vehículo
        QuerySnapshot turnosSnapshot = await FirebaseFirestore.instance
            .collection('turns')
            .where('vehicleId', isEqualTo: vehiculo.id)
            .get();
        for (DocumentSnapshot turnoDoc in turnosSnapshot.docs) {
          transaction.delete(turnoDoc.reference);
        }
        // Elimina el vehículo
        transaction.delete(vehicleRef);
      });

      // Redirige a la página principal después de eliminar
      // ignore: use_build_context_synchronously
      context.pop(); // Ajusta la ruta según tu configuración

      // Mostrar mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo eliminado exitosamente')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el vehículo: $e')),
      );
    }
  }

  Future<List<QueryDocumentSnapshot>> obtenerTurnos() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('turns')
        .where('vehicleId', isEqualTo: vehiculo.id)
        .where('state', whereIn: ['Realizado']).get();
    return querySnapshot.docs;
  }

  Future<String> _getUserDetails(String userId) async {
    try {
      // Realiza la consulta para obtener el DocumentSnapshot
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Verifica si el documento existe
      if (userDoc.exists) {
        // Accede al nombre de usuario y devuelve su valor
        return userDoc.data()?['userName'] ?? 'Usuario sin nombre';
      } else {
        return 'Usuario no encontrado';
      }
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir durante la consulta
      print('Error al obtener detalles del usuario: $e');
      return 'Error al obtener detalles del usuario';
    }
  }

  Icon _getStateIcon(String state) {
    switch (state) {
      case 'Pendiente':
        return const Icon(Icons.pending, color: Colors.orange, size: 48);
      case 'Confirmado':
        return const Icon(Icons.check_circle, color: Colors.green, size: 48);
      case 'En Progreso':
        return const Icon(Icons.autorenew, color: Colors.blue, size: 48);
      case 'Realizado':
        return const Icon(Icons.done, color: Colors.purple, size: 48);
      case 'Cancelado':
        return const Icon(Icons.cancel, color: Colors.red, size: 48);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 48);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del vehículo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '🚗 Vehículo: ${vehiculo.brand} ${vehiculo.model}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Text(
                        'Modelo: ${vehiculo.model}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        'Marca: ${vehiculo.brand}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Patente: ${vehiculo.licensePlate}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Año: ${vehiculo.year ?? 'Desconocido'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.push('/cliente/vehiculo/edit',
                                  extra: vehiculo);
                            },
                            child: const Text('Editar'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              // Mostrar diálogo de confirmación
                              bool confirmacion = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: const Text(
                                        '¿Estás seguro que deseas eliminar este vehículo?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              false); // No elimina el vehículo
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(
                                              true); // Confirma la eliminación del vehículo
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Si la confirmación es true, elimina el vehículo
                              if (confirmacion == true) {
                                // ignore: use_build_context_synchronously
                                await eliminarVehiculo(context);
                              }
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<QueryDocumentSnapshot>>(
                future: obtenerTurnos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay turnos realizados o cancelados.');
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Turnos Realizados:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var turno = snapshot.data![index];
                            return Card(
                              child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('🚗'),
                                          const SizedBox(
                                              width:
                                                  8), // Espacio entre el emoji y el texto
                                          Text(
                                              '${vehiculo.brand} ${vehiculo.model}'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ingreso: ${DateFormat('yyyy-MM-dd').format(turno['ingreso'].toDate())}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        'Egreso: ${turno.data() != null && (turno.data() as Map<String, dynamic>).containsKey('egreso') ? DateFormat('yyyy-MM-dd').format((turno.data() as Map<String, dynamic>)['egreso'].toDate()) : 'No disponible'}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    ],
                                  ),
                                  trailing: _getStateIcon(turno['state']),
                                  onTap: () {}),
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
