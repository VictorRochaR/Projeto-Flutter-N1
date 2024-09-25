import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

Color hexToColor(String hexColor) {
  final buffer = StringBuffer();
  buffer.write('ff');
  buffer.write(hexColor.substring(1));
  return Color(int.parse(buffer.toString(), radix: 16));
}

class AppColors {
  static final Color primaryColor = hexToColor('#291D21');
  static final Color secondaryColor = hexToColor('#5D544D');
  static final Color backgroundColor = hexToColor('#E1DACA');
  static final Color accentColor = hexToColor('#CB6F84');
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HOME TODO',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: TaskPlanner(),
    );
  }
}

class TaskPlanner extends StatefulWidget {
  @override
  _TaskPlannerState createState() => _TaskPlannerState();
}

class _TaskPlannerState extends State<TaskPlanner> {
  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController = TextEditingController();
  final TextEditingController responsibleController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedView = 'Day';

  void addTask() {
    if (taskController.text.isNotEmpty &&
        responsibleController.text.isNotEmpty) {
      setState(() {
        tasks.add({
          'task': taskController.text,
          'owner': responsibleController.text,
          'date': selectedDate,
          'done': false,
        });
        taskController.clear();
        responsibleController.clear();
      });
    }
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index]['done'] = !tasks[index]['done'];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    tasks.sort((a, b) => a['date'].compareTo(b['date']));

    Map<String, List<Map<String, dynamic>>> groupedTasks = {};
    for (var task in tasks) {
      String dateKey;
      if (selectedView == 'Day') {
        dateKey = DateFormat('yyyy-MM-dd').format(task['date']);
      } else {
        DateTime startOfWeek =
            task['date'].subtract(Duration(days: task['date'].weekday - 1));
        dateKey = DateFormat('yyyy-MM-dd').format(startOfWeek);
      }

      if (!groupedTasks.containsKey(dateKey)) {
        groupedTasks[dateKey] = [];
      }
      groupedTasks[dateKey]!.add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HOME TODO',
          style: TextStyle(color: AppColors.primaryColor),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.accentColor,
        actions: [
          DropdownButton<String>(
            value: selectedView,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
            onChanged: (String? newValue) {
              setState(() {
                selectedView = newValue!;
              });
            },
            items: <String>['Day', 'Week']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: TextStyle(color: AppColors.primaryColor)),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groupedTasks.length,
        itemBuilder: (context, index) {
          String dateKey = groupedTasks.keys.elementAt(index);
          List<Map<String, dynamic>> tasksForDate = groupedTasks[dateKey]!;

          return Card(
            color: AppColors.backgroundColor,
            margin: EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(
                selectedView == 'Day'
                    ? DateFormat('EEEE, MMMM d  yyyy')
                        .format(DateTime.parse(dateKey))
                    : 'Week ${DateFormat('MMMM d, yyyy').format(DateTime.parse(dateKey))}',
                style: TextStyle(color: AppColors.primaryColor),
              ),
              children: tasksForDate.map((task) {
                return ListTile(
                  title: Text(task['task'],
                      style: TextStyle(color: AppColors.primaryColor)),
                  subtitle: Text('Owner: ${task['owner']}',
                      style: TextStyle(color: AppColors.primaryColor)),
                  trailing: Checkbox(
                    value: task['done'],
                    onChanged: (value) {
                      toggleTask(tasks.indexOf(task));
                    },
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: taskController,
                      decoration: InputDecoration(labelText: 'Task'),
                    ),
                    TextField(
                      controller: responsibleController,
                      decoration: InputDecoration(labelText: 'Owner'),
                    ),
                    SizedBox(height: 10),
                    Text("Date:"),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addTask();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.accentColor,
      ),
    );
  }
}
