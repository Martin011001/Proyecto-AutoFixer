import 'package:aplicacion_taller/entities/info_cliente_turn_progress.dart';
import 'package:flutter/material.dart';

class VerProgresoReparaciones extends StatelessWidget {
  final TurnDetails turnDetails;

  const VerProgresoReparaciones({Key? key, required this.turnDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso del Turno'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Vehículo: ${turnDetails.vehicleBrand} ${turnDetails.vehicleModel}',
                  style: const TextStyle(fontSize: 18)),
              Text('Fecha de ingreso: ${turnDetails.formattedDate}',
                  style: const TextStyle(fontSize: 18)),
              Text('Estado del turno: ${turnDetails.turnState}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              _buildProgressIndicator(turnDetails.turnState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String state) {
    double progress = 0.0;

    switch (state) {
      case 'pending':
        progress = 0.25;
        break;
      case 'confirm':
        progress = 0.50;
        break;
      case 'in progress':
        progress = 0.75;
        break;
      case 'done':
        progress = 1.0;
        break;
    }

    return SizedBox(
      height: 20, // Altura personalizada del LinearProgressIndicator
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }
}
