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
  void initState() {
    super.initState();
    Provider.of<HabitProvider>(context, listen: false).loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddHabitDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddHabitDialog extends StatefulWidget {
  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Color _selectedColor = Colors.blue;
  Recurrence _selectedRecurrence = Recurrence.daily;

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    return AlertDialog(
      title: Text('Add New Habit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Habit Name'),
          ),
          SizedBox(height: 10),
          ListTile(
            title: Text('Select Date'),
            trailing: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
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
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                habitProvider.addHabit(
                  _controller.text,
                  _selectedDate,
                  _selectedColor,
                  _selectedRecurrence,
                );
                Navigator.of(context).pop();
              }
            },
            child: Text('Add Habit'),
          ),
        ],
      ),
    );
  }
}

class HabitListScreen extends StatefulWidget {
  @override
  _HabitListScreenState createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  DateTime _selectedDate = DateTime.now();

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
            child: Center(
                child: Text(
                    'Completed: ${habitProvider.getCompletedCount(_selectedDate)}')),
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
              habitProvider.loadHabits();
            },
          ),
          Expanded(
            child: habitsForSelectedDate.isEmpty
                ? Center(child: Text('No habits for this date.'))
                : ListView.builder(
                    itemCount: habitsForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final habit = habitsForSelectedDate[index];
                      final dateKey = _selectedDate.toIso8601String();

                      return ListTile(
                        title: Text(
                          habit.name,
                          style: TextStyle(
                            decoration: habit.completionStatus[dateKey] ?? false
                                ? TextDecoration.lineThrough
                                : null,
                            color: habit.color,
                          ),
                        ),
                        leading: Checkbox(
                          value: habit.completionStatus[dateKey] ?? false,
                          onChanged: (value) {
                            habitProvider.toggleHabitStatus(
                                habitProvider.habits.indexOf(habit),
                                _selectedDate);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Habit status updated')));
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            habitProvider.removeHabit(
                                habitProvider.habits.indexOf(habit));
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Habit deleted')));
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
