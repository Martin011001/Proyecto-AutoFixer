import 'package:intl/intl.dart';

class TurnDetails {
  final String userName;
  final String vehicleBrand;
  final String vehicleModel;
  final DateTime ingreso;
  final String turnState;

  TurnDetails({
    required this.userName,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.ingreso,
    required this.turnState,
  });

   String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(ingreso);
  }
}