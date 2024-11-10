import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/widgets/calendar.dart';

enum Recurrence { daily, weekly, monthly }

class Habit {
  String name;
  bool isDone;
  DateTime date;
  Color color;
  Recurrence recurrence;

  Habit({
    required this.name,
    this.isDone = false,
    required this.date,
    required this.color,
    required this.recurrence,
  });
}

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  void addHabit(String habitName, DateTime date, Color color, Recurrence recurrence) {
    _habits.add(Habit(name: habitName, date: date, color: color, recurrence: recurrence));
    notifyListeners();
  }

  void toggleHabitStatus(int index) {
    _habits[index].isDone = !_habits[index].isDone;
    notifyListeners();
  }

  List<Habit> getHabitsForDate(DateTime date) {
    return _habits.where((habit) {
      if (habit.date.isSameDate(date)) return true;
      if (habit.recurrence == Recurrence.daily) return true;
      if (habit.recurrence == Recurrence.weekly && date.weekday == habit.date.weekday) return true;
      if (habit.recurrence == Recurrence.monthly && date.day == habit.date.day) return true;
      return false;
    }).toList();
  }

  int getCompletedCount() {
    return _habits.where((habit) => habit.isDone).length;
  }

  void removeHabit(int index) {
    _habits.removeAt(index);
    notifyListeners();
  }
}

extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

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