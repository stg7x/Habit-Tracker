import 'package:flutter/material.dart';

// Habit model sınıfı
enum Recurrence { daily, weekly, monthly }

class Habit {
  String name;
  bool isDone;
  DateTime date;
  Color color;
  Recurrence recurrence;

  Habit({
    required this.name,
    this.isDone = false,
    required this.date,
    required this.color,
    required this.recurrence,
  });
}

// DateTime karşılaştırması için extension
extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
