import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/fitness_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/bmi_calculator_screen.dart';
import 'screens/weight_tracker_screen.dart';
import 'screens/goal_management_screen.dart';
import 'screens/analytics_screen.dart';

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
        themeMode: ThemeMode.dark, // Dark Mode Only
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.dark,
            primary: Color(0xFF8B5CF6), // Purple 500
            secondary: Color(0xFF3B82F6), // Blue 500
            background: const Color(0xFF0F172A),
            surface: Color(0xFF1E293B), // Slate 800 (Cards)
            onBackground: Colors.white,
            onSurface: Colors.white,
            error: Color(0xFFEF4444), // Soft Red
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Colors.white60,
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/bmi_calc': (context) => const BmiCalculatorScreen(),
          '/weight_tracker': (context) => const WeightTrackerScreen(),
          '/goal_mgmt': (context) => const GoalManagementScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
        },
      ),
    );
  }
}
