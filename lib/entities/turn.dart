import 'package:cloud_firestore/cloud_firestore.dart';

class Turn {
  final String? id;
  final String userId;
  final String vehicleId; // Agregado el campo vehicleId
  final List<String> services; // Agregado el campo services
  final DateTime ingreso; // Cambiado el nombre del campo date a ingreso
  final String state;
  final double totalPrice; // Agregado el campo totalPrice
  final DateTime egreso;

  Turn({
    this.id,
    required this.userId,
    required this.vehicleId,
    required this.services,
    required this.ingreso,
    required this.state,
    required this.totalPrice,
    required this.egreso
  });

  factory Turn.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Turn(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String? ?? '',
      services: List<String>.from(data['services'] ?? []),
      ingreso: (data['ingreso'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Manejar el caso nulo
      state: data['state'] ?? '',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      egreso: (data['egreso'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Manejar el caso nulo
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'vehicleId': vehicleId, // Agregado el campo vehicleId
      'services': services, // Agregado el campo services
      'ingreso': ingreso, // Cambiado el nombre del campo date a ingreso
      'state': state,
      'totalPrice': totalPrice,
      'egreso': egreso, // Agregado el campo totalPrice
    };
  }
}
