import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepairRequestCalendar extends StatefulWidget {
  final Function(String)? onReservationIdSelected;

  const RepairRequestCalendar({Key? key, this.onReservationIdSelected})
      : super(key: key);

  @override
  _RepairRequestCalendarState createState() => _RepairRequestCalendarState();
}

class _RepairRequestCalendarState extends State<RepairRequestCalendar> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<DateTime, List<TimeOfDay>> _reservedTimes = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    _fetchReservedTimes(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Fecha y Hora'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildTimePicker(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleDateTimeSelection,
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2024, 12, 31),
      focusedDay: _selectedDate,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
        _fetchReservedTimes(selectedDay);
      },
    );
  }

  Widget _buildTimePicker() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final hour = index + 9;
          final time = TimeOfDay(hour: hour, minute: 0);
          final dateTime = DateTime(_selectedDate.year, _selectedDate.month,
              _selectedDate.day, hour, 0);

          return ListTile(
            title: Text(time.format(context)),
            onTap: _isTimeAvailable(dateTime)
                ? () {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                : null,
            selected: _selectedTime == time,
            enabled: _isTimeAvailable(dateTime),
          );
        },
      ),
    );
  }

  bool _isTimeAvailable(DateTime dateTime) {
    final times =
        _reservedTimes[DateTime(dateTime.year, dateTime.month, dateTime.day)];
    if (times != null) {
      final selectedTime =
          TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      for (var reservedTime in times) {
        if (reservedTime.hour == selectedTime.hour &&
            reservedTime.minute == selectedTime.minute) {
          return false; // La hora seleccionada ya está reservada
        }
      }
    }
    return true; // La hora seleccionada está disponible
  }

  Future<void> _fetchReservedTimes(DateTime date) async {
    try {
      final snapshot = await _firestore
          .collection('reservations')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
          .where('date',
              isLessThan: Timestamp.fromDate(date.add(const Duration(days: 1))))
          .where('reserved',
              isEqualTo: true) // Filtra solo las reservas confirmadas
          .get();

      final times = snapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp;
        final dateTime = timestamp.toDate();
        return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      }).toList();

      setState(() {
        _reservedTimes[DateTime(date.year, date.month, date.day)] = times;
      });
    } catch (e) {
      // Manejar errores de manera apropiada
      print("Error fetching reserved times: $e");
    }
  }

  Future<void> _handleDateTimeSelection() async {
    final selectedDateTime = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

    // Verifica si la fecha y hora seleccionadas ya están reservadas
    if (!_isTimeAvailable(selectedDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('La fecha y hora seleccionadas ya están reservadas.')),
      );
      return;
    }

    // Crear la reserva en Firestore y obtener el ID
    DocumentReference reservationRef =
        await _firestore.collection('reservations').add({
      'date': selectedDateTime,
      'reserved': false, // Inicialmente falso
      // Aquí debes agregar cualquier otro campo necesario, como userId, vehicleId, etc.
    });

    String reservationId = reservationRef.id;

    // Enviar el reservationId de vuelta a SelectService
    widget.onReservationIdSelected?.call(reservationId);

    // Volver a la pantalla anterior
    Navigator.pop(context);
  }
}
