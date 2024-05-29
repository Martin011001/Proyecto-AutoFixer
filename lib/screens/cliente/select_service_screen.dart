import 'package:aplicacion_taller/screens/cliente/calander.dart';
import 'package:aplicacion_taller/screens/cliente/confirm_turn_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicacion_taller/entities/_repair_service.dart';
import 'package:aplicacion_taller/entities/vehicle.dart';

class SeleccionarServicio extends StatefulWidget {
  static const String name = 'seleccionar-servicio-screen';
  const SeleccionarServicio({super.key});

  @override
  State<SeleccionarServicio> createState() => _SeleccionarServicioState();
}

class _SeleccionarServicioState extends State<SeleccionarServicio> {
  late Future<List<Vehicle>> _vehiclesFuture;
  Vehicle? _vehiculoSeleccionado;
  final Set<Service> _selectedServices = {};
  double _precioTotal = 0.0;
  bool _vehiculosDisponibles = true;
  String? _reservationId; // Variable para almacenar el reservationId

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _fetchUserVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar servicio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Añado padding general a la vista
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVehicleSelector(),
            const SizedBox(height: 16),
            _buildServiceList(),
            const SizedBox(height: 16),
            _buildCalendarButton(), // Botón para abrir el calendario
            const SizedBox(height: 16),
            const Divider(),
            _buildTotalPrice(),
            const SizedBox(height: 30),
            _buildReserveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return FutureBuilder<List<Vehicle>>(
      future: _vehiclesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _vehiculosDisponibles = true;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: const Text('Seleccionar vehículo'),
                  subtitle: _vehiculoSeleccionado != null
                      ? Text(
                          'Vehículo seleccionado: ${_vehiculoSeleccionado!.brand}, ${_vehiculoSeleccionado!.model}')
                      : const Text('Seleccione un vehículo'),
                  children: snapshot.data!.map((vehicle) {
                    return RadioListTile<Vehicle>(
                      value: vehicle,
                      groupValue: _vehiculoSeleccionado,
                      onChanged: (value) {
                        setState(() {
                          _vehiculoSeleccionado = value;
                        });
                      },
                      title: Text('${vehicle.brand} ${vehicle.model}'),
                    );
                  }).toList(),
                ),
              ),
            );
          } else {
            _vehiculosDisponibles = false;
            return const Text('No hay vehículos disponibles');
          }
        } else {
          return const Center(
              child:
                  LinearProgressIndicator()); // Muestra un indicador de carga
        }
      },
    );
  }

  Widget _buildServiceList() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          const ListTile(
            title: Text('Seleccionar servicios'),
          ),
          ...services.map((service) {
            return CheckboxListTile(
              title: Text(service.nombre),
              value: _selectedServices.contains(service),
              onChanged: _vehiculosDisponibles && _vehiculoSeleccionado != null
                  ? (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedServices.add(service);
                          _precioTotal += service.precio;
                        } else {
                          _selectedServices.remove(service);
                          _precioTotal -= service.precio;
                        }
                      });
                    }
                  : null,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCalendarButton() {
    return Container(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () async {
          final reservationId = await Navigator.push<String?>(
            context,
            MaterialPageRoute(
                builder: (context) => RepairRequestCalendar(
                      onReservationIdSelected: handleReservationIdSelected,
                    )),
          );

          if (reservationId != null) {
            setState(() {
              _reservationId = reservationId;
            });
          }
        },
        child: const Text('Seleccionar fecha'),
      ),
    );
  }

  void handleReservationIdSelected(String reservationId) {
    setState(() {
      _reservationId = reservationId;
    });
  }

  Widget _buildTotalPrice() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        'Precio Total: $_precioTotal',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReserveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_vehiculoSeleccionado != null &&
              _reservationId != null &&
              _selectedServices.isNotEmpty) {
            _createTurn(); // Llamar a la función para crear el turno
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Por favor seleccione un vehículo, una fecha y al menos un servicio.'),
              ),
            );
          }
        },
        child: const Text('Reservar turno'),
      ),
    );
  }

  Future<List<Vehicle>> _fetchUserVehicles() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('vehiculos')
        .where('userID', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
  }

  Future<void> _createTurn() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String vehicleId = _vehiculoSeleccionado?.id ?? '';
    
    List<String> serviceIds = _selectedServices.map((s) => s.id).toList();

    if (userId.isEmpty || vehicleId.isEmpty || serviceIds.isEmpty || _reservationId == null) {
      return;
    }

    DocumentReference turnRef = await FirebaseFirestore.instance.collection('turns').add({
      'userId': userId,
      'vehicleId': vehicleId,
      'services': serviceIds,
      'reservationId': _reservationId, // Utiliza el reservationId en lugar de la fecha
      'state': 'pendiente',
      'totalPrice': _precioTotal,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Turno reservado con éxito.'),
      ),
    );

    // Opcional: Regresar a la pantalla anterior o a otra pantalla
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmTurnScreen(turnId: turnRef.id),
      ),
    );
  }
}
