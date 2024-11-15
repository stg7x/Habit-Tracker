import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habit_tracker/models/habit.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime, DateTime) onDaySelected;
  CalendarWidget({Key? key, required this.onDaySelected}) : super(key: key);
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}
class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();  // Seçilen tarihi burada tutuyoruz.
  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: _focusedDay,
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;  // Seçilen tarihi güncelliyoruz.
          _focusedDay = focusedDay;  // Focused günü güncelliyoruz.
        });
        widget.onDaySelected(selectedDay, focusedDay);  // Ana widget'tan gelen onDaySelected fonksiyonunu çağırıyoruz
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.teal,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(color: Colors.white),
        defaultDecoration: BoxDecoration(shape: BoxShape.rectangle),
      ),
      selectedDayPredicate: (day) {
        return day.isSameDate(_selectedDate);  // Seçilen tarihi kontrol ediyoruz.
      },
    );
  }
}