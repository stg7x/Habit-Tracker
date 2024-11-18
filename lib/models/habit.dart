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

  // *** JSON'a dönüştürmek için toJson metodu ***
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isDone': isDone,
      'date': date.toIso8601String(),
      'color': color.value, // Renk değeri int olarak kaydediliyor
      'recurrence': recurrence.toString(), // Enum string olarak kaydediliyor
    };
  }

  // *** JSON'dan nesneye dönüştürmek için fromJson metodu ***
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      isDone: json['isDone'],
      date: DateTime.parse(json['date']),
      color: Color(json['color']), // Renk int değerinden Color nesnesine dönüştürülüyor
      recurrence: Recurrence.values.firstWhere((e) => e.toString() == json['recurrence']),
    );
  }
}

// DateTime karşılaştırması için extension
extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
