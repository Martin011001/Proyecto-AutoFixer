import 'package:flutter/material.dart';
import 'package:aplicacion_taller/widgets/home_screen_base.dart';
import 'package:aplicacion_taller/widgets/navigation_button.dart';

class ClienteHomeScreen extends StatelessWidget {
  const ClienteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeScreenBase(
        title: 'Inicio: cliente',
        buttons: [
          NavigationButton(
            text: 'Mis vehiculos',
            route: '/cliente/vehiculo/list',
            icon: Icon(Icons.car_rental, size: 115, color: Colors.white),
          ),
          NavigationButton(
            text: 'Mis reparaciones',
            route: '/cliente/reparations',
            icon: Icon(Icons.build, size: 115, color: Colors.white),
          ),
          NavigationButton(
            text: 'Solicitar turno',
            route: '/cliente/turns/create/refactor',
            icon: Icon(Icons.calendar_month, size: 115, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
