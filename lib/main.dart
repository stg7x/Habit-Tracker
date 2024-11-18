import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final provider = HabitProvider();
        provider.loadHabits(); // Alışkanlıkları yükle
        return provider;
      },
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
