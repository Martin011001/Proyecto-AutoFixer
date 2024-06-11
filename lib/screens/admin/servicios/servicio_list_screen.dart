import 'package:aplicacion_taller/entities/service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:aplicacion_taller/screens/admin/servicios/servicio_details_screen.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        automaticallyImplyLeading: true, // Esto muestra la flecha de retroceso
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }

          final services = snapshot.data?.docs ?? [];

          if (services.isEmpty) {
            return const Center(child: Text('No hay servicios disponibles'));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final serviceDoc = services[index];
              final service = Service.fromFirestore(serviceDoc);

              return GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de detalles del servicio
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // podria agregarse en el router
                      builder: (context) =>
                          ServiceDetailScreen(serviceId: service.id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '\$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/administrador/add-service');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
