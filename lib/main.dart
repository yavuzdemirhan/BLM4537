import 'package:flutter/material.dart';
import 'package:moto_tour/screens/welcome_screen.dart';
import 'screens/home_screen.dart';

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
        // KIRMIZI TEMA AYARLARI
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red, 
          primary: Colors.red,
          secondary: Colors.redAccent
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}