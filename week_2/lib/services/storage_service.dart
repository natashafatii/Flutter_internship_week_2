import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  // Save tasks as JSON string
  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = json.encode(tasks);
    await prefs.setString('tasks', tasksString);
  }

  // Load tasks from JSON string
  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      try {
        final List<dynamic> tasksList = json.decode(tasksString);
        return tasksList.cast<Map<String, dynamic>>();
      } catch (e) {
        // Handle legacy format (List<String>)
        final List<dynamic> tasksList = json.decode(tasksString);
        if (tasksList.isNotEmpty && tasksList[0] is String) {
          // Convert from old format to new format
          return tasksList.map((task) => {
            'title': task.toString(),
            'category': 'Personal',
            'completed': false,
            'createdAt': DateTime.now().toString(),
          }).toList();
        }
        return [];
      }
    }
    return [];
  }

  // Save counter value
  static Future<void> saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', value);
  }

  // Load counter value
  static Future<int> loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('counter') ?? 0;
  }
}