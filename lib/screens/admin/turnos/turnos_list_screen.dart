import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicacion_taller/entities/turn.dart';

import 'package:aplicacion_taller/widgets/turn_item.dart';

class TurnosListScreen extends StatefulWidget {
  const TurnosListScreen({super.key});

  @override
  _TurnosListScreenState createState() => _TurnosListScreenState();
}

class _TurnosListScreenState extends State<TurnosListScreen> {
  String? selectedState;
  final List<String> states = [
    'Pendiente',
    'Confirmado',
    'En Progreso',
    'Realizado',
    'Cancelado'
  ];
  List<Turn> allTurns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    List<Turn> filteredTurns = selectedState != null
        ? allTurns.where((turn) => turn.state == selectedState).toList()
        : allTurns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnos'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Seleccionar estado'),
            subtitle: selectedState != null
                ? Text('Estado seleccionado: ${_getStateTitle(selectedState!)}')
                : const Text('Seleccione un estado'),
            children: states.map((state) {
              return CheckboxListTile(
                value: selectedState == state,
                onChanged: (value) {
                  setState(() {
                    selectedState = value! ? state : null;
                  });
                },
                title: Text(_getStateTitle(state)),
              );
            }).toList(),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _ListTurnView(
                    turns: filteredTurns,
                    selectedState: selectedState,
                    getStateTitle: _getStateTitle,
                  ),
          ),
        ],
      ),
    );
  }

  String _getStateTitle(String state) {
    switch (state) {
      case 'Pendiente':
        return 'Turnos Pendientes';
      case 'Confirmado':
        return 'Turnos Confirmados';
      case 'En Progreso':
        return 'Turnos en Progreso';
      case 'Realizado':
        return 'Turnos Completados';
      case 'Cancelado':
        return 'Turnos Cancelados';
      default:
        return '';
    }
  }
}

class _ListTurnView extends StatelessWidget {
  final List<Turn> turns;
  final String? selectedState;
  final Function(String) getStateTitle;

  const _ListTurnView({
    required this.turns,
    required this.selectedState,
    required this.getStateTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (selectedState != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              getStateTitle(selectedState!),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ...turns.map((turn) => TurnItem(turn: turn)),
        if (turns.isNotEmpty) const Divider(),
      ],
    );
  }
}
