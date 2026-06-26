import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<FlSpot> spots;
  final Color color;
  final bool showArea;

  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.spots,
    required this.color,
    this.showArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                minY: _calculateMinY(),
                maxY: _calculateMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: showArea
                        ? BarAreaData(
                            show: true,
                            color: color.withOpacity(0.12),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMinY() {
    if (spots.isEmpty) return 0;
    final values = spots.map((e) => e.y).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    return (min - 1).floorToDouble();
  }

  double _calculateMaxY() {
    if (spots.isEmpty) return 1;
    final values = spots.map((e) => e.y).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max + 1).ceilToDouble();
  }
}
