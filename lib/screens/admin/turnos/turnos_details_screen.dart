import 'package:aplicacion_taller/entities/turn.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TurnoDetailsScreen extends StatefulWidget {
  final Turn turn;
  const TurnoDetailsScreen({super.key, required this.turn});

  @override
  _TurnoDetailsScreenState createState() => _TurnoDetailsScreenState();
}

class _TurnoDetailsScreenState extends State<TurnoDetailsScreen> {
  late String _selectedState;
  final List<String> _states = ['Pendiente', 'Confirmado', 'En Progreso', 'Realizado', 'Cancelado'];
  String? _vehicleDetails;
  String? _userDetails;

  @override
  void initState() {
    super.initState();
    _selectedState = _states.contains(widget.turn.state) ? widget.turn.state : _states[0];
    _fetchVehicleDetails();
    _fetchUserDetails();
  }

  Future<void> _fetchVehicleDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('vehiculos')
          .doc(widget.turn.vehicleId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _vehicleDetails = '${snapshot['model']} - ${snapshot['brand']} - Patente: ${snapshot['licensePlate']}';
        });
      }
    } catch (e) {
      print('Error al obtener detalles del vehículo: $e');
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.turn.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _userDetails = snapshot['name'] ?? 'Nombre no disponible';
        });
      }
    } catch (e) {
      print('Error al obtener detalles del usuario: $e');
    }
  }

  void _updateTurnState() async {
    try {
      await FirebaseFirestore.instance
          .collection('turns')
          .doc(widget.turn.id)
          .update({'state': _selectedState});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado con éxito')),
      );
    } catch (e) {
      print('Error al actualizar el estado del turno: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles del Turno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Fecha de Ingreso',
                  DateFormat('dd/MM/yyyy').format(widget.turn.ingreso),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Detalles del Vehículo', _vehicleDetails),
                const SizedBox(height: 16),
                _buildDetailRow('Usuario', _userDetails),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Estado:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedState,
                        items: _states.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedState = newValue!;
                          });
                        },
               
                        icon: const Icon(Icons.arrow_drop_down), 
                      
                        iconSize: 26, 
                        dropdownColor: Colors.white,
                        iconEnabledColor: Colors.black,
                        underline: Container(), 
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateTurnState,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Actualizar Estado'),
                  ),
                ),
              ],
            ),
          ),
        
      ),
    );
  }

  Widget _buildDetailRow(String title, String? detail) {
    return detail == null
        ? const CircularProgressIndicator()
        : Row(
            children: [
              Text(
                '$title: ',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  detail,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
            ],
          );
  }
}
