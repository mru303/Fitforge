import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fitness_provider.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);
    final weightEntries = fitness.weightEntries;
    
    double currentWeight = weightEntries.isNotEmpty ? weightEntries.first.weight : 75.0;
    double latestBmi = fitness.bmiRecords.isNotEmpty ? fitness.bmiRecords.first.score : 23.4;
    String latestBmiCategory = fitness.bmiRecords.isNotEmpty ? fitness.bmiRecords.first.category : 'Normal';
    
    double lastDiff = fitness.lostOrGained;
    String diffText = lastDiff == 0 
        ? "0.0 kg change" 
        : lastDiff > 0 
            ? "+${lastDiff.toStringAsFixed(1)} kg gained" 
            : "${lastDiff.toStringAsFixed(1)} kg lost";

    Color categoryColor;
    switch (latestBmiCategory) {
      case 'Underweight':
        categoryColor = Colors.amber;
        break;
      case 'Normal':
        categoryColor = Colors.emerald;
        break;
      case 'Overweight':
        categoryColor = Colors.orange;
        break;
      default:
        categoryColor = Colors.red;
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.52),
                    ),
                  ),
                  const Text(
                    'Iron Forger',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Streak Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: fitness.trackingStreak > 0 
                        ? const Color(0xFF8B5CF6).withOpacity(0.4) 
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: fitness.trackingStreak > 0 ? const Color(0xFFF59E0B) : Colors.white30,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${fitness.trackingStreak} Days',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: fitness.trackingStreak > 0 ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Overview Statistics Banner Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GOAL COMPLETION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${fitness.goalProgressPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.black,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            lastDiff <= 0 ? Icons.trending_down : Icons.trending_up,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            diffText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Circular progress ring
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: fitness.goalProgressPercentage / 100,
                        strokeWidth: 9,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Icon(
                          Icons.insights_rounded,
                          size: 32,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Health Grid (BMI / Weight / Goal)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.28,
            children: [
              // Weight card
              _buildStatsCard(
                title: 'CURRENT WEIGHT',
                value: '${currentWeight.toStringAsFixed(1)} kg',
                subtitle: weightEntries.isNotEmpty 
                    ? 'Logs: ${weightEntries.length}' 
                    : 'No entries yet',
                icon: Icons.monitor_weight_rounded,
                accentColor: const Color(0xFF8B5CF6),
              ),
              // Goal Weight Card
              _buildStatsCard(
                title: 'GOAL TARGET',
                value: '${fitness.goalWeight.toStringAsFixed(1)} kg',
                subtitle: 'Remaining: ${(currentWeight - fitness.goalWeight).abs().toStringAsFixed(1)} kg',
                icon: Icons.track_changes_rounded,
                accentColor: const Color(0xFF3B82F6),
              ),
              // BMI Card
              _buildStatsCard(
                title: 'CURRENT BMI',
                value: latestBmi.toStringAsFixed(1),
                subtitle: latestBmiCategory,
                icon: Icons.calculate_rounded,
                accentColor: categoryColor,
              ),
              // Tracking Days
              _buildStatsCard(
                title: 'LIFETIME LOGS',
                value: '${weightEntries.length} Items',
                subtitle: 'Active tracking',
                icon: Icons.date_range_rounded,
                accentColor: const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Recent Activity Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                DateFormat('EEE, MMM d').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (weightEntries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.scale_rounded, color: Colors.white24, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Unlock your forge analytics!',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add your first weight entry in the Tracker tab to begin.',
                        style: TextStyle(fontSize: 12, color: Colors.white38),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest weighing recorded',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Logged at ${weightEntries.first.weight} kg on ${DateFormat('MMM dd').format(weightEntries.first.date)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 0.8,
                ),
              ),
              Icon(
                icon,
                color: accentColor.withOpacity(0.8),
                size: 18,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w830,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        ],
      ),
    );
  }
}
