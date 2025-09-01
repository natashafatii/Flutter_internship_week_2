import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Show quick add menu in modal bottom sheet
  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Quick Add",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.task, color: Color(0xFF3F51B5)),
                title: const Text('Add New Task'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/todo');
                },
              ),
              ListTile(
                leading: const Icon(Icons.note_add, color: Color(0xFF3F51B5)),
                title: const Text('Create Quick Note'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddNoteDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer, color: Color(0xFF3F51B5)),
                title: const Text('Start Timer'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Timer started for 25 minutes')),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show dialog to add a note
  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Quick Note'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Enter your note here...'),
            autofocus: true,
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note saved successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show a confirmation dialog for a task
  void _showConfirmationDialog(BuildContext context, String task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text('Do you want to add "$task"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$task added successfully')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x40000000),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EAF6), Color(0xFFFFFFFF)],
          ),
        ),
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    shadowColor: const Color(0x33000000),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.home_rounded,
                              size: 60,
                              color: const Color(0xFF3F51B5),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Welcome to Your Dashboard!",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Manage your tasks and track your progress",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            _AnimatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/todo');
                              },
                              icon: Icons.check_circle_outline,
                              label: 'Go to To-Do List',
                              color: const Color(0xFF3F51B5),
                            ),
                            const SizedBox(height: 20),
                            _AnimatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/counter');
                              },
                              icon: Icons.add_circle_outline,
                              label: 'Go to Counter',
                              color: const Color(0xFF3F51B5),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Use the + button to quickly add items!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddMenu(context),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        elevation: 6,
        tooltip: 'Quick Add Menu', // Added tooltip for accessibility
      ),
    );
  }
}

// Custom Animated Button Widget
class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _AnimatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  __AnimatedButtonState createState() => __AnimatedButtonState();
}

class __AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: ElevatedButton.icon(
        onPressed: () {
          _buttonController.forward().then((_) {
            _buttonController.reverse();
            widget.onPressed();
          });
        },
        icon: Icon(widget.icon, size: 28),
        label: Text(
          widget.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8,
          shadowColor: widget.color,
        ),
      ),
    );
  }
}
