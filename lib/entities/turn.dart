import 'package:cloud_firestore/cloud_firestore.dart';

class Turn {
  final String? id;
  final String userId;
  final String vehicleId;
  final List<String> services;
  final DateTime ingreso;
  final String state;
  final double totalPrice;
  final String? reservationId; // Cambiado a String

  Turn({
    this.id,
    required this.userId,
    required this.vehicleId,
    required this.services,
    required this.ingreso,
    required this.state,
    required this.totalPrice,
    this.reservationId, // Asegurado que sea requerido
  });

  factory Turn.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Turn(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String? ?? '',
      services: List<String>.from(data['services'] ?? []),
      ingreso: (data['ingreso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      state: data['state'] ?? '',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      reservationId: data['reservationId'] as String? ?? '', // Cambiado a String
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'services': services,
      'ingreso': ingreso,
      'state': state,
      'totalPrice': totalPrice,
      'reservationId': reservationId, // Cambiado a String
    };
  }
}
