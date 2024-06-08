import 'package:go_router/go_router.dart';
import 'package:aplicacion_taller/entities/user.dart';
import 'package:aplicacion_taller/entities/turn.dart';
import 'package:aplicacion_taller/screens/admin/turnos/turnos_details_screen.dart';
import 'package:aplicacion_taller/screens/admin/servicios/add_services_screen.dart';
import 'package:aplicacion_taller/screens/admin/home_screen.dart';
import 'package:aplicacion_taller/screens/admin/perfiles/home_screen.dart';
import 'package:aplicacion_taller/screens/admin/perfiles/profile_screen.dart';
import 'package:aplicacion_taller/screens/admin/servicios/_servicios_screen.dart';
import 'package:aplicacion_taller/screens/admin/turnos/turnos_list_screen.dart';
import 'package:aplicacion_taller/screens/admin/config/business_hours_screen.dart';

final adminRoutes = [
  GoRoute(
    path: '/administrador',
    builder: (context, state) => const AdminHomeScreen(),
  ),
  GoRoute(
    path: '/administrador/perfiles',
    builder: (context, state) => const PerfilesScreen(),
  ),
  GoRoute(
    path: '/administrador/perfiles/profile',
    builder: (context, state) => ProfileScreen(user: state.extra as User),
  ),
  GoRoute(
    path: '/administrador/turnos',
    builder: (context, state) => const TurnosListScreen(),
  ),
  //GoRoute(
  //  path: '/administrador/reparaciones',
  //  builder: (context, state) => const ReparacionesScreen(),
  //),
  GoRoute(
    path: '/administrador/servicios',
    builder: (context, state) => const ServiciosScreen(),
  ),
  //GoRoute(
  //  path: '/administrador/metricas',
  //  builder: (context, state) => const MetricasScreen(),
  //),
  // GoRoute(
  //   path: '/administrador/servicios-detail',
  //   builder: (context, state) => ServicieDetailScreen(service: state.extra as Service),
  // ),
  GoRoute(
    path: '/administrador/add-service',
    builder: (context, state) => AddServiceScreen(),
  ),
  GoRoute(
    path: '/administrador/business-hours',
    builder: (context, state) => const BusinessHoursScreen(),
  ),
  GoRoute(
    path: '/administrador/turno-detail',
    builder: (context, state) => TurnoDetailsScreen(turn: state.extra as Turn),
  ),
];
