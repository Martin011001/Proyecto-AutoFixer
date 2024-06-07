import 'package:aplicacion_taller/entities/service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  ServiceDetailScreen({required this.serviceId});

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
        title: const Text('Service Details'),
      ),
      body: FutureBuilder<Service>(
        future: _fetchService(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching service details'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Service not found'));
          }

          Service service = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Service Name: ${service.name}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: \$${service.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Acción para editar
                        },
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                          onPressed: () => eliminarServicio(context),
                        // ignore: sort_child_properties_last
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
