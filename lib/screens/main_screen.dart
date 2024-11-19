import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/widgets/calendar.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Sayfalarımızı tanımlıyoruz
  final List<Widget> _pages = [
    HabitListScreen(),
    StatisticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'İstatistikler',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HabitListScreen extends StatefulWidget {
  @override
  _HabitListScreenState createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Color _selectedColor = Colors.blue;
  Recurrence _selectedRecurrence = Recurrence.daily;

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habitsForSelectedDate = habitProvider.getHabitsForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Completed: ${habitProvider.getCompletedCount()}')),
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarWidget(
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'New Habit',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      habitProvider.addHabit(_controller.text, _selectedDate, _selectedColor, _selectedRecurrence);
                      _controller.clear();
                    }
                  },
                ),
              ),
            ),
          ),
          DropdownButton<Recurrence>(
            value: _selectedRecurrence,
            items: Recurrence.values.map((Recurrence recurrence) {
              return DropdownMenuItem<Recurrence>(
                value: recurrence,
                child: Text(recurrence.toString().split('.').last),
              );
            }).toList(),
            onChanged: (Recurrence? newValue) {
              setState(() {
                _selectedRecurrence = newValue!;
              });
            },
          ),
          Expanded(
            child: habitsForSelectedDate.isEmpty
                ? Center(child: Text('No habits for this date.'))
                : ListView.builder(
                    itemCount: habitsForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final habit = habitsForSelectedDate[index];
                      return ListTile(
                        title: Text(
                          habit.name,
                          style: TextStyle(
                            decoration: habit.isDone ? TextDecoration.lineThrough : null,
                            color: habit.color,
                          ),
                        ),
                        leading: Checkbox(
                          value: habit.isDone,
                          onChanged: (value) {
                            habitProvider.toggleHabitStatus(habitProvider.habits.indexOf(habit));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Habit status updated')));
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            habitProvider.removeHabit(habitProvider.habits.indexOf(habit));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Habit deleted')));
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}