import 'package:aplicacion_taller/screens/cliente/thank_you_screen.dart';
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
          var reservationId = data['reservationId'];
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

              return FutureBuilder<DocumentSnapshot>(
                future: _fetchReservationDate(reservationId),
                builder: (context, reservationSnapshot) {
                  if (reservationSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (reservationSnapshot.hasError) {
                    print('Error al cargar los datos de la reserva: ${reservationSnapshot.error}');
                    return const Center(child: Text('Error al cargar los datos de la reserva.'));
                  }

                  if (!reservationSnapshot.hasData || !reservationSnapshot.data!.exists) {
                    print('Reserva no encontrada para reservationId: $reservationId');
                    return const Center(child: Text('Reserva no encontrada.'));
                  }

                  var reservationData = reservationSnapshot.data!.data() as Map<String, dynamic>;
                  var reservationDateTime = (reservationData['date'] as Timestamp).toDate();
                  var formattedDate = DateFormat('dd-MM-yyyy HH:mm').format(reservationDateTime);

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

                            // Actualiza la reserva para marcarla como reservada
                            await FirebaseFirestore.instance.collection('reservations').doc(reservationId).update({
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
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _fetchReservationDate(String reservationId) async {
    // Acceder al documento en Firestore usando el reservationId directamente
    var docRef = FirebaseFirestore.instance.collection('reservations').doc(reservationId);
    return docRef.get();
  }
}
