import 'package:aplicacion_taller/entities/service.dart';
import 'package:aplicacion_taller/screens/admin/servicios/editar_servicios_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({required this.serviceId});

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Future<Service> _fetchService() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('services')
        .doc(widget.serviceId)
        .get();
    return Service.fromFirestore(doc);
  }

  Future<void> eliminarServicio(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.serviceId)
          .delete();
      // Redirige a la página principal después de eliminar
      context.pop(); // Ajusta la ruta según tu configuración
    } catch (e) {
      // Maneja el error si ocurre
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el servicio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de servicio'),
      ),
      body: FutureBuilder<Service>(
        future: _fetchService(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error al traer los detalles del servicio'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Servicio no encontrado'));
          }

          Service service = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Servicio',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          )),
                      Text(
                        'Nombre servicio: ${service.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Precio: \$${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dias aproximados: ${service.diasAproximados}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // podria agregarse en el router
                                  builder: (context) =>
                                      ServiceEditScreen(service: service),
                                ),
                              );
                            },
                            child: const Text('Editar'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              // Mostrar diálogo de confirmación
                              bool confirmacion = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: const Text(
                                        '¿Estás seguro que deseas eliminar este servicio?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmacion) {
                                // ignore: use_build_context_synchronously
                                await eliminarServicio(context);
                              }
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
