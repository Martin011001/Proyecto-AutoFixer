import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicacion_taller/entities/user.dart';
import 'package:aplicacion_taller/entities/vehicle.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _vehiclesFuture = _fetchUserVehicles();
  }
   Future<void> _deleteVehicle(BuildContext context, String vehicleId) async {

    try {
      // Inicia una transacción para asegurar la consistencia de la eliminación
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Referencia al documento del vehículo
        DocumentReference vehicleRef = FirebaseFirestore.instance.collection('vehiculos').doc(vehicleId);

        // Elimina el vehículo
        transaction.delete(vehicleRef);
       

        // Obtén los turnos asociados al vehicleId del vehículo
        QuerySnapshot turnosSnapshot = await FirebaseFirestore.instance.collection('turns')
            .where('vehicleId', isEqualTo: vehicleId).get();
        for (DocumentSnapshot turnoDoc in turnosSnapshot.docs) {
          // Elimina cada turno
          transaction.delete(turnoDoc.reference);
        }
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehículo eliminado exitosamente')),
        );
          setState(() {
          _vehiclesFuture = _fetchUserVehicles();
        });

      });

      
    } catch (e) {
      // Maneja el error si ocurre
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el vehículo: $e')),
      );
    }
  }

  Future<List<Vehicle>> _fetchUserVehicles() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('vehiculos')
        .where('userID', isEqualTo: user.id)
        .get();

    return querySnapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
  }
  



  void _editUserInfo(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: user.name);
    final TextEditingController phoneController =
        TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .update({
                  'name': nameController.text,
                  'phone': phoneController.text,
                });

                setState(() {
                  user = User(
                    id: user.id,
                    name: nameController.text,
                    phone: phoneController.text,
                  );
                });

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editVehicle(BuildContext context, Vehicle vehicle) {
    final TextEditingController modelController =
        TextEditingController(text: vehicle.model);
    final TextEditingController brandController =
        TextEditingController(text: vehicle.brand);
    final TextEditingController licensePlateController =
        TextEditingController(text: vehicle.licensePlate);
    final TextEditingController yearController =
        TextEditingController(text: vehicle.year ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'License Plate'),
              ),
              TextField(
                controller: yearController,
                decoration:const InputDecoration(labelText: 'Year'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('vehiculos')
                      .doc(vehicle
                          .id) // Use vehicle.id instead of vehicle.licensePlate
                      .update({
                    'model': modelController.text,
                    'brand': brandController.text,
                    'licensePlate': licensePlateController.text,
                    'year': yearController.text.isEmpty
                        ? null
                        : yearController.text,
                  });

                   setState(() {
                    _vehiclesFuture = _fetchUserVehicles();
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error updating vehicle: $e');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addVehicle(BuildContext context) {
    final TextEditingController modelController = TextEditingController();
    final TextEditingController brandController = TextEditingController();
    final TextEditingController licensePlateController =
        TextEditingController();
    final TextEditingController yearController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'License Plate'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('vehiculos').add({
                    'model': modelController.text,
                    'brand': brandController.text,
                    'licensePlate': licensePlateController.text,
                    'userID': user.id,
                    'year': yearController.text.isEmpty
                        ? null
                        : yearController.text,
                  });

                   setState(() {
                    _vehiclesFuture = _fetchUserVehicles();
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error adding vehicle: $e');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile: ${user.name}'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Name: ${user.name}'),
                subtitle: Text('Phone: ${user.phone}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editUserInfo(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Vehicles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: FutureBuilder<List<Vehicle>>(
                  future: _vehiclesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(heightFactor: 2, child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(heightFactor: 2, child: Text('Error fetching vehicles'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(heightFactor: 2, child: Text('No vehicles found'));
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var vehicle = snapshot.data![index];
                          return Card(
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                  '${vehicle.brand} ${vehicle.model} (${vehicle.year ?? 'N/A'})'),
                              subtitle: Text(
                                  'License Plate: ${vehicle.licensePlate}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editVehicle(context, vehicle);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      bool? confirmDelete = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Vehicle'),
                                          content: const Text(
                                              'Are you sure you want to delete this vehicle?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmDelete == true) {
                                        await _deleteVehicle(context,vehicle.id);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () => _addVehicle(context),
                child: const Text('Add New Vehicle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
