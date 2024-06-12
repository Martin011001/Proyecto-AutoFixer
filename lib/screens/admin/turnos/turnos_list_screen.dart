import 'package:aplicacion_taller/widgets/turnos_list.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnos'),
        automaticallyImplyLeading: true,
      ),
      body: TurnosList(),
    );
  }
}
