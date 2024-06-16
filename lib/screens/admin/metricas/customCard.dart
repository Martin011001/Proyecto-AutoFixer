import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Importar para formateo de fechas

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
