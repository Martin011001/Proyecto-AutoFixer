import 'package:flutter/material.dart';

class StateSelector extends StatelessWidget {
  final String? selectedState;
  final List<String> states;
  final Function(String?) onChanged;

  const StateSelector({
    required this.selectedState,
    required this.states,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Seleccionar estado'),
      subtitle: selectedState != null
          ? Text('Estado seleccionado: ${_getStateTitle(selectedState!)}')
          : const Text('Seleccione un estado'),
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: states.length,
          itemBuilder: (context, index) {
            final state = states[index];
            return CheckboxListTile(
              value: selectedState == state,
              onChanged: (value) {
                onChanged(value ? state : null);
              },
              title: Text(_getStateTitle(state)),
            );
          },
        ),
      ],
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
