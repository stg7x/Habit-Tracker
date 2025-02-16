import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:pie_chart/pie_chart.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final today = DateTime.now();
    final completedToday = habitProvider.getCompletedCount(today);
    final totalHabits = habitProvider.habits.length;

    Map<String, double> _createSampleData() {
      return {
        'Completed': completedToday.toDouble(),
        'Remaining': (totalHabits - completedToday).toDouble(),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Statistics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Completed Habits: $completedToday',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Total Habits: $totalHabits',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Overall Statistics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: PieChart(
                dataMap: _createSampleData(),
                chartType: ChartType.ring,
                chartRadius: MediaQuery.of(context).size.width / 2,
                colorList: [Colors.green, Colors.red],
                chartValuesOptions: ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: true,
                  decimalPlaces: 1,
                ),
                legendOptions: LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                  legendTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: habitProvider.habits.length,
                itemBuilder: (context, index) {
                  final habit = habitProvider.habits[index];
                  final completedCount = habit.completionStatus.values
                      .where((status) => status)
                      .length;

                  return ListTile(
                    title: Text(habit.name),
                    subtitle: Text('Completed: $completedCount times'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}