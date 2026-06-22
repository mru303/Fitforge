import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';

class CaloriesTab extends StatefulWidget {
  const CaloriesTab({super.key});

  @override
  State<CaloriesTab> createState() => _CaloriesTabState();
}

class _CaloriesTabState extends State<CaloriesTab> {
  double _heightCm = 175.0;
  double _weightKg = 70.0;
  int _age = 25;
  String _gender = 'Male';
  String _activityLevel = 'Sedentary';

  Map<String, double>? _results;

  final List<String> _activities = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Athlete'
  ];

  @override
  void initState() {
    super.initState();
    _triggerCalculation();
  }

  void _triggerCalculation() {
    final fitness = Provider.of<FitnessProvider>(context, listen: false);
    final calculated = fitness.calculateCalories(
      height: _heightCm,
      weight: _weightKg,
      age: _age,
      gender: _gender,
      activityLevel: _activityLevel,
    );
    setState(() {
      _results = calculated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calorie Intake Guide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Calculate daily energy budgets based on activity and metabolic rates',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.48),
            ),
          ),
          const SizedBox(height: 24),

          // Core details inputs
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DETERMINING PARAMETERS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 0.8),
                ),
                const SizedBox(height: 18),

                // Height Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Height', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
                    Text('${_heightCm.round()} cm', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Slider(
                  value: _heightCm,
                  min: 100,
                  max: 250,
                  activeColor: const Color(0xFF8B5CF6),
                  onChanged: (val) {
                    setState(() {
                      _heightCm = val;
                      _triggerCalculation();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Weight Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weight', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
                    Text('${_weightKg.round()} kg', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Slider(
                  value: _weightKg,
                  min: 30,
                  max: 200,
                  activeColor: const Color(0xFF3B82F6),
                  onChanged: (val) {
                    setState(() {
                      _weightKg = val;
                      _triggerCalculation();
                    });
                  },
                ),

                const SizedBox(height: 12),

                // Age and Gender
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Age', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18, color: Colors.white40),
                                onPressed: () {
                                  if (_age > 1) {
                                    setState(() {
                                      _age--;
                                      _triggerCalculation();
                                    });
                                  }
                                },
                              ),
                              Text('$_age', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18, color: Colors.white40),
                                onPressed: () {
                                  setState(() {
                                    _age++;
                                    _triggerCalculation();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gender', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMiniGenderButton('Male'),
                              const SizedBox(width: 8),
                              _buildMiniGenderButton('Female'),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Activity level selector
                const Text('Daily Activity Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
                const SizedBox(height: 8),
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: _activityLevel,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      items: _activities.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _activityLevel = val;
                            _triggerCalculation();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Calorie outputs
          if (_results != null) ...[
            const Text(
              'Recommended Budgets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            // Bento Grid of budgets
            _buildCalorieResultCard(
              title: 'WEIGHT LOSS',
              description: 'Caloric deficit for targeted weight loss',
              calories: _results!['loss']!,
              themeColor: const Color(0xFF8B5CF6),
              icon: Icons.unfold_less_rounded,
            ),
            const SizedBox(height: 12),
            _buildCalorieResultCard(
              title: 'MAINTENANCE',
              description: 'Calorie equilibrium for weight stability',
              calories: _results!['maintenance']!,
              themeColor: const Color(0xFF3B82F6),
              icon: Icons.balance_rounded,
            ),
            const SizedBox(height: 12),
            _buildCalorieResultCard(
              title: 'WEIGHT GAIN',
              description: 'Caloric surplus for muscle synthesis',
              calories: _results!['gain']!,
              themeColor: const Color(0xFF10B981),
              icon: Icons.unfold_more_rounded,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMiniGenderButton(String gender) {
    bool isSel = _gender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender;
          _triggerCalculation();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF8B5CF6) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          gender,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : Colors.white40,
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieResultCard({
    required String title,
    required String description,
    required double calories,
    required Color themeColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: themeColor, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: themeColor, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${calories.round()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.black,
                  color: Colors.white,
                ),
              ),
              const Text(
                'kcal / day',
                style: TextStyle(fontSize: 10, color: Colors.white40),
              )
            ],
          )
        ],
      ),
    );
  }
}
