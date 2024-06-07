import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:aplicacion_taller/entities/vehicle.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehiculo;

  const VehicleDetailsScreen({super.key, required this.vehiculo});

 Future<void> eliminarVehiculo(BuildContext context) async {
    try {
      // Inicia una transacción para asegurar la consistencia de la eliminación
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Referencia al documento del vehículo
        DocumentReference vehicleRef = FirebaseFirestore.instance.collection('vehiculos').doc(vehiculo.id);


        // Obtén los turnos asociados al vehicleId del vehículo
        QuerySnapshot turnosSnapshot = await FirebaseFirestore.instance.collection('turns')
            .where('vehicleId', isEqualTo: vehiculo.id).get();
        for (DocumentSnapshot turnoDoc in turnosSnapshot.docs) {
          // Elimina cada turno
          transaction.delete(turnoDoc.reference);
        }
         // Elimina el vehículo
        transaction.delete(vehicleRef);
      });

      // Redirige a la página principal después de eliminar
      context.go('/cliente/vehiculo/list'); // Ajusta la ruta según tu configuración
    } catch (e) {
      // Maneja el error si ocurre
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Modelo: ${vehiculo.model}'),
            Text('Marca: ${vehiculo.brand}'),
            Text('Patente: ${vehiculo.licensePlate}'),
            Text('Año: ${vehiculo.year ?? 'Desconocido'}'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.push('/cliente/vehiculo/edit', extra: vehiculo);
                  },
                  child: const Text('Editar'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(  
                  onPressed: () => eliminarVehiculo(context),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
