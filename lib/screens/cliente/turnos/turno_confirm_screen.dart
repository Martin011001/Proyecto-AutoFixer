import 'package:aplicacion_taller/screens/cliente/turnos/turno_thankyou_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Importa la biblioteca intl para formatear fechas
import 'package:aplicacion_taller/entities/_repair_service.dart';

class ConfirmTurnScreen extends StatelessWidget {
  final String turnId;

  ConfirmTurnScreen({required this.turnId});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Turno')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('turns').doc(turnId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos del turno.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Turno no encontrado.'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var vehicleId = data['vehicleId'];
          var ingreso = (data['ingreso'] as Timestamp).toDate();
          var formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(ingreso);
          var serviceIds = data['services'] as List<dynamic>;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('vehiculos').doc(vehicleId).get(),
            builder: (context, vehicleSnapshot) {
              if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vehicleSnapshot.hasError) {
                return const Center(child: Text('Error al cargar los datos del vehículo.'));
              }

              if (!vehicleSnapshot.hasData || !vehicleSnapshot.data!.exists) {
                return const Center(child: Text('Vehículo no encontrado.'));
              }

              var vehicleData = vehicleSnapshot.data!.data() as Map<String, dynamic>;

    return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Vehículo: ${vehicleData['brand']} ${vehicleData['model']} (${vehicleData['year']})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estado: ${data['state']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fecha de ingreso: $formattedDate',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Precio total: ${data['totalPrice']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Servicios:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    ...serviceIds.map((serviceId) {
                      var service = services.firstWhere((s) => s.id == serviceId);
                      return Center(
                        child: Text('${service.nombre} - \$${service.precio}'),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('turns').doc(turnId).update({
                          'confirm': true,
                        });
                        String formattedDatefinal = "${ingreso.year}-${ingreso.month}-${ingreso.day}";
                        String formattedTime = "${ingreso.hour}:${ingreso.minute.toString().padLeft(2, '0')}";
                        DocumentReference docRef = FirebaseFirestore.instance
                            .collection('reservations')
                            .doc(formattedDatefinal)
                            .collection('times')
                            .doc(formattedTime);

                        await docRef.set({
                          'time': formattedTime,
                          'reserved': true,
                          'user_id': FirebaseAuth.instance.currentUser?.uid,
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ThankYouScreen()),
                        );
                      },
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


