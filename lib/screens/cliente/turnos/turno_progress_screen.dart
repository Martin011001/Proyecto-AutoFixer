import 'package:aplicacion_taller/entities/info_cliente_turn_progress.dart';
import 'package:flutter/material.dart';

class VerProgresoReparaciones extends StatelessWidget {
  final TurnDetails turnDetails;

  const VerProgresoReparaciones({super.key, required this.turnDetails});
  Icon _getStateIcon(String state) {
    switch (state) {
      case 'Pendiente':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'Confirmado':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'En Progreso':
        return const Icon(Icons.autorenew, color: Colors.blue);
      case 'Realizado':
        return const Icon(Icons.done, color: Colors.purple);
      case 'Cancelado':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso del Turno'),
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
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🚗 Vehículo: ${turnDetails.vehicleBrand} ${turnDetails.vehicleModel}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ingreso: ${turnDetails.ingresoDate}',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromARGB(172, 0, 0, 0)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _getStateIcon(turnDetails.turnState),
                      const SizedBox(width: 8),
                      Text(
                        '${turnDetails.turnState}',
                        style: const TextStyle(
                            fontSize: 18, color: Color.fromARGB(172, 0, 0, 0)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Retirar: ${turnDetails.egresoDate}',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromARGB(172, 0, 0, 0)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildProgressIndicator(turnDetails.turnState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String state) {
    double progress = 0.0;
    // ['Pendiente', 'Confirmado', 'En Progreso', 'Realizado', 'Cancelado']

    switch (state) {
      case 'Pendiente':
        progress = 0.25;
        break;
      case 'Confirmado':
        progress = 0.50;
        break;
      case 'En Progreso':
        progress = 0.75;
        break;
      case 'Realizado':
        progress = 1.0;
        break;
      case 'Cancelado':
        progress = 1.0;
        break;
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 20, // Altura personalizada del LinearProgressIndicator
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
