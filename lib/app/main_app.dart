import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/alarm_provider.dart';
import 'screens/home_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AlarmProvider(),
      child: MaterialApp(
        title: 'Puzukkeni',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2), // Playful blue
            secondary: const Color(0xFFFFB547), // Warm orange
            tertiary: const Color(0xFF66BB6A), // Success green
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFB547),
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              letterSpacing: 0.1,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
