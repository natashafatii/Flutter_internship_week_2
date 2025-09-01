import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> with SingleTickerProviderStateMixin {
  int _counter = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _loadCounter();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Load counter from SharedPreferences
  Future<void> _loadCounter() async {
    try {
      final counterValue = await StorageService.loadCounter();
      if (mounted) {
        setState(() {
          _counter = counterValue;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading counter: $e')),
        );
      }
    }
  }

  // Save counter to SharedPreferences
  Future<void> _saveCounter() async {
    await StorageService.saveCounter(_counter);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveCounter();
  }

  void _decrementCounter() {
    if (_counter > 0) {
      setState(() {
        _counter--;
      });
      _saveCounter();
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
    _saveCounter();
  }

  void _showResetConfirmation() {
    if (_counter == 0) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Counter?'),
          content: const Text('Are you sure you want to reset the counter to zero?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _resetCounter();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Counter reset to zero')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5), // Indigo
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
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
        title: const Text(
          'Elegant Counter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5), // Indigo to match other screens
        foregroundColor: Colors.white, // This ensures icons and text are white
        actions: [
          if (_counter > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _showResetConfirmation,
              tooltip: 'Reset Counter',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EAF6), Color(0xFFFFFFFF)], // Indigo gradient to match
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Current Count:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1A237E), // Dark Indigo to match
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Counter Display
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Text(
                            '$_counter',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: _counter == 0
                                  ? Colors.grey[600]
                                  : const Color(0xFF303F9F), // Darker Indigo
                              shadows: _counter > 0 ? [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: const Color(0x4D3F51B5), // Using hex with alpha instead of withOpacity
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Counter Statistics
                    if (_counter > 0)
                      Column(
                        children: [
                          Text(
                            _counter == 1 ? '1 tap so far' : '$_counter taps so far',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1A237E), // Dark Indigo
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Decrement Button
                        ElevatedButton(
                          onPressed: _decrementCounter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF44336), // Red (kept for clarity)
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 24.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                          child: const Icon(Icons.remove, size: 28),
                        ),

                        // Increment Button
                        ElevatedButton(
                          onPressed: _incrementCounter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5), // Indigo to match
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 24.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                          child: const Icon(Icons.add, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Reset Button
                    if (_counter > 0)
                      TextButton(
                        onPressed: _showResetConfirmation,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1A237E), // Dark Indigo
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Reset Counter',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                    // Persistent Storage Info
                    const SizedBox(height: 30),
                    const Text(
                      'Your count is automatically saved and will persist between app sessions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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

      // Floating Action Button for quick increment
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        backgroundColor: const Color(0xFF3F51B5), // Indigo to match
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        elevation: 8,
        tooltip: 'Increment Counter',
      ),
    );
  }
}
