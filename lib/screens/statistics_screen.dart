import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final today = DateTime.now();
    final completedToday = habitProvider.getCompletedCount(today);
    final totalHabits = habitProvider.habits.length;

    List<charts.Series<ChartData, String>> _createSampleData() {
      final data = [
        ChartData('Completed', completedToday),
        ChartData('Remaining', totalHabits - completedToday),
      ];

      return [
        charts.Series<ChartData, String>(
          id: 'Habits',
          domainFn: (ChartData data, _) => data.label,
          measureFn: (ChartData data, _) => data.value,
          data: data,
          labelAccessorFn: (ChartData row, _) => '${row.label}: ${row.value}',
        )
      ];
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
              child: charts.PieChart(
                _createSampleData(),
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcWidth: 60,
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.inside,
                    )
                  ],
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
