import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, this.onAddWeight});

  final VoidCallback? onAddWeight;

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);
    final entries = fitness.weightEntries;
    final currentWeight = fitness.currentWeight;
    final latestBmi = fitness.latestBmi;
    final latestCategory = fitness.bmiRecords.isNotEmpty
        ? fitness.bmiRecords.first.category
        : 'Normal';
    final progress = fitness.goalProgressPercentage / 100;
    final difference = fitness.lostOrGained;
    final diffText = difference == 0
        ? 'Balanced'
        : difference > 0
            ? '+${difference.toStringAsFixed(1)} kg'
            : '${difference.toStringAsFixed(1)} kg';

    Color bmiColor = const Color(0xFF10B981);
    if (latestCategory == 'Underweight') {
      bmiColor = Colors.amber;
    } else if (latestCategory == 'Overweight' || latestCategory == 'Obese') {
      bmiColor = Colors.orange;
    }

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today’s Focus',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                              letterSpacing: 1.4)),
                      const SizedBox(height: 4),
                      const Text('FitForge',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${_greeting()}, ${fitness.userProfile.name}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.65))),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Text('${fitness.trackingStreak}d',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 12))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Goal progress',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 12,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text('${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('$diffText vs your starting point',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white)),
                      ],
                    ),
                  ),
                  ProgressRing(
                      value: progress,
                      size: 92,
                      accent: Colors.white,
                      icon: Icons.insights_rounded,
                      label: 'On track'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle(
                title: 'Quick stats', subtitle: 'A glance at your momentum'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                    label: 'Current weight',
                    value: '${currentWeight.toStringAsFixed(1)} kg',
                    subtitle: 'Live log',
                    icon: Icons.monitor_weight_rounded,
                    accent: const Color(0xFF7C3AED)),
                StatCard(
                    label: 'Goal weight',
                    value: '${fitness.goalWeight.toStringAsFixed(1)} kg',
                    subtitle:
                        '${(currentWeight - fitness.goalWeight).abs().toStringAsFixed(1)} kg left',
                    icon: Icons.track_changes_rounded,
                    accent: const Color(0xFF2563EB)),
                StatCard(
                    label: 'BMI',
                    value: latestBmi.toStringAsFixed(1),
                    subtitle: latestCategory,
                    icon: Icons.calculate_rounded,
                    accent: bmiColor),
                StatCard(
                    label: 'Logs',
                    value: '${entries.length}',
                    subtitle: 'Entries saved',
                    icon: Icons.history_rounded,
                    accent: const Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weight This Week',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  if (entries.length < 2)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: [
                            Icon(Icons.show_chart_rounded,
                                size: 38, color: Colors.white24),
                            const SizedBox(height: 10),
                            const Text(
                                'No weight history yet.\nStart logging your journey.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white70, height: 1.4)),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                onAddWeight?.call();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add Weight'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF7C3AED),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 140,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: LineChart(
                          key: ValueKey(entries.length),
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: const LineTouchData(enabled: false),
                            minY: _lowest(entries) - 1,
                            maxY: _highest(entries) + 1,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _buildWeeklySpots(entries),
                                isCurved: true,
                                color: const Color(0xFF7C3AED),
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color:
                                      const Color(0xFF7C3AED).withOpacity(0.16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle(
                title: 'Today’s plan', subtitle: 'Keep the momentum steady'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _actionChip(context, Icons.add_circle_outline_rounded,
                    'Log weight', 'Add a fresh reading'),
                _actionChip(context, Icons.insights_rounded, 'Open insights',
                    'Check your trends'),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.06))),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Color(0xFF7C3AED))),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Motivation',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            _quote(),
                            key: ValueKey(_quote()),
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.62)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.06))),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEE, MMM d').format(DateTime.now()),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(
                            entries.isEmpty
                                ? 'No logs yet. Start a streak.'
                                : 'Latest entry logged on ${DateFormat('MMM d').format(entries.first.date)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.58))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(
      BuildContext context, IconData icon, String title, String subtitle) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$title tapped'))),
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11, color: Colors.white.withOpacity(0.5)))
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour <= 11) {
      return 'Good Morning ☀️';
    }
    if (hour >= 12 && hour <= 16) {
      return 'Keep Pushing 💪';
    }
    if (hour >= 17 && hour <= 20) {
      return 'Good Evening 🌙';
    }
    return 'Finish Strong 🔥';
  }

  String _quote() {
    final quotes = [
      'Small progress is still progress.',
      'Forge yourself every day.',
      'Consistency beats perfection.',
      'Discipline beats motivation.',
      'Strong today. Stronger tomorrow.',
    ];
    final index =
        Random(DateTime.now().millisecondsSinceEpoch).nextInt(quotes.length);
    return quotes[index];
  }

  double _lowest(List<dynamic> entries) {
    return entries.fold<double>(double.infinity,
        (value, entry) => entry.weight < value ? entry.weight : value);
  }

  double _highest(List<dynamic> entries) {
    return entries.fold<double>(
        0, (value, entry) => entry.weight > value ? entry.weight : value);
  }

  List<FlSpot> _buildWeeklySpots(List<dynamic> entries) {
    final sorted = List<dynamic>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final slice =
        sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;
    return [
      for (int i = 0; i < slice.length; i++)
        FlSpot(i.toDouble(), slice[i].weight),
    ];
  }
}
