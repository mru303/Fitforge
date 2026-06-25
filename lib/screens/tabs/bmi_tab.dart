import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fitness_provider.dart';

class BmiTab extends StatefulWidget {
  const BmiTab({super.key});

  @override
  State<BmiTab> createState() => _BmiTabState();
}

class _BmiTabState extends State<BmiTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calculator states
  double _heightCm = 175.0;
  double _weightKg = 70.0;
  int _age = 25;
  String _gender = 'Male';

  // Calculator outputs
  double? _bmiValue;
  String _bmiCategory = '';
  String _idealRange = '';
  List<String> _recommendations = [];

  // History search/filter states
  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _sortOrder = 'Newest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateBmi();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateBmi() {
    double bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    String category;
    List<String> recs = [];
    double minIdeal = 18.5 * (_heightCm / 100) * (_heightCm / 100);
    double maxIdeal = 24.9 * (_heightCm / 100) * (_heightCm / 100);

    if (bmi < 18.5) {
      category = 'Underweight';
      recs = [
        'Prioritize progressive weight training to build lean muscle mass.',
        'Focus on energy-dense, nutrient-rich foods (nuts, whole grains, healthy fats).',
        'Consider eating smaller, more frequent meals throughout the day.'
      ];
    } else if (bmi < 25) {
      category = 'Normal';
      recs = [
        'Outstanding! Maintain your current caloric equilibrium and active routine.',
        'Adopt a combination of resistance lifting and cardiovascular workouts.',
        'Maintain a balanced diet rich in leafy greens, protein, and dietary fibers.'
      ];
    } else if (bmi < 30) {
      category = 'Overweight';
      recs = [
        'Attempt a moderate energy deficit (~300-500 kcal below maintenance).',
        'Add at least 150 minutes of high-intensity aerobic exercise per week.',
        'Increase protein consumption to preserve muscle while losing fat.'
      ];
    } else {
      category = 'Obese';
      recs = [
        'We recommend consulting a clinician or physical trainer before intensive training.',
        'Work steadily on standard steps, low-impact cardio, and portion control.',
        'Integrate strength training to maintain base metabolic rate.'
      ];
    }

    setState(() {
      _bmiValue = bmi;
      _bmiCategory = category;
      _idealRange = '${minIdeal.toStringAsFixed(1)} - ${maxIdeal.toStringAsFixed(1)} kg';
      _recommendations = recs;
    });
  }

  void _saveBmi() {
    if (_bmiValue != null) {
      final fitness = Provider.of<FitnessProvider>(context, listen: false);
      fitness.addBmiRecord(_bmiValue!, _bmiCategory, _heightCm, _weightKg);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BMI calculation saved to history!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      _tabController.animateTo(1); // switch to history view
    }
  }

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);

    // Apply filtering and sorting on history records
    var filteredRecords = fitness.bmiRecords.where((rec) {
      final matchesSearch = DateFormat('yyyy-MM-dd')
          .format(rec.date)
          .contains(_searchQuery) ||
          rec.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rec.score.toStringAsFixed(1).contains(_searchQuery);

      final matchesFilter = _categoryFilter == 'All' || rec.category == _categoryFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    if (_sortOrder == 'Newest') {
      filteredRecords.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortOrder == 'Oldest') {
      filteredRecords.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortOrder == 'Highest') {
      filteredRecords.sort((a, b) => b.score.compareTo(a.score));
    } else if (_sortOrder == 'Lowest') {
      filteredRecords.sort((a, b) => a.score.compareTo(b.score));
    }

    return Column(
      children: [
        // Tab Headers
        Container(
          color: const Color(0xFF0F172A),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF8B5CF6),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.4),
            tabs: const [
              Tab(icon: Icon(Icons.calculate_outlined), text: 'BMI Calculator'),
              Tab(icon: Icon(Icons.history_toggle_off_rounded), text: 'Saved Records'),
            ],
          ),
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Calculator
              _buildCalculatorView(),

              // Tab 2: History
              _buildHistoryView(filteredRecords),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCalculatorView() {
    Color gaugeColor;
    switch (_bmiCategory) {
      case 'Underweight':
        gaugeColor = Colors.amber;
        break;
      case 'Normal':
        gaugeColor = const Color(0xFF10B981);
        break;
      case 'Overweight':
        gaugeColor = Colors.orange;
        break;
      default:
        gaugeColor = Colors.red;
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gender Selector
          const Text(
            'Gender Identity',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildGenderButton('Male', Icons.male, const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              _buildGenderButton('Female', Icons.female, const Color(0xFFEC4899)),
            ],
          ),
          const SizedBox(height: 20),

          // Height / Weight sliders
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('HEIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38)),
                      const SizedBox(height: 6),
                      Text('${_heightCm.round()} cm', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Slider(
                        value: _heightCm,
                        min: 100,
                        max: 250,
                        activeColor: const Color(0xFF8B5CF6),
                        onChanged: (val) {
                          setState(() {
                            _heightCm = val;
                            _calculateBmi();
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('WEIGHT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38)),
                      const SizedBox(height: 6),
                      Text('${_weightKg.round()} kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Slider(
                        value: _weightKg,
                        min: 30,
                        max: 200,
                        activeColor: const Color(0xFF3B82F6),
                        onChanged: (val) {
                          setState(() {
                            _weightKg = val;
                            _calculateBmi();
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Age adjustments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AGE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white60),
                      onPressed: () {
                        if (_age > 1) {
                          setState(() {
                            _age--;
                            _calculateBmi();
                          });
                        }
                      },
                    ),
                    Text('$_age yrs', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white60),
                      onPressed: () {
                        setState(() {
                          _age++;
                          _calculateBmi();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Calculation results
          if (_bmiValue != null) ...[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gaugeColor.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  const Text(
                    'CALCULATED BMI SCORE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bmiValue!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: gaugeColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: gaugeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _bmiCategory.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gaugeColor),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Divider(color: Colors.white.withOpacity(0.06)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('IDEAL TARGET WEIGHT', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      Text(_idealRange, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _saveBmi,
                      icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: const Text('Save to BMI History'),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommendations
            const Text(
              'Forge Health Recommendations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, color: Color(0xFF8B5CF6), size: 12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _recommendations[index],
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon, Color color) {
    bool isSelected = _gender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _gender = gender;
            _calculateBmi();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.18) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.04),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.white54, size: 28),
              const SizedBox(height: 6),
              Text(
                gender,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryView(List<dynamic> records) {
    return Column(
      children: [
        // Filter bar elements
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search input
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search score, category, date...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),

              // Filter choices
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _categoryFilter,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: <String>['All', 'Underweight', 'Normal', 'Overweight', 'Obese']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text('Type: $value'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _categoryFilter = val ?? 'All';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _sortOrder,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: <String>['Newest', 'Oldest', 'Highest', 'Lowest']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text('Sort: $value'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _sortOrder = val ?? 'Newest';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List View
        Expanded(
          child: records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_edu_rounded, size: 40, color: Colors.white12),
                      const SizedBox(height: 12),
                      Text(
                        'No matching calculations found',
                        style: TextStyle(color: Colors.white.withOpacity(0.35)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final rec = records[index];
                    Color categoryColor;
                    switch (rec.category) {
                      case 'Underweight':
                        categoryColor = Colors.amber;
                        break;
                      case 'Normal':
                        categoryColor = const Color(0xFF10B981);
                        break;
                      case 'Overweight':
                        categoryColor = Colors.orange;
                        break;
                      default:
                        categoryColor = Colors.red;
                        break;
                    }

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.03)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    rec.score.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight:FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      rec.category,
                                      style: TextStyle(fontSize: 10, color: categoryColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Inputs: ${rec.height.round()} cm, ${rec.weight.round()} kg",
                                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35)),
                              )
                            ],
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd').format(rec.date),
                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.25)),
                          )
                        ],
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }
}
