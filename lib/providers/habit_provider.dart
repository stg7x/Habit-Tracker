import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'dart:convert'; // JSON encode/decode için
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences için

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  // Yeni alışkanlık ekleme
  void addHabit(String habitName, DateTime date, Color color, Recurrence recurrence) {
    _habits.add(Habit(name: habitName, date: date, color: color, recurrence: recurrence));
    saveHabits(); // Alışkanlıkları kaydet (SharedPreferences ile)
    notifyListeners();
  }

  // Alışkanlık durumunu değiştirme
  void toggleHabitStatus(int index) {
    _habits[index].isDone = !_habits[index].isDone;
    saveHabits(); // Değişiklik sonrası kaydet
    notifyListeners();
  }

  // Tarihe göre alışkanlıkları getirme
  List<Habit> getHabitsForDate(DateTime date) {
    return _habits.where((habit) {
      if (habit.date.isSameDate(date)) return true;
      if (habit.recurrence == Recurrence.daily) return true;
      if (habit.recurrence == Recurrence.weekly && date.weekday == habit.date.weekday) return true;
      if (habit.recurrence == Recurrence.monthly && date.day == habit.date.day) return true;
      return false;
    }).toList();
  }

  // Tamamlanan alışkanlık sayısını al
  int getCompletedCount() {
    return _habits.where((habit) => habit.isDone).length;
  }

  // Alışkanlık silme
  void removeHabit(int index) {
    _habits.removeAt(index);
    saveHabits(); // Silme sonrası kaydet
    notifyListeners();
  }

  // *** SharedPreferences işlemleri ***

  // Alışkanlıkları SharedPreferences'e kaydetme
  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences başlat
    final String encodedHabits = json.encode(_habits.map((habit) => habit.toJson()).toList());
    await prefs.setString('habits', encodedHabits); // JSON string olarak kaydet
  }

  // Alışkanlıkları SharedPreferences'den yükleme
  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance(); // SharedPreferences başlat
    final String? savedHabits = prefs.getString('habits'); // Alışkanlıkları getir
    if (savedHabits != null) {
      final List decodedHabits = json.decode(savedHabits); // JSON'dan listeye dönüştür
      _habits.clear();
      _habits.addAll(decodedHabits.map((habit) => Habit.fromJson(habit)).toList());
      notifyListeners(); // Ekranı güncelle
    }
  }
}
