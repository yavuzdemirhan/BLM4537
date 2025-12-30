import 'package:flutter/material.dart';
import 'package:moto_tour/screens/home_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MotoTourApp());
}

class MotoTourApp extends StatelessWidget {
  const MotoTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoRota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.red,
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),

      home: const WelcomeScreen(), 
    );
  }
}