import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Mock storage service to make the code runnable
class StorageService {
  static Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> jsonList = json.decode(tasksString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = json.encode(tasks);
    await prefs.setString('tasks', tasksString);
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _taskFocusNode = FocusNode();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  String _searchQuery = '';
  String _selectedCategory = 'Personal';
  final Set<int> _completedTasks = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    _taskController.dispose();
    _searchController.dispose();
    _taskFocusNode.dispose();
    super.dispose();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    try {
      final tasks = await StorageService.loadTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          // Initialize completed tasks set
          for (int i = 0; i < _tasks.length; i++) {
            if (_tasks[i]['completed'] == true) {
              _completedTasks.add(i);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  // Save tasks to SharedPreferences
  void _saveTasks() {
    StorageService.saveTasks(_tasks);
  }

  // Add a task
  void _addTask() {
    final task = _taskController.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        _tasks.insert(0, {
          'title': task,
          'category': _selectedCategory,
          'completed': false,
          'createdAt': DateTime.now().toString(),
        });
      });
      _taskController.clear();
      _saveTasks();
      _taskFocusNode.unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid task')),
      );
    }
  }

  // Toggle task completion
  void _toggleTaskCompletion(int index) {
    setState(() {
      if (_completedTasks.contains(index)) {
        _completedTasks.remove(index);
        _tasks[index]['completed'] = false;
      } else {
        _completedTasks.add(index);
        _tasks[index]['completed'] = true;
      }
    });
    _saveTasks();
  }

  // Delete a task
  void _deleteTask(int index) {
    final deletedTask = _tasks[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${deletedTask['title']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                  _completedTasks.remove(index);
                });
                _saveTasks();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${deletedTask['title']}" deleted')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Edit a task
  void _editTask(int index) {
    final currentTask = _tasks[index];
    _taskController.text = currentTask['title'];
    _selectedCategory = currentTask['category'] ?? 'Personal';

    showDialog(
      context: context,
      builder: (context) {
        String tempCategory = _selectedCategory;

        return AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Edit your task...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  children: ['Personal', 'Work', 'Shopping', 'Health'].map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: tempCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          tempCategory = category;
                          _selectedCategory = tempCategory;
                        });
                        Navigator.pop(context);
                        _editTask(index);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedTask = _taskController.text.trim();
                if (updatedTask.isNotEmpty) {
                  setState(() {
                    _tasks[index] = {
                      'title': updatedTask,
                      'category': tempCategory,
                      'completed': currentTask['completed'],
                      'createdAt': currentTask['createdAt'],
                    };
                  });
                  _saveTasks();
                  _taskController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task cannot be empty')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Clear all tasks
  void _clearAllTasks() {
    if (_tasks.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Tasks?'),
          content: const Text('This will remove all tasks. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tasks.clear();
                  _completedTasks.clear();
                });
                _saveTasks();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All tasks cleared')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  // Filter tasks based on search query
  List<Map<String, dynamic>> get _filteredTasks {
    if (_searchQuery.isEmpty) return _tasks;
    return _tasks.where((task) =>
    task['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (task['category']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          if (_tasks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllTasks,
              tooltip: 'Clear All Tasks',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EAF6), Color(0xFFFFFFFF)],
          ),
        ),
        child: SingleChildScrollView( // WRAPPED THE CONTENT IN A SCROLL VIEW TO PREVENT OVERFLOW
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "What's on your mind?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Selection
                    Wrap(
                      spacing: 8.0,
                      children: ['Personal', 'Work', 'Shopping', 'Health'].map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: _selectedCategory == category
                              ? const Color(0xFF3F51B5)
                              : Colors.grey[200],
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Add Task Input Section
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _taskController,
                                focusNode: _taskFocusNode,
                                decoration: InputDecoration(
                                  hintText: 'Enter a new task...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onSubmitted: (_) => _addTask(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _addTask,
                              icon: const Icon(Icons.add, size: 24),
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F51B5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search Bar
                    if (_tasks.isNotEmpty)
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),

                    // Tasks Counter
                    if (_tasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Tasks: ${_tasks.length} • Completed: ${_completedTasks.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),

                    // Tasks List
                    // NOTE: Removed `Expanded` because it's inside a `SingleChildScrollView`
                    filteredTasks.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.checklist_rounded
                                : Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No tasks yet!\nAdd your first task to get started.'
                                : 'No tasks found for "$_searchQuery"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true, // IMPORTANT: Allows ListView to work inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final originalIndex = _tasks.indexWhere((t) => t['title'] == task['title'] && t['category'] == task['category']);
                        final isCompleted = originalIndex != -1 && _completedTasks.contains(originalIndex);

                        return Dismissible(
                          key: Key('${task['title']}${task['category']}'),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            if (originalIndex != -1) {
                              _deleteTask(originalIndex);
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: GestureDetector(
                                onTap: () {
                                  if (originalIndex != -1) {
                                    _toggleTaskCompletion(originalIndex);
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: isCompleted
                                      ? Colors.green
                                      : const Color(0xFF3F51B5),
                                  child: Icon(
                                    isCompleted ? Icons.check : Icons.circle,
                                    color: Colors.white,
                                    size: isCompleted ? 20 : 16,
                                  ),
                                ),
                              ),
                              title: Text(
                                task['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: isCompleted ? Colors.grey : Colors.black,
                                ),
                              ),
                              subtitle: task['category'] != null
                                  ? Text(
                                task['category'],
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      if (originalIndex != -1) {
                                        _editTask(originalIndex);
                                      }
                                    },
                                    tooltip: 'Edit Task',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      if (originalIndex != -1) {
                                        _deleteTask(originalIndex);
                                      }
                                    },
                                    tooltip: 'Delete Task',
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (originalIndex != -1) {
                                  _editTask(originalIndex);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
