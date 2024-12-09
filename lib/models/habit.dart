import 'package:flutter/material.dart';

// Habit model sınıfı
enum Recurrence { daily, weekly, monthly }

class Habit {
  String name;
  DateTime date;
  Color color;
  Recurrence recurrence;
  Map<String, bool> completionStatus; // Tarih bazlı tamamlanma durumu

  Habit({
    required this.name,
    required this.date,
    required this.color,
    required this.recurrence,
    Map<String, bool>? completionStatus, // Varsayılan değeri opsiyonel parametre olarak alıyoruz.
  }) : completionStatus = completionStatus ?? {}; // Eğer completionStatus null ise, boş bir harita oluşturuyoruz.

  // JSON'a dönüştürme metodu
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'color': color.value,
      'recurrence': recurrence.toString(),
      'completionStatus': completionStatus, // Harita JSON'a dahil edilir
    };
  }

  // JSON'dan nesneye dönüştürme metodu
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      date: DateTime.parse(json['date']),
      color: Color(json['color']),
      recurrence: Recurrence.values.firstWhere(
        (e) => e.toString() == json['recurrence'], 
        orElse: () => Recurrence.daily,  // Varsayılan değer
      ),
      completionStatus: Map<String, bool>.from(json['completionStatus'] ?? {}),
    );
  }
}

// DateTime karşılaştırması için extension
extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
