import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplicacion_taller/entities/turn.dart';

import 'package:aplicacion_taller/widgets/turn_item.dart';

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
    List<Turn> filteredTurns = selectedState != null &&
            selectedState!.value != 'Todos'
        ? allTurns.where((turn) => turn.state == selectedState!.value).toList()
        : allTurns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnos'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<TurnState>(
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
