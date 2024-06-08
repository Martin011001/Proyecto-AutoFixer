import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicacion_taller/entities/turn.dart';
import 'package:aplicacion_taller/widgets/turn_item.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class TurnosListScreen extends StatefulWidget {
  const TurnosListScreen({Key? key}) : super(key: key);

  @override
  _TurnosListScreenState createState() => _TurnosListScreenState();
}

class _TurnosListScreenState extends State<TurnosListScreen> {
  TurnState? selectedState;
  final List<TurnState> states = [
    TurnState('Todos', 'Todos los Turnos', Icons.all_inclusive),
    TurnState('Pendiente', 'Turnos Pendientes', Icons.access_time),
    TurnState('Confirmado', 'Turnos Confirmados', Icons.check_circle),
    TurnState('En Progreso', 'Turnos en Progreso', Icons.hourglass_bottom),
    TurnState('Realizado', 'Turnos Completados', Icons.done),
    TurnState('Cancelado', 'Turnos Cancelados', Icons.cancel),
  ];
  List<Turn> allTurns = [];
  bool isLoading = true;

  // Fechas para los filtros
  DateTime? startDate;
  DateTime? endDate;

  DateTime? egresoStartDate;
  DateTime? egresoEndDate;

  bool useIngresoFilter = true;
  bool useEgresoFilter = false;

  @override
  void initState() {
    super.initState();
    // Inicializar las fechas de filtro con una semana desde hoy
    startDate = DateTime.now();
    endDate = DateTime.now().add(Duration(days: 7));
    egresoStartDate = DateTime.now();
    egresoEndDate = DateTime.now().add(Duration(days: 14));
    _fetchTurns();
  }

  void _fetchTurns() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('turns').get();
      setState(() {
        allTurns = snapshot.docs.map((doc) => Turn.fromFirestore(doc)).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately here
    }
  }

  // Método para filtrar por fechas de ingreso y egreso
  List<Turn> _filterByDate(List<Turn> turns) {
    return turns.where((turn) {
      bool withinIngresoDates = true;
      bool withinEgresoDates = true;

      if (useIngresoFilter && startDate != null && endDate != null) {
        withinIngresoDates = turn.ingreso.isAfter(startDate!) && turn.ingreso.isBefore(endDate!);
      }

      if (useEgresoFilter && egresoStartDate != null && egresoEndDate != null) {
        withinEgresoDates = turn.egreso.isAfter(egresoStartDate!) && turn.egreso.isBefore(egresoEndDate!);
      }

      return withinIngresoDates && withinEgresoDates;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Turn> filteredTurns = selectedState != null &&
            selectedState!.value != 'Todos'
        ? allTurns.where((turn) => turn.state == selectedState!.value).toList()
        : allTurns;

    filteredTurns = _filterByDate(filteredTurns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnos'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<TurnState>(
                  value: selectedState ??
                      states.firstWhere((state) => state.value == 'Todos'),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                    if (value!.value == 'Todos') {
                      setState(() {
                        filteredTurns = allTurns;
                      });
                    }
                  },
                  items: states.map((state) {
                    return DropdownMenuItem<TurnState>(
                      value: state,
                      child: Row(
                        children: <Widget>[
                          Icon(state.icon),
                          const SizedBox(width: 10),
                          Text(state.title),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: useIngresoFilter,
                      onChanged: (value) {
                        setState(() {
                          useIngresoFilter = value ?? true;
                        });
                      },
                    ),
                    const Text('Usar Fecha de Ingreso para filtrar'),
                  ],
                ),
                if (useIngresoFilter) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != startDate) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                        child: Text(
                          'Fecha de Ingreso: ${startDate != null ? DateFormat('dd/MM/yyyy').format(startDate!) : 'Seleccione'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != endDate) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                        child: Text(
                          'Hasta: ${endDate != null ? DateFormat('dd/MM/yyyy').format(endDate!) : 'Seleccione'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: useEgresoFilter,
                      onChanged: (value) {
                        setState(() {
                          useEgresoFilter = value ?? false;
                        });
                      },
                    ),
                    const Text('Usar Fecha de Egreso para filtrar'),
                  ],
                ),
                if (useEgresoFilter) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: egresoStartDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != egresoStartDate) {
                            setState(() {
                              egresoStartDate = picked;
                            });
                          }
                        },
                        child: Text(
                          'Fecha de Egreso: ${egresoStartDate != null ? DateFormat('dd/MM/yyyy').format(egresoStartDate!) : 'Seleccione'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: egresoEndDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != egresoEndDate) {
                            setState(() {
                              egresoEndDate = picked;
                            });
                          }
                        },
                        child: Text(
                          'Hasta: ${egresoEndDate != null ? DateFormat('dd/MM/yyyy').format(egresoEndDate!) : 'Seleccione'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _ListTurnView(
                    turns: filteredTurns,
                  ),
          ),
        ],
      ),
    );
  }
}

class TurnState {
  final String value;
  final String title;
  final IconData icon;

  TurnState(this.value, this.title, this.icon);
}

class _ListTurnView extends StatelessWidget {
  final List<Turn> turns;

  const _ListTurnView({
    required this.turns,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...turns.map((turn) => TurnItem(turn: turn)),
        if (turns.isNotEmpty) const Divider(),
      ],
    );
  }
}
