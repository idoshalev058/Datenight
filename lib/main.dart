import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DateNightApp());
}

class DateNightApp extends StatelessWidget {
  const DateNightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ido 🎸 & Shira 🦊 Date Night',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Fredoka',
        scaffoldBackgroundColor: const Color(0xFF0F0D14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9D4EDD),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1A24),
          primary: const Color(0xFF9D4EDD),
          secondary: const Color(0xFFFF6B9D),
        ),
        cardColor: const Color(0xFF1E1A24),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFF5F1F8), fontFamily: 'Fredoka'),
          bodyLarge: TextStyle(color: Color(0xFFF5F1F8), fontFamily: 'Fredoka'),
          headlineSmall: TextStyle(color: Color(0xFFF5F1F8), fontWeight: FontWeight.w700, fontFamily: 'Fredoka'),
          headlineMedium: TextStyle(color: Color(0xFFF5F1F8), fontWeight: FontWeight.w700, fontFamily: 'Fredoka'),
          headlineLarge: TextStyle(color: Color(0xFFF5F1F8), fontWeight: FontWeight.w900, fontFamily: 'Fredoka'),
          titleLarge: TextStyle(color: Color(0xFFF5F1F8), fontWeight: FontWeight.w700, fontFamily: 'Fredoka'),
          labelLarge: TextStyle(color: Color(0xFFF5F1F8), fontWeight: FontWeight.w700, fontFamily: 'Fredoka'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1A24),
          foregroundColor: Color(0xFFFF6B9D),
          elevation: 0,
          titleTextStyle: TextStyle(color: Color(0xFFFF6B9D), fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Fredoka'),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
