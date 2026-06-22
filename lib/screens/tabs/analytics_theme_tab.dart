import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/fitness_provider.dart';

class AnalyticsThemeTab extends StatelessWidget {
  const AnalyticsThemeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);
    final entries = fitness.weightEntries;
    final bmis = fitness.bmiRecords;

    double currentWeight = entries.isNotEmpty ? entries.first.weight : 75.0;
    double latestBmi = bmis.isNotEmpty ? bmis.first.score : 23.4;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Insights & Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Detailed trend reviews, achievements, and statistics',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.48),
            ),
          ),
          const SizedBox(height: 24),

          // Profile Summary Banner (Screen 9)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROFILE BRIEF',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 0.8),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProfileStat('Current Weight', '${currentWeight.toStringAsFixed(1)} kg'),
                    _buildProfileStat('Goal Weight', '${fitness.goalWeight.toStringAsFixed(1)} kg'),
                    _buildProfileStat('Latest BMI', latestBmi.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Weight Trend Charts (Screen 6)
          const Text(
            'Weight & BMI Trends',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),

          if (entries.isEmpty || entries.length < 2)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart_rounded, size: 40, color: Colors.white24),
                    const SizedBox(height: 10),
                    Text(
                      'Log 2 or more weighings to generate charts',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35)),
                    )
                  ],
                ),
              ),
            )
          else ...[
            // Weight Line Chart
            Container(
              height: 220,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getWeightSpots(entries),
                      isCurved: true,
                      color: const Color(0xFF8B5CF6),
                      barWidth: 3.5,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF8B5CF6).withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chronological Weight Curve (Y-axis: kg, X-axis: entry indices)',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.36)),
            ),
          ],
          const SizedBox(height: 24),

          // Badge Achievement System Page Sector (Unlocked/Locked)
          const Text(
            'Unlocked Achievements',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
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
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: badge.isUnlocked 
                        ? const Color(0xFF10B981).withOpacity(0.2) 
                        : Colors.white.withOpacity(0.04),
                  ),
                ),
                child: Row(
                  children: [
                    // Badge Circle Indicator
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: badge.isUnlocked 
                            ? const Color(0xFF10B981).withOpacity(0.12) 
                            : Colors.white.withOpacity(0.03),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge.isUnlocked ? Icons.verified_rounded : Icons.lock_outline_rounded,
                        color: badge.isUnlocked ? const Color(0xFF10B981) : Colors.white24,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: badge.isUnlocked ? Colors.white : Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            badge.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: badge.isUnlocked ? Colors.white.withOpacity(0.48) : Colors.white.withOpacity(0.18),
                            ),
                          ),
                          if (badge.isUnlocked && badge.unlockedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Forged on ${DateFormat('yyyy-MM-dd').format(badge.unlockedAt!)}',
                              style: const TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                            )
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getWeightSpots(List<dynamic> entries) {
    // Sort oldest to newest for chronological left-to-right graphs
    final chronEntries = List<dynamic>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    List<FlSpot> spots = [];
    for (int i = 0; i < chronEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), chronEntries[i].weight));
    }
    return spots;
  }

  Widget _buildProfileStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.black, color: Colors.white),
        ),
      ],
    );
  }
}
