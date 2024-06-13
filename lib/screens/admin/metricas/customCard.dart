import 'package:aplicacion_taller/screens/admin/metricas/customcard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MetricasScreen extends StatelessWidget {
  const MetricasScreen({super.key});

  Future<List<Map<String, dynamic>>> obtenerTurnos() async {
    try {
      QuerySnapshot turnosSnapshot =
          await FirebaseFirestore.instance.collection('turns').get();

      // Mapear IDs de servicios a nombres
      Map<String, String> idToName = {};
      QuerySnapshot serviciosSnapshot =
          await FirebaseFirestore.instance.collection('services').get();
      for (var doc in serviciosSnapshot.docs) {
        idToName[doc.id] = doc['name'];
      }

      // Mapear campos de turno y filtrar por estados permitidos
      List<Map<String, dynamic>> turnosMapeados =
          turnosSnapshot.docs.where((turnoDoc) {
        final turnoData = turnoDoc.data() as Map<String, dynamic>;
        final estado = turnoData['state'];

        // Filtrar por los estados permitidos
        return estado == 'Confirmado' ||
            estado == 'En proceso' ||
            estado == 'Realizado';
      }).map((turnoDoc) {
        final turnoData = turnoDoc.data() as Map<String, dynamic>;

        List<String> nombresServicios = [];
        for (var idServicio in (turnoData['services'] as List)) {
          if (idToName.containsKey(idServicio)) {
            nombresServicios.add(idToName[idServicio]!);
          }
        }

        return {
          'id': turnoDoc.id,
          'ingreso': turnoData.containsKey('ingreso')
              ? (turnoData['ingreso'] as Timestamp).toDate()
              : null,
          'egreso': turnoData.containsKey('egreso')
              ? (turnoData['egreso'] as Timestamp).toDate()
              : null,
          'services': nombresServicios,
          'state': turnoData['state'] ?? '',
          'totalPrice': (turnoData['totalPrice'] ?? 0).toDouble(),
        };
      }).toList();

      return turnosMapeados;
    } catch (e) {
      // Manejo de errores
      print('Error al obtener los turnos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métricas'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerTurnos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          // Obtén las métricas calculadas
          final turnos = snapshot.data!;
          final totalTurnos = turnos.length;
          final turnosConfirmados =
              turnos.where((t) => t['state'] == 'Confirmado').length;
          final turnosRealizados =
              turnos.where((t) => t['state'] == 'Realizado').length;
          final totalServicios =
              turnos.expand((t) => t['services'] as List<String>).length;
          final totalIngresos =
              turnos.fold(0.0, (sum, turno) => sum + (turno['totalPrice'] as double));
          final promedioIngresosPorServicio =
              totalServicios > 0 ? totalIngresos / turnos.length : 0.0;

          // Calcular tiempo promedio por servicio (en días)
          double tiempoPromedioPorServicio = 0.0;
          int cantidadTurnosRealizados = 0;

          for (var turno in turnos) {
            if (turno['state'] == 'Realizado' &&
                turno['ingreso'] != null &&
                turno['egreso'] != null) {
              final DateTime ingreso = turno['ingreso'];
              final DateTime egreso = turno['egreso'];
              final int dias = egreso.difference(ingreso).inDays;
              tiempoPromedioPorServicio += dias;
              cantidadTurnosRealizados++;
            }
          }

          tiempoPromedioPorServicio =
              cantidadTurnosRealizados > 0 ? tiempoPromedioPorServicio / cantidadTurnosRealizados : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSection(
                icon: Icons.event,
                title: 'Turnos',
                metrics: [
                  {'label': 'Total de Turnos', 'value': totalTurnos.toString()},
                  {
                    'label': 'Turnos Confirmados',
                    'value': turnosConfirmados.toString()
                  },
                  {
                    'label': 'Turnos Realizados',
                    'value': turnosRealizados.toString()
                  },
                ],
                customMetric: {
                  'label': 'Turnos por fecha',
                },
                segundaMetrica: 'Turnos por estado',
                opcionesSegundaMetrica: [
                  'Confirmado',
                  'En proceso',
                  'Finalizado'
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _buildSection(
                icon: Icons.assignment,
                title: 'Servicios',
                metrics: [
                  {
                    'label': 'Tiempo Prom. Turnos (días)',
                    'value': tiempoPromedioPorServicio.toStringAsFixed(2)
                  },
                  {
                    'label': 'Total de Servicios Realiz.',
                    'value': totalServicios.toString()
                  },
                ],
                customMetric: {'label': 'Servicios por fecha'},
                segundaMetrica: 'Tipo de Servicio',
                opcionesSegundaMetrica: ['Pulido', 'Chapa', 'Tapizado'],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              const CustomizableMetricCard(
                customMetricLabel: 'Ingresos por fecha',
                segundaMetrica: 'Servicio',
                opcionesSegundaMetrica: ['Pulido', 'Chapa', 'Tapizado'],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Map<String, String>> metrics,
    required Map<String, String> customMetric,
    required String segundaMetrica,
    required List<String> opcionesSegundaMetrica,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: metrics
              .map((metric) => Card(
                    child: ListTile(
                      title: Text(metric['label']!),
                      trailing: Text(
                        metric['value']!,
                        style: const TextStyle(
                          fontSize: 15, // Tamaño de fuente más grande
                          fontWeight: FontWeight.bold, // Texto en negrita
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        // Aquí solía estar la sección de ingresos, ahora usamos CustomizableMetricCard
        CustomizableMetricCard(
          customMetricLabel: customMetric['label']!,
          segundaMetrica: segundaMetrica,
          opcionesSegundaMetrica: opcionesSegundaMetrica,
        ),
      ],
    );
  }
}
