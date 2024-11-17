import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/widgets/calendar.dart';
import 'models/habit.dart';
import 'providers/habit_provider.dart';
import 'screens/main_screen.dart';
import 'screens/statistics_screen .dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: MainScreen(),
    );
  }
}