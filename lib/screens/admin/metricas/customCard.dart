import 'package:flutter/material.dart';

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
  String? _selectedFecha;
  String? _selectedTipoServicio;

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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fecha'),
                DropdownButton<String>(
                  value: _selectedFecha,
                  items: const ['Día', 'Semana', 'Mes'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedFecha = value;
                    });
                    // Lógica para actualizar métrica según selección de fecha
                  },
                  hint: const Text('Seleccionar'),
                ),
              ],
            ),
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
                    });
                    // Lógica para actualizar métrica según selección de tipo de servicio
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
