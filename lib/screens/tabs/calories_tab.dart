import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

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
        activityLevel: _activityLevel);
    setState(() => _results = calculated);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
                title: 'Calorie guide',
                subtitle: 'Plan your daily energy without losing momentum'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.06))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Body metrics',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: StatCard(
                              label: 'Height',
                              value: '${_heightCm.round()} cm',
                              subtitle: 'Current height',
                              icon: Icons.straighten_rounded,
                              accent: const Color(0xFF7C3AED))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: StatCard(
                              label: 'Weight',
                              value: '${_weightKg.round()} kg',
                              subtitle: 'Current bodyweight',
                              icon: Icons.monitor_weight_rounded,
                              accent: const Color(0xFF2563EB))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Age',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (_age > 1) {
                                        setState(() {
                                          _age--;
                                          _triggerCalculation();
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.remove,
                                        color: Colors.white60)),
                                Text('$_age',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _age++;
                                        _triggerCalculation();
                                      });
                                    },
                                    icon: const Icon(Icons.add,
                                        color: Colors.white60)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gender',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70)),
                            const SizedBox(height: 8),
                            Row(children: [
                              _buildMiniGenderButton('Male'),
                              const SizedBox(width: 8),
                              _buildMiniGenderButton('Female'),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Daily activity',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70)),
                  const SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          borderRadius: BorderRadius.circular(14)),
                      child: DropdownButton<String>(
                          value: _activityLevel,
                          dropdownColor: const Color(0xFF121212),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                          items: _activities
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text(value)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _activityLevel = val;
                                _triggerCalculation();
                              });
                            }
                          }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Height',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text('${_heightCm.round()} cm',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Slider(
                            value: _heightCm,
                            min: 100,
                            max: 250,
                            activeColor: const Color(0xFF7C3AED),
                            onChanged: (val) {
                              setState(() {
                                _heightCm = val;
                                _triggerCalculation();
                              });
                            })
                      ]),
                  const SizedBox(height: 8),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weight',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text('${_weightKg.round()} kg',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Slider(
                            value: _weightKg,
                            min: 30,
                            max: 200,
                            activeColor: const Color(0xFF2563EB),
                            onChanged: (val) {
                              setState(() {
                                _weightKg = val;
                                _triggerCalculation();
                              });
                            })
                      ]),
                ],
              ),
            ),
            const SizedBox(height: 22),
            if (_results == null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 44, color: Color(0xFF7C3AED)),
                    const SizedBox(height: 12),
                    const Text('Calculate your calorie budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Fine-tune your body metrics to see a tailored energy plan.', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.58)), textAlign: TextAlign.center),
                  ],
                ),
              )
            else ...[
              const SectionTitle(
                  title: 'Recommended budgets',
                  subtitle: 'Choose the plan that fits your goal'),
              const SizedBox(height: 12),
              _buildCalorieResultCard(
                  title: 'WEIGHT LOSS',
                  description: 'Caloric deficit for targeted weight loss',
                  calories: _results!['loss']!,
                  themeColor: const Color(0xFF7C3AED),
                  icon: Icons.unfold_less_rounded),
              const SizedBox(height: 12),
              _buildCalorieResultCard(
                  title: 'MAINTENANCE',
                  description: 'Calorie equilibrium for weight stability',
                  calories: _results!['maintenance']!,
                  themeColor: const Color(0xFF2563EB),
                  icon: Icons.balance_rounded),
              const SizedBox(height: 12),
              _buildCalorieResultCard(
                  title: 'WEIGHT GAIN',
                  description: 'Caloric surplus for muscle synthesis',
                  calories: _results!['gain']!,
                  themeColor: const Color(0xFF10B981),
                  icon: Icons.unfold_more_rounded),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniGenderButton(String gender) {
    final isSelected = _gender == gender;
    return InkWell(
      onTap: () {
        setState(() {
          _gender = gender;
          _triggerCalculation();
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF7C3AED).withOpacity(0.18)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(999)),
        child: Text(gender,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.white54)),
      ),
    );
  }

  Widget _buildCalorieResultCard(
      {required String title,
      required String description,
      required double calories,
      required Color themeColor,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: themeColor)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(
                        fontSize: 12, color: Colors.white.withOpacity(0.56)))
              ])),
          Text('${calories.round()} kcal',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: themeColor)),
        ],
      ),
    );
  }
}
