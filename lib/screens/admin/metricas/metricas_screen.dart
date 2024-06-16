import 'package:aplicacion_taller/screens/admin/metricas/customCard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
          final totalIngresos = turnos.fold(
              0.0, (sum, turno) => sum + (turno['totalPrice'] as double));
          final promedioIngresosPorServicio =
              totalServicios > 0 ? totalIngresos / turnos.length : 0.0;

          print('ingresos: ${totalIngresos}');

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

          tiempoPromedioPorServicio = cantidadTurnosRealizados > 0
              ? tiempoPromedioPorServicio / cantidadTurnosRealizados
              : 0.0;

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
                segundaMetrica: 'Estado de Turnos',
                opcionesSegundaMetrica: [
                  'Confirmado',
                  'En progreso',
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
              _buildSection(
                icon: Icons.attach_money,
                title: 'Ingresos',
                metrics: [
                  {
                    'label': 'Ingresos Totales',
                    'value': '\$${totalIngresos.toStringAsFixed(2)}'
                  },
                  {
                    'label': 'Prom. Ingresos por servicio',
                    'value':
                        '\$${promedioIngresosPorServicio.toStringAsFixed(2)}'
                  },
                ],
                customMetric: {'label': 'Ingresos por fecha'},
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
        // Aquí usamos CustomizableMetricCard para métricas personalizables
        CustomizableMetricCard(
          customMetricLabel: customMetric['label']!,
          segundaMetrica: segundaMetrica,
          opcionesSegundaMetrica: opcionesSegundaMetrica,
        ),
      ],
    );
  }
}


class CustomizableMetricCard extends StatefulWidget {
  const CustomizableMetricCard({
    super.key,
    required this.customMetricLabel,
    required this.segundaMetrica,
    required this.opcionesSegundaMetrica,
  });

  final String customMetricLabel;
  final String segundaMetrica;
  final List<String> opcionesSegundaMetrica;

  @override
  _CustomizableMetricCardState createState() => _CustomizableMetricCardState();
}

class _CustomizableMetricCardState extends State<CustomizableMetricCard> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _selectedTipoServicio;
  List<Map<String, dynamic>> turnos = [];
  bool _isExpanded = false;
  int _calculatedCount = 0;

  @override
  void initState() {
    super.initState();
    _obtenerTurnos();
        print('Fecha de Ingreso: $turnos');

  }

  Future<void> _obtenerTurnos() async {
    try {
      QuerySnapshot turnosSnapshot =
          await FirebaseFirestore.instance.collection('turns').get();

      Map<String, String> idToName = {};
      QuerySnapshot serviciosSnapshot =
          await FirebaseFirestore.instance.collection('services').get();
      for (var doc in serviciosSnapshot.docs) {
        idToName[doc.id] = doc['name'];
      }

      List<Map<String, dynamic>> turnosMapeados =
          turnosSnapshot.docs.where((turnoDoc) {
        final turnoData = turnoDoc.data() as Map<String, dynamic>;
        final estado = turnoData['state'];
        return estado == 'Confirmado' ||
            estado == 'En Progreso' ||
            estado == 'Finalizado';
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

      setState(() {
        turnos = turnosMapeados;
        
      });
    } catch (e) {
      print('Error al obtener los turnos: $e');
    }
  }

  void _actualizarMetricas() {
    if (_fechaInicio != null &&
        _fechaFin != null &&
        _selectedTipoServicio != null) {
      setState(() {
        _isExpanded = true;
        _calculatedCount = _contarTurnos();
      });
    } else {
      setState(() {
        _isExpanded = false;
      });
    }
  }

  int _contarTurnos() {
  List<Map<String, dynamic>> turnosFiltrados = turnos.where((turno) {
    DateTime? ingreso = turno['ingreso'];
    bool dentroDelRango = false;

    if (ingreso != null && _fechaInicio != null && _fechaFin != null) {
      // Formatear las fechas para comparar solo la parte de fecha (sin la hora)
      DateTime fechaInicioFiltrada = DateTime(_fechaInicio!.year, _fechaInicio!.month, _fechaInicio!.day);
      DateTime fechaFinFiltrada = DateTime(_fechaFin!.year, _fechaFin!.month, _fechaFin!.day);
      DateTime fechaIngresoFiltrada = DateTime(ingreso.year, ingreso.month, ingreso.day);

      // Verificar si la fecha de ingreso está dentro del rango seleccionado
      dentroDelRango = fechaIngresoFiltrada.isAfter(fechaInicioFiltrada.subtract(const Duration(days: 1))) &&
          fechaIngresoFiltrada.isBefore(fechaFinFiltrada.add(const Duration(days: 1)));
    }

    bool tieneEstadoCorrecto = turno['state'] == _selectedTipoServicio;

    // Imprimir logs para depuración
    print('Turno: ${turno['id']}');

    return dentroDelRango && tieneEstadoCorrecto;
  }).toList();

  // Log de los turnos filtrados
  print('Turnos Filtrados: $turnosFiltrados');

  return turnosFiltrados.length;
}

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.customMetricLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFechaSelector(
                  label: 'Inicio:',
                  selectedDate: _fechaInicio,
                  onPressed: () => _selectDate(context, true),
                ),
                const SizedBox(height: 10),
                _buildFechaSelector(
                  label: 'Fin:',
                  selectedDate: _fechaFin,
                  onPressed: () => _selectDate(context, false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.segundaMetrica),
                DropdownButton<String>(
                  value: _selectedTipoServicio,
                  items: widget.opcionesSegundaMetrica.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTipoServicio = value;
                      _actualizarMetricas();
                    });
                  },
                  hint: const Text('Seleccionar'),
                ),
              ],
            ),
            if (_isExpanded) const SizedBox(height: 10),
            if (_isExpanded)
              Text(
                'Cantidad de Turnos: $_calculatedCount',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechaSelector({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        SizedBox(
          width: 150, // Ajustar el ancho del botón para que se vea bien
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(
              selectedDate != null
                  ? DateFormat('dd/MM/yyyy').format(selectedDate)
                  : 'Seleccionar',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate =
        isStartDate ? _fechaInicio ?? DateTime.now() : _fechaFin ?? DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = selectedDate;
        } else {
          _fechaFin = selectedDate;
        }
        _actualizarMetricas();
      });
    }
  }
}
