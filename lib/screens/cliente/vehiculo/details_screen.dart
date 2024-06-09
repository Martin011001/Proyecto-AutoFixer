import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Auto'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
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
                  Text.rich(
                    TextSpan(
                      children: [
                        const WidgetSpan(
                          child: Icon(
                            Icons.car_repair_rounded,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' ${vehiculo.brand} ${vehiculo.model}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                title: const Text('Confirmar Eliminación'),
                                content: const Text(
                                    '¿Estás seguro de que deseas eliminar este vehículo?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(false); // No elimina el vehículo
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
        ),
      ),
    );
  }
}
