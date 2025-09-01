import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/to_do_screen.dart';
import 'screens/counter_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 2 Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Use a more comprehensive theme setup
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5), // Indigo
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFF5C6BC0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      // Set initial route instead of home to ensure proper navigation
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/todo': (context) => const TodoScreen(),
        '/counter': (context) => const CounterScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}