import 'package:aplicacion_taller/entities/info_cliente_turn_progress.dart';
import 'package:aplicacion_taller/screens/cliente/cliente_edit.dart';
import 'package:aplicacion_taller/screens/cliente/turnos/turno_progress_screen.dart';
import 'package:go_router/go_router.dart';

import 'package:aplicacion_taller/screens/cliente/home_screen.dart';
import 'package:aplicacion_taller/screens/cliente/turnos/turno_history_screen.dart';
import 'package:aplicacion_taller/screens/cliente/vehiculo/list_screen.dart';
import 'package:aplicacion_taller/screens/cliente/turnos/turno_confirm_screen.dart';
import 'package:aplicacion_taller/screens/cliente/turnos/turno_thankyou_screen.dart';
import 'package:aplicacion_taller/screens/cliente/vehiculo/register_screen.dart';
import 'package:aplicacion_taller/screens/cliente/vehiculo/details_screen.dart';
import 'package:aplicacion_taller/screens/cliente/vehiculo/edit_screen.dart';

import 'package:aplicacion_taller/screens/cliente/turnos/turno_create_screen.dart';
import 'package:aplicacion_taller/entities/vehicle.dart';

final clienteRoutes = [
  GoRoute(
    path: '/cliente',
    builder: (context, state) => const ClienteHomeScreen(),
  ),
  GoRoute(
    path: '/cliente/reparations',
    builder: (context, state) => const ReparationHistoryScreen(),
  ),
  //GoRoute(
  //  path: '/cliente/turns/create',
  //  builder: (context, state) => const SeleccionarServicio(),
  //),
  GoRoute(
    path: '/cliente/turns/confirm/:turnId',
    builder: (context, state) {
      final turnId = state.pathParameters['turnId']!;
      return ConfirmTurnScreen(turnId: turnId);
    },
  ),
  GoRoute(
    path: '/cliente/turns/thankYou',
    builder: (context, state) => ThankYouScreen(),
  ),
  GoRoute(
    path: '/cliente/vehiculo/list',
    builder: (context, state) => const VehicleListScreen(),
  ),
  GoRoute(
    path: '/cliente/vehiculo/register',
    builder: (context, state) => const VehicleRegisterScreen(),
  ),
  GoRoute(
    path: '/cliente/vehiculo/details',
    builder: (context, state) =>
        VehicleDetailsScreen(vehiculo: state.extra as Vehicle),
  ),
  GoRoute(
    path: '/cliente/vehiculo/edit',
    builder: (context, state) =>
        VehicleEditScreen(vehicle: state.extra as Vehicle),
  ),
  // WIP
  GoRoute(
    path: '/cliente/turns/create/refactor',
    builder: (context, state) => const TurnCreate(),
  ),

  GoRoute(
    path: '/cliente/editar/perfil',
    builder: (context, state) => const EditUserScreen(),
  ),
  GoRoute(
    path: '/cliente/turn-progress',
    builder: (context, state) =>
        VerProgresoReparaciones(turnDetails: state.extra as TurnDetails),
  ),
];
