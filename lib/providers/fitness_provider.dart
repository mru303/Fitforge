import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry.dart';
import '../models/bmi_record.dart';
import '../models/achievement_badge.dart';

class FitnessProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  List<WeightEntry> _weightEntries = [];
  List<BmiRecord> _bmiRecords = [];
  double _goalWeight = 70.0;
  List<AchievementBadge> _badges = [];

  FitnessProvider() {
    _initBadges();
    _loadFromPrefs();
  }

  bool get isInitialized => _isInitialized;
  List<WeightEntry> get weightEntries => _weightEntries;
  List<BmiRecord> get bmiRecords => _bmiRecords;
  double get goalWeight => _goalWeight;
  List<AchievementBadge> get badges => _badges;

  // Initialize static/unlocked badges
  void _initBadges() {
    _badges = [
      AchievementBadge(
        id: 'badge_first_entry',
        title: 'First Step',
        description: 'Logged your very first weight entry!',
        iconCode: 'first_entry',
      ),
      AchievementBadge(
        id: 'badge_7_day',
        title: 'Consistency Spike',
        description: 'Tracked weight across a 7-day streak.',
        iconCode: 'streak_7',
      ),
      AchievementBadge(
        id: 'badge_30_day',
        title: 'Dedicated Forger',
        description: 'Completed a 30-day weight tracking milestone.',
        iconCode: 'streak_30',
      ),
      AchievementBadge(
        id: 'badge_goal_achieved',
        title: 'Forge Mastered',
        description: 'Successfully reached your goal weight!',
        iconCode: 'goal_hit',
      ),
      AchievementBadge(
        id: 'badge_consistency_champion',
        title: 'Iron Consistency',
        description: 'Maintained 5 or more distinct logs.',
        iconCode: 'champion',
      ),
    ];
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Load Goal Weight
    _goalWeight = _prefs.getDouble('goal_weight') ?? 70.0;

    // Load Weight Entries
    final weightJson = _prefs.getStringList('weight_entries') ?? [];
    _weightEntries = weightJson
        .map((e) => WeightEntry.fromJson(e))
        .toList();
    _weightEntries.sort((a, b) => b.date.compareTo(a.date)); // descending dates

    // Load BMI Records
    final bmiJson = _prefs.getStringList('bmi_records') ?? [];
    _bmiRecords = bmiJson
        .map((e) => BmiRecord.fromJson(e))
        .toList();
    _bmiRecords.sort((a, b) => b.date.compareTo(a.date));

    // Evaluate Achievements
    _checkAndUnlockAchievements();

    _isInitialized = true;
    notifyListeners();
  }

  // Save changes to SharedPreferences
  Future<void> _saveWeightEntries() async {
    final list = _weightEntries.map((e) => e.toJson()).toList();
    await _prefs.setStringList('weight_entries', list);
  }

  Future<void> _saveBmiRecords() async {
    final list = _bmiRecords.map((e) => e.toJson()).toList();
    await _prefs.setStringList('bmi_records', list);
  }

  // Goal Management
  Future<void> setGoalWeight(double weight) async {
    _goalWeight = weight;
    await _prefs.setDouble('goal_weight', weight);
    _checkAndUnlockAchievements();
    notifyListeners();
  }

  // Weight entry CRUD
  Future<void> addWeightEntry(double weight, DateTime date, String notes) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: weight,
      date: date,
      notes: notes,
    );
    _weightEntries.add(entry);
    _weightEntries.sort((a, b) => b.date.compareTo(a.date));
    await _saveWeightEntries();
    _checkAndUnlockAchievements();
    notifyListeners();
  }

  Future<void> updateWeightEntry(String id, double weight, DateTime date, String notes) async {
    final index = _weightEntries.indexWhere((element) => element.id == id);
    if (index != -1) {
      _weightEntries[index] = WeightEntry(
        id: id,
        weight: weight,
        date: date,
        notes: notes,
      );
      _weightEntries.sort((a, b) => b.date.compareTo(a.date));
      await _saveWeightEntries();
      _checkAndUnlockAchievements();
      notifyListeners();
    }
  }

  Future<void> deleteWeightEntry(String id) async {
    _weightEntries.removeWhere((element) => element.id == id);
    await _saveWeightEntries();
    notifyListeners();
  }

  // BMI Record CRUD
  Future<void> addBmiRecord(double score, String category, double height, double weight) async {
    final record = BmiRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: score,
      category: category,
      date: DateTime.now(),
      height: height,
      weight: weight,
    );
    _bmiRecords.insert(0, record);
    await _saveBmiRecords();
    notifyListeners();
  }

  // Calorie Calculations
  Map<String, double> calculateCalories({
    required double height,
    required double weight,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    // Harris-Benedict formulation
    double bmr = 0;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    double multiplexer = 1.2; // Sedentary
    switch (activityLevel) {
      case 'Sedentary':
        multiplexer = 1.2;
        break;
      case 'Lightly Active':
        multiplexer = 1.375;
        break;
      case 'Moderately Active':
        multiplexer = 1.55;
        break;
      case 'Very Active':
        multiplexer = 1.725;
        break;
      case 'Athlete':
        multiplexer = 1.9;
        break;
    }

    double maintenance = bmr * multiplexer;
    double loss = maintenance - 500;
    double gain = maintenance + 500;

    return {
      'maintenance': maintenance,
      'loss': loss,
      'gain': gain,
    };
  }

  // Streaks and statistics
  int get trackingStreak {
    if (_weightEntries.isEmpty) return 0;
    
    // Sort ascending for chronological tracking
    final chronList = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get unique dates
    final uniqueDates = chronList
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();

    int streak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    // If no weight entry today or yesterday, streak is broken 
    if (!uniqueDates.contains(today) && !uniqueDates.contains(yesterday)) {
      return 0;
    }

    DateTime checkDate = uniqueDates.contains(today) ? today : yesterday;
    while (uniqueDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  double get lostOrGained {
    if (_weightEntries.length < 2) return 0.0;
    // First vs current
    final chronEntries = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    return chronEntries.last.weight - chronEntries.first.weight;
  }

  double get goalProgressPercentage {
    if (_weightEntries.isEmpty) return 0.0;
    double currentWeight = _weightEntries.first.weight;
    
    // Pick the earliest entry to see initial starting point
    final chronEntries = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    double startWeight = chronEntries.first.weight;

    if ((startWeight - _goalWeight).abs() < 0.1) return 100.0;

    double totalToLoseOrGain = startWeight - _goalWeight;
    double currentProgress = startWeight - currentWeight;

    double percentage = (currentProgress / totalToLoseOrGain) * 100;
    if (percentage < 0) return 0.0;
    if (percentage > 100) return 100.0;
    return percentage;
  }

  void _checkAndUnlockAchievements() {
    bool updated = false;

    for (int i = 0; i < _badges.length; i++) {
      final badge = _badges[i];
      if (badge.isUnlocked) continue;

      bool trigger = false;
      if (badge.id == 'badge_first_entry' && _weightEntries.isNotEmpty) {
        trigger = true;
      } else if (badge.id == 'badge_7_day' && trackingStreak >= 7) {
        trigger = true;
      } else if (badge.id == 'badge_30_day' && trackingStreak >= 30) {
        trigger = true;
      } else if (badge.id == 'badge_consistency_champion' && _weightEntries.length >= 5) {
        trigger = true;
      } else if (badge.id == 'badge_goal_achieved' && _weightEntries.isNotEmpty) {
        double currentWeight = _weightEntries.first.weight;
        // See if starting weight was heavier or lighter than goal
        final chronEntries = List<WeightEntry>.from(_weightEntries)..sort((a, b) => a.date.compareTo(b.date));
        double startWeight = chronEntries.first.weight;
        
        if (startWeight >= _goalWeight) {
          // Weight loss goal
          if (currentWeight <= _goalWeight) trigger = true;
        } else {
          // Weight gain goal
          if (currentWeight >= _goalWeight) trigger = true;
        }
      }

      if (trigger) {
        _badges[i] = badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
        updated = true;
      }
    }

    if (updated) {
      _saveBadgesToPrefs();
    }
  }

  Future<void> _saveBadgesToPrefs() async {
    final unlockedBadges = _badges
        .where((b) => b.isUnlocked)
        .map((b) => b.id)
        .toList();
    await _prefs.setStringList('unlocked_badges', unlockedBadges);
  }
}
