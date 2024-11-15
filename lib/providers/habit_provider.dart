import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  // Yeni alışkanlık ekleme
  void addHabit(String habitName, DateTime date, Color color, Recurrence recurrence) {
    _habits.add(Habit(name: habitName, date: date, color: color, recurrence: recurrence));
    notifyListeners();
  }

  // Alışkanlık durumunu değiştirme
  void toggleHabitStatus(int index) {
    _habits[index].isDone = !_habits[index].isDone;
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
    notifyListeners();
  }
}
