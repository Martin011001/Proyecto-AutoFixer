import 'package:flutter/material.dart';
import 'package:aplicacion_taller/widgets/home_screen_base.dart';
import 'package:aplicacion_taller/widgets/navigation_button.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return const HomeScreenBase(
      title: 'Inicio: Admin',
      buttons: [
        NavigationButton(
          text: 'Turnos',
          route: '/administrador/turnos',
          icon: Icon(Icons.calendar_month, size: 115, color: Colors.white),
        ),
        NavigationButton(
          text: 'Usuarios',
          route: '/administrador/perfiles',
          icon: Icon(Icons.person, size: 115, color: Colors.white),
        ),
        NavigationButton(
          text: 'Metricas',
          route: '/administrador/metricas',
          icon: Icon(Icons.bar_chart, size: 115, color: Colors.white),
        ),
        NavigationButton(
          text: 'Servicios',
          route: '/administrador/servicios',
          icon: Icon(Icons.local_hospital, size: 115, color: Colors.white),
        ),
        NavigationButton(
          text: 'Horas de negocio',
          route: '/administrador/business-hours',
          icon: Icon(Icons.access_time, size: 115, color: Colors.white),
        ),
      ],
    );
  }
}
