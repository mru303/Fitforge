import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class BmiTab extends StatefulWidget {
  const BmiTab({super.key});

  @override
  State<BmiTab> createState() => _BmiTabState();
}

class _BmiTabState extends State<BmiTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double _heightCm = 175.0;
  double _weightKg = 70.0;
  int _age = 25;
  String _gender = 'Male';

  double? _bmiValue;
  String _bmiCategory = '';
  String _idealRange = '';
  List<String> _recommendations = [];

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
    final bmi = _weightKg / ((_heightCm / 100) * (_heightCm / 100));
    String category;
    List<String> recs = [];
    final minIdeal = 18.5 * (_heightCm / 100) * (_heightCm / 100);
    final maxIdeal = 24.9 * (_heightCm / 100) * (_heightCm / 100);

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
      _idealRange =
          '${minIdeal.toStringAsFixed(1)} - ${maxIdeal.toStringAsFixed(1)} kg';
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
            backgroundColor: Color(0xFF10B981)),
      );
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);

    var filteredRecords = fitness.bmiRecords.where((rec) {
      final matchesSearch =
          DateFormat('yyyy-MM-dd').format(rec.date).contains(_searchQuery) ||
              rec.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              rec.score.toStringAsFixed(1).contains(_searchQuery);
      final matchesFilter =
          _categoryFilter == 'All' || rec.category == _categoryFilter;
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

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFF121212),
                border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF7C3AED),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              tabs: const [
                Tab(
                    icon: Icon(Icons.calculate_outlined),
                    text: 'BMI Calculator'),
                Tab(
                    icon: Icon(Icons.history_toggle_off_rounded),
                    text: 'Saved Records'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalculatorView(),
                _buildHistoryView(filteredRecords),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: 'BMI calculator',
              subtitle: 'Understand your body range and next steps'),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGenderButton('Male', Icons.male, const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              _buildGenderButton(
                  'Female', Icons.female, const Color(0xFFEC4899)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.06))),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
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
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF7C3AED),
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      thumbColor: const Color(0xFF7C3AED),
                      overlayColor: const Color(0xFF7C3AED).withOpacity(0.12)),
                  child: Column(
                    children: [
                      Slider(
                          value: _heightCm,
                          min: 100,
                          max: 250,
                          onChanged: (val) => setState(() {
                                _heightCm = val;
                                _calculateBmi();
                              })),
                      Slider(
                          value: _weightKg,
                          min: 30,
                          max: 200,
                          onChanged: (val) => setState(() {
                                _weightKg = val;
                                _calculateBmi();
                              })),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: StatCard(
                      label: 'Age',
                      value: '$_age yrs',
                      subtitle: 'Life stage',
                      icon: Icons.cake_rounded,
                      accent: const Color(0xFF2563EB))),
              const SizedBox(width: 12),
              Expanded(
                  child: StatCard(
                      label: 'Range',
                      value: _idealRange.isEmpty ? '—' : _idealRange,
                      subtitle: 'Ideal target',
                      icon: Icons.monitor_weight_rounded,
                      accent: const Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 20),
          if (_bmiValue == null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.insights_rounded, color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('No BMI result yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Adjust your height and weight to unlock a fresh BMI insight.', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFF7C3AED),
                    const Color(0xFF2563EB)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calculated BMI',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Text(_bmiValue!.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(_bmiCategory.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: Text('Ideal target weight',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7)))),
                      Text(_idealRange,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveBmi,
                      icon: const Icon(Icons.bookmark_border_rounded),
                      label: const Text('Save to BMI history'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          const SectionTitle(
              title: 'Recommendations',
              subtitle: 'Small habits that help your range'),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recommendations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.06))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.16),
                            borderRadius: BorderRadius.circular(999)),
                        child: const Icon(Icons.auto_awesome_rounded,
                            size: 14, color: Color(0xFF7C3AED))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_recommendations[index],
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.72)))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon, Color color) {
    final isSelected = _gender == gender;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _gender = gender;
            _calculateBmi();
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withOpacity(0.18) : const Color(0xFF121212),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected
                    ? color.withOpacity(0.5)
                    : Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.white54, size: 28),
              const SizedBox(height: 6),
              Text(gender,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryView(List<dynamic> records) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search score, category, date...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white30),
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(14)),
                        child: DropdownButton<String>(
                          value: _categoryFilter,
                          dropdownColor: const Color(0xFF121212),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          items: <String>[
                            'All',
                            'Underweight',
                            'Normal',
                            'Overweight',
                            'Obese'
                          ]
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text('Type: $value')))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _categoryFilter = val ?? 'All'),
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
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(14)),
                        child: DropdownButton<String>(
                          value: _sortOrder,
                          dropdownColor: const Color(0xFF121212),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          items: <String>[
                            'Newest',
                            'Oldest',
                            'Highest',
                            'Lowest'
                          ]
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text('Sort: $value')))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _sortOrder = val ?? 'Newest'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.history_edu_rounded,
                          size: 40, color: Colors.white12),
                      const SizedBox(height: 12),
                      Text('No matching calculations found',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.35)))
                    ]))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: records.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
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
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.06))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text(rec.score.toStringAsFixed(1),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white)),
                                    const SizedBox(width: 10),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            color:
                                                categoryColor.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(rec.category,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: categoryColor,
                                                fontWeight: FontWeight.bold)))
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Inputs: ${rec.height.round()} cm, ${rec.weight.round()} kg',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Colors.white.withOpacity(0.35))),
                                ]),
                          ),
                          Text(DateFormat('yyyy-MM-dd').format(rec.date),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.25))),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
