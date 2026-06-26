import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';
import '../widgets/fitforge_logo.dart';
import 'tabs/home_tab.dart';
import 'tabs/weight_tracker_tab.dart';
import 'tabs/bmi_tab.dart';
import 'tabs/calories_tab.dart';
import 'tabs/analytics_theme_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    HomeTab(onAddWeight: _openAddWeightSheet),
    const WeightTrackerTab(),
    const BmiTab(),
    const CaloriesTab(),
    const AnalyticsThemeTab(),
  ];

  static void _openAddWeightSheet() {
    WeightTrackerTab.openAddWeightSheet();
  }

  void _showProfileSheet() {
    final fitness = context.read<FitnessProvider>();
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: FitForgeLogo(size: 54)),
              const SizedBox(height: 18),
              Text(
                fitness.userProfile.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Premium fitness profile',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.56),
                ),
              ),
              const SizedBox(height: 18),
              _profileRow('Current weight', '${fitness.currentWeight.toStringAsFixed(1)} kg'),
              _profileRow('Goal weight', '${fitness.goalWeight.toStringAsFixed(1)} kg'),
              _profileRow('Height', '${fitness.userProfile.heightCm.toStringAsFixed(0)} cm'),
              _profileRow('Theme', 'Matte Black'),
              _profileRow('Units', 'Metric'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await fitness.resetData();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data reset successfully')),
                      );
                    }
                  },
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Reset Data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'App Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.36),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.62)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 14,
        title: const FitForgeLogo(size: 34, showLabel: true),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 15, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Consumer<FitnessProvider>(
                  builder: (context, fitness, _) => Text(
                    '${fitness.trackingStreak}d',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showProfileSheet,
            splashRadius: 22,
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'F',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _openAddWeightSheet();
        },
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Weight'),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFF7C3AED).withOpacity(0.18),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.scale_outlined), selectedIcon: Icon(Icons.scale), label: 'Tracker'),
            NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'BMI'),
            NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department), label: 'Calories'),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Insights'),
          ],
        ),
      ),
    );
  }
}
