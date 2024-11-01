import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

// Task model
class Task {
  String name;
  bool isDone;
  DateTime date; // Yeni tarih özelliği eklendi

  Task({required this.name, this.isDone = false, required this.date});
}

// Task Provider
class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String taskName, DateTime date) {
    _tasks.add(Task(name: taskName, date: date)); // Task'e tarih bilgisi ile ekleme yapıldı
    notifyListeners();
  }

  void toggleTaskStatus(int index) {
    _tasks[index].isDone = !_tasks[index].isDone;
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  // Seçilen tarihe göre görevleri döndüren fonksiyon
  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) => task.date.isSameDate(date)).toList();
  }
}

// Tarih kontrolü için yardımcı fonksiyon
extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoListScreen(),
    );
  }
}

// To-Do List ekranı artık StatefulWidget olarak tanımlandı
class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

// TodoListScreen'in State'i
class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Seçilen tarihi tutmak için bir değişken

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: Column(
        children: [
          CalendarWidget(
            onDaySelected: (selectedDay, focusedDay) { // Takvimden tarih seçme
              setState(() {
                _selectedDate = selectedDay; // Seçilen tarih güncelleniyor
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'New Task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      taskProvider.addTask(_controller.text, _selectedDate); // Seçilen tarih ile görev ekleme
                      _controller.clear();
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: taskProvider.getTasksForDate(_selectedDate).length, // Seçilen tarihe göre görev listeleme
              itemBuilder: (context, index) {
                final task = taskProvider.getTasksForDate(_selectedDate)[index]; // Seçilen tarihe göre görevleri al
                return ListTile(
                  title: Text(
                    task.name,
                    style: TextStyle(
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (value) {
                      taskProvider.toggleTaskStatus(index);
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      taskProvider.removeTask(index);
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

// Takvim bileşeni

class CalendarWidget extends StatelessWidget {
  final Function(DateTime, DateTime) onDaySelected; // onDaySelected parametresi

  CalendarWidget({required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    // _TodoListScreenState'e erişim
    final _TodoListScreenState state = context.findAncestorStateOfType<_TodoListScreenState>()!;

    return TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
      onDaySelected: (selectedDay, focusedDay) {
        print('Seçilen Gün: $selectedDay'); // Seçilen gün konsola yazdırılır
        onDaySelected(selectedDay, focusedDay);
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue, // Seçilen gün için arka plan rengi
          shape: BoxShape.rectangle, // Şekil
        ),
        selectedTextStyle: TextStyle(
          color: Colors.white, // Seçilen gün üzerindeki metin rengi
        ),
        defaultDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
        ),
      ),
      // Seçilen günü kontrol etmek için
      selectedDayPredicate: (day) {
        return day.isSameDate(state._selectedDate); // _selectedDate ile karşılaştırma
      },
    );
  }
}
