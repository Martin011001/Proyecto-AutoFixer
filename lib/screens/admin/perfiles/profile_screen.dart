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

  String? _nameError;
  String? _phoneError;
  String? _modelError;
  String? _brandError;
  String? _licensePlateError;
  String? _yearError;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _vehiclesFuture = _fetchUserVehicles();
  }

  Future<void> _deleteVehicle(BuildContext context, String vehicleId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference vehicleRef =
            FirebaseFirestore.instance.collection('vehiculos').doc(vehicleId);
        transaction.delete(vehicleRef);

        QuerySnapshot turnosSnapshot = await FirebaseFirestore.instance
            .collection('turns')
            .where('vehicleId', isEqualTo: vehicleId)
            .get();
        for (DocumentSnapshot turnoDoc in turnosSnapshot.docs) {
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar información de usuario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      errorText: _nameError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      errorText: _phoneError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _nameError = nameController.text.isEmpty
                          ? 'El nombre no puede estar vacío'
                          : null;
                      _phoneError = phoneController.text.isEmpty ||
                              !RegExp(r'^\d+$')
                                  .hasMatch(phoneController.text) ||
                              phoneController.text.length < 8
                          ? 'El teléfono debe ser numerico y de aunque sea 8 digitos'
                          : null;
                    });

                    if (_nameError != null || _phoneError != null) {
                      return;
                    }

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
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar vehículo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: modelController,
                    decoration: InputDecoration(
                      labelText: 'Modelo',
                      errorText: _modelError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: brandController,
                    decoration: InputDecoration(
                      labelText: 'Marca',
                      errorText: _brandError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: licensePlateController,
                    decoration: InputDecoration(
                      labelText: 'Matrícula',
                      errorText: _licensePlateError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: yearController,
                    decoration: InputDecoration(
                      labelText: 'Año',
                      errorText: _yearError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _modelError = modelController.text.isEmpty ||
                              modelController.text.length < 3
                          ? 'El modelo debe tener aunque 3 caracteres'
                          : null;
                      _brandError = brandController.text.isEmpty ||
                              brandController.text.length < 3
                          ? 'La marca debe tener aunque 3 caracteres'
                          : null;
                      _licensePlateError = licensePlateController
                                  .text.isEmpty ||
                              !RegExp(r'^([A-Z]{2}\d{3}[A-Z]{2}|[A-Z]{3}\d{3})$')
                                  .hasMatch(licensePlateController.text)
                          ? 'Ingrese una patente válida (Ejemplo: AA123BB o ACB123)'
                          : null;
                      _yearError = yearController.text.isNotEmpty &&
                              !RegExp(r'^\d{4}$').hasMatch(yearController.text)
                          ? 'Ingrese un año válido (entre 1900 y el año actual)'
                          : null;
                    });

                    if (_modelError != null ||
                        _brandError != null ||
                        _licensePlateError != null ||
                        _yearError != null) {
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('vehiculos')
                          .doc(vehicle.id)
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
                      print('Error actualizando vehiculo: $e');
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar nuevo vehículo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: modelController,
                    decoration: InputDecoration(
                      labelText: 'Modelo',
                      errorText: _modelError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: brandController,
                    decoration: InputDecoration(
                      labelText: 'Marca',
                      errorText: _brandError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: licensePlateController,
                    decoration: InputDecoration(
                      labelText: 'Matrícula',
                      errorText: _licensePlateError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: yearController,
                    decoration: InputDecoration(
                      labelText: 'Año',
                      errorText: _yearError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _modelError = modelController.text.isEmpty ||
                              modelController.text.length < 3
                          ? 'El modelo debe tener 3 caracteres'
                          : null;
                      _brandError = brandController.text.isEmpty ||
                              brandController.text.length < 3
                          ? 'La marca debe tener 3 caracteres'
                          : null;
                      _licensePlateError = licensePlateController
                                  .text.isEmpty ||
                              !RegExp(r'^([A-Z]{2}\d{3}[A-Z]{2}|[A-Z]{3}\d{3})$')
                                  .hasMatch(licensePlateController.text)
                          ? 'Ingrese un año válido (entre 1900 y el año actual)'
                          : null;
                      _yearError = yearController.text.isNotEmpty &&
                              !RegExp(r'^\d{4}$').hasMatch(yearController.text)
                          ? 'Ingrese un año válido (entre 1900 y el año actual)'
                          : null;
                    });

                    if (_modelError != null ||
                        _brandError != null ||
                        _licensePlateError != null ||
                        _yearError != null) {
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('vehiculos')
                          .add({
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
                      print('Error agregando vehiculo: $e');
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil: ${user.name}'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Perfil:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Nombre: ${user.name}'),
                subtitle: Text('Teléfono: ${user.phone}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editUserInfo(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Vehículos:',
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
                      return const Center(
                          heightFactor: 2, child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                          heightFactor: 2,
                          child: Text('Error al obtener los vehículos'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          heightFactor: 2,
                          child: Text('No se encontraron vehículos'));
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
                              subtitle:
                                  Text('Matrícula: ${vehicle.licensePlate}'),
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
                                          title:
                                              const Text('Eliminar vehículo'),
                                          content: const Text(
                                              '¿Estás seguro que deseas eliminar este vehículo?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmDelete == true) {
                                        await _deleteVehicle(
                                            context, vehicle.id);
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
                child: const Text('Agregar nuevo vehículo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
