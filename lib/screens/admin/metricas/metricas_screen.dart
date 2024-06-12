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

      // Mapear campos de turno
      List<Map<String, dynamic>> turnosMapeados = turnosSnapshot.docs.map((turnoDoc) {
        List<String> nombresServicios = [];
        for (var idServicio in (turnoDoc['services'] as List)) {
          if (idToName.containsKey(idServicio)) {
            nombresServicios.add(idToName[idServicio]!);
          }
        }

        return {
          'id': turnoDoc.id,
          'ingreso': (turnoDoc['ingreso'] as Timestamp).toDate(),
          'egreso': (turnoDoc['egreso'] as Timestamp).toDate(),
          'services': nombresServicios,
          'state': turnoDoc['state'] ?? '',
          'totalPrice': (turnoDoc['totalPrice'] ?? 0).toDouble(),
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: 'Turnos',
            metrics: [
              {'label': 'Total de Turnos', 'value': '50'},
              {'label': 'Turnos Confirmados', 'value': '30'},
              {'label': 'Turnos Realizados', 'value': '20'},
            ],
            customMetric: {
              'label': 'Turnos por fecha',
            },
            segundaMetrica: 'Turnos por estado',
            opcionesSegundaMetrica: ['Confirmado', 'En proceso', 'Finalizado'],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Servicios',
            metrics: [
              {'label': 'Tiempo Total de Servicio (horas)', 'value': '150'},
              {'label': 'Tiempo Promedio de Servicio (horas)', 'value': '5'},
              {'label': 'Total de Servicios', 'value': '30'},
            ],
            customMetric: {
              'label': 'Servicios por fecha'
            },
            segundaMetrica: 'Tipo de Servicio',
            opcionesSegundaMetrica: ['Pulido', 'Chapa', 'Tapizado'],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Ingresos',
            metrics: [
              {'label': 'Ingresos Totales', 'value': '\$1500'},
              {'label': 'Promedio de Ingresos por Turno', 'value': '\$30'},
              {'label': 'Total de Turnos', 'value': '50'},
            ],
            customMetric: {
              'label': 'Ingresos por fecha'
            },
            segundaMetrica: 'Servicio',
            opcionesSegundaMetrica: ['Pulido', 'Chapa', 'Tapizado'],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required List<Map<String, String>> metrics,
      required Map<String, String> customMetric,
      required String segundaMetrica,
      required List<String> opcionesSegundaMetrica}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (var metric in metrics)
          Card(
            child: ListTile(
              title: Text(metric['label']!),
              trailing: Text(metric['value']!),
            ),
          ),
        const SizedBox(height: 20),
        _buildCustomizableMetricCard(customMetric, segundaMetrica, opcionesSegundaMetrica),
      ],
    );
  }

  Widget _buildCustomizableMetricCard(Map<String, String> customMetric, String segundaMetrica, List<String> opcionesSegundaMetrica) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customMetric['label']!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fecha'),
                DropdownButton<String>(
                  items: const ['Día', 'Semana', 'Mes'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    // Actualizar métrica según selección
                  },
                  hint: const Text('Seleccionar'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(segundaMetrica),
                DropdownButton<String>(
                  items: opcionesSegundaMetrica.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    // Actualizar métrica según selección
                  },
                  hint: const Text('Seleccionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
