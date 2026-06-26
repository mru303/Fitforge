import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/fitness_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitForgeApp());
}

class FitForgeApp extends StatelessWidget {
  const FitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
      ],
      child: MaterialApp(
        title: 'FitForge',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050505),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7C3AED),
            secondary: Color(0xFF2563EB),
            surface: Color(0xFF121212),
            surfaceContainerHighest: Color(0xFF1B1B1B),
            error: Color(0xFFEF4444),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF121212),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
            titleLarge: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF121212),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
        home: const SplashScreen(),
        routes: {'/dashboard': (context) => const DashboardScreen()},
      ),
    );
  }
}
