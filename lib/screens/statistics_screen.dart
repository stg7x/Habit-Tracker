import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final today = DateTime.now(); // Bugünün tarihi

    return Scaffold(
      appBar: AppBar(
        title: Text('İstatistikler'),
      ),
      body: Center(
        child: Text(
          'Tamamlanan Görev Sayısı: ${habitProvider.getCompletedCount(today)}', // Bugün için tamamlanan görev sayısı
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
