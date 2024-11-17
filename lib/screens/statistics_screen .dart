import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';


class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('İstatistikler'),
      ),
      body: Center(
        child: Text(
          'Tamamlanan Görev Sayısı: ${habitProvider.getCompletedCount()}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}