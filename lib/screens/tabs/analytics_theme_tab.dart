import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class AnalyticsThemeTab extends StatelessWidget {
  const AnalyticsThemeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);
    final entries = fitness.weightEntries;
    final bmis = fitness.bmiRecords;

    final currentWeight = entries.isNotEmpty ? entries.first.weight : 75.0;
    final latestBmi = bmis.isNotEmpty ? bmis.first.score : 23.4;

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
                title: 'Insights & profile',
                subtitle: 'A premium snapshot of your progress'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile brief',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: StatCard(
                              label: 'Current weight',
                              value: '${currentWeight.toStringAsFixed(1)} kg',
                              subtitle: 'Latest log',
                              icon: Icons.monitor_weight_rounded,
                              accent: Colors.white,
                              isCompact: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: StatCard(
                              label: 'Goal weight',
                              value:
                                  '${fitness.goalWeight.toStringAsFixed(1)} kg',
                              subtitle: 'Target',
                              icon: Icons.track_changes_rounded,
                              accent: Colors.white,
                              isCompact: true))
                    ]),
                    const SizedBox(height: 12),
                    StatCard(
                        label: 'Latest BMI',
                        value: latestBmi.toStringAsFixed(1),
                        subtitle: 'Body score',
                        icon: Icons.calculate_rounded,
                        accent: Colors.white,
                        isCompact: true),
                  ]),
            ),
            const SizedBox(height: 22),
            const SectionTitle(
                title: 'Weight trends',
                subtitle: 'Clear visual checkpoints over time'),
            const SizedBox(height: 12),
            if (entries.isEmpty || entries.length < 2)
              Container(
                height: 200,
                decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.06))),
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.show_chart_rounded,
                          size: 40, color: Colors.white24),
                      const SizedBox(height: 10),
                      Text('Log 2 or more weighings to generate charts',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.35)))
                    ])),
              )
            else
              ChartCard(
                  title: 'Weight trend',
                  subtitle: 'Chronological curve from your recent logs',
                  spots: _getWeightSpots(entries),
                  color: const Color(0xFF7C3AED)),
            const SizedBox(height: 22),
            if (entries.isEmpty || entries.length < 2)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.insights_rounded,
                        size: 44, color: Color(0xFF7C3AED)),
                    const SizedBox(height: 12),
                    const Text('Charts will appear after you log weights',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                        'A few weigh-ins unlock rich trend insights and milestone tracking.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.58)),
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
            const SizedBox(height: 22),
            const SectionTitle(
                title: 'Unlocked achievements',
                subtitle: 'Milestones that keep the streak alive'),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fitness.badges.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final badge = fitness.badges[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: badge.isUnlocked
                              ? const Color(0xFF10B981).withOpacity(0.2)
                              : Colors.white.withOpacity(0.06))),
                  child: Row(children: [
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: badge.isUnlocked
                                ? const Color(0xFF10B981).withOpacity(0.12)
                                : Colors.white.withOpacity(0.03),
                            shape: BoxShape.circle),
                        child: Icon(
                            badge.isUnlocked
                                ? Icons.verified_rounded
                                : Icons.lock_outline_rounded,
                            color: badge.isUnlocked
                                ? const Color(0xFF10B981)
                                : Colors.white24,
                            size: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(badge.title,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: badge.isUnlocked
                                      ? Colors.white
                                      : Colors.white38)),
                          const SizedBox(height: 2),
                          Text(badge.description,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: badge.isUnlocked
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.18))),
                          if (badge.isUnlocked && badge.unlockedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                                'Forged on ${DateFormat('yyyy-MM-dd').format(badge.unlockedAt!)}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w700))
                          ]
                        ]))
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getWeightSpots(List<dynamic> entries) {
    final chronEntries = List<dynamic>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    return [
      for (int i = 0; i < chronEntries.length; i++)
        FlSpot(i.toDouble(), chronEntries[i].weight)
    ];
  }
}
