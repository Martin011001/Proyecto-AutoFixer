import 'package:aplicacion_taller/entities/info_cliente_turn_progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aplicacion_taller/entities/turn.dart';

class ReparationHistoryScreen extends StatelessWidget {
  static const String name = 'reparation-history-screen';

  const ReparationHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Reparaciones'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!authSnapshot.hasData) {
            return const Center(child: Text('No has iniciado sesión'));
          }

          final String userId = authSnapshot.data!.uid;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('turns')
                .where('userId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar los turnos'));
              }

              final data = snapshot.requireData;
              List<Turn> turns =
                  data.docs.map((doc) => Turn.fromFirestore(doc)).toList();
                  print(data);

              if (turns.isEmpty) {
                return const Center(child: Text('No hay turnos disponibles'));
              }

              List<Turn> inProgressTurns = turns
                  .where((turn) =>
                      turn.state == 'pending' ||
                      turn.state == 'confirm' ||
                      turn.state == 'in progress')
                  .toList();

              List<Turn> doneTurns =
                  turns.where((turn) => turn.state == 'done').toList();

              return _ListTurnView(
                inProgressTurns: inProgressTurns,
                doneTurns: doneTurns,
              );
            },
          );
        },
      ),
    );
  }
}

class _ListTurnView extends StatelessWidget {
  final List<Turn> inProgressTurns;
  final List<Turn> doneTurns;

  const _ListTurnView({
    required this.inProgressTurns,
    required this.doneTurns,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (inProgressTurns.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Turnos en Progreso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...inProgressTurns.map((turn) => _TurnItem(turn: turn)).toList(),
          const Divider(),
        ],
        if (doneTurns.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Turnos Finalizados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...doneTurns.map((turn) => _TurnItem(turn: turn)).toList(),
          const Divider(),
        ],
      ],
    );
  }
}

class _TurnItem extends StatelessWidget {
  final Turn turn;

  const _TurnItem({required this.turn});

  @override
  Widget build(BuildContext context) {
    String formattedInDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(turn.ingreso);
    String formattedOutDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(turn.egreso);
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserDetails(turn.userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        if (userSnapshot.hasError) {
          return const Text('Error al cargar detalles del usuario');
        }
        if (!userSnapshot.hasData) {
          return const Text('Detalles del usuario no encontrados');
        }

        final userData = userSnapshot.data!;
        final String userName =
            userData['name'] ?? 'Desconocido'; // Nombre del usuario

        return FutureBuilder<Map<String, dynamic>>(
          future: _getVehicleDetails(turn.vehicleId),
          builder: (context, vehicleSnapshot) {
            if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            if (vehicleSnapshot.hasError) {
              return const Text('Error al cargar detalles del vehículo');
            }
            if (!vehicleSnapshot.hasData) {
              return const Text('Detalles del vehículo no encontrados');
            }

            final vehicleData = vehicleSnapshot.data!;
            final String vehicleBrand = vehicleData['brand'] ?? 'Desconocido';
            final String vehicleModel = vehicleData['model'] ?? 'Desconocido';

            return Card(
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vehículo: $vehicleBrand $vehicleModel'),
                    Text('Fecha de ingreso: $formattedInDate'),
                    Text('Estado del turno: ${turn.state}'),
                    Text('Fecha de retiro aproximada: $formattedOutDate'),
                  ],
                ),
                onTap: () {
                  context.push('/cliente/turn-progress',
                      extra: TurnDetails(
                        userName: userName,
                        vehicleBrand: vehicleBrand,
                        vehicleModel: vehicleModel,
                        ingreso: turn.ingreso,
                        turnState: turn.state,
                      ));
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> _getVehicleDetails(String vehicleId) async {
    final vehicleDoc = await FirebaseFirestore.instance
        .collection('vehiculos')
        .doc(vehicleId)
        .get();
    return vehicleDoc.data() as Map<String, dynamic>? ?? {};
  }
}
