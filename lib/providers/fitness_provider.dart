import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/weight_entry.dart';
import '../models/bmi_record.dart';
import '../models/achievement_badge.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class FitnessProvider extends ChangeNotifier {
  bool _isInitialized = false;

  List<WeightEntry> _weightEntries = [];
  List<BmiRecord> _bmiRecords = [];
  double _goalWeight = 70.0;
  List<AchievementBadge> _badges = [];
  UserProfile _userProfile = UserProfile();

  FitnessProvider() {
    _initBadges();
    _loadFromPrefs();
  }

  bool get isInitialized => _isInitialized;
  List<WeightEntry> get weightEntries => _weightEntries;
  List<BmiRecord> get bmiRecords => _bmiRecords;
  double get goalWeight => _goalWeight;
  List<AchievementBadge> get badges => _badges;
  UserProfile get userProfile => _userProfile;
  double get currentWeight => _weightEntries.isNotEmpty
      ? _weightEntries.first.weight
      : _userProfile.weightKg;
  double get highestWeight => _weightEntries.isEmpty
      ? currentWeight
      : _weightEntries.reduce((a, b) => a.weight > b.weight ? a : b).weight;
  double get lowestWeight => _weightEntries.isEmpty
      ? currentWeight
      : _weightEntries.reduce((a, b) => a.weight < b.weight ? a : b).weight;
  double get averageWeight {
    if (_weightEntries.isEmpty) return currentWeight;
    final total =
        _weightEntries.fold<double>(0, (sum, entry) => sum + entry.weight);
    return total / _weightEntries.length;
  }

  String get weightTrendLabel {
    if (_weightEntries.length < 2) return 'Stable';
    final chronEntries = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final first = chronEntries.first.weight;
    final last = chronEntries.last.weight;
    final delta = last - first;
    if (delta > 0.3) return 'Trending Up';
    if (delta < -0.3) return 'Trending Down';
    return 'Stable';
  }

  double get averageWeeklyChange {
    if (_weightEntries.length < 2) return 0.0;
    final sorted = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first.date;
    final last = sorted.last.date;
    final days = last.difference(first).inDays;
    if (days <= 0) return 0.0;
    final delta = sorted.last.weight - sorted.first.weight;
    return delta / (days / 7);
  }

  double get latestBmi =>
      _bmiRecords.isNotEmpty ? _bmiRecords.first.score : 0.0;

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
    _goalWeight = await StorageService.getGoalWeight();

    final weightJson = await StorageService.getWeightEntries();
    _weightEntries = weightJson.map((e) => WeightEntry.fromJson(e)).toList();
    _weightEntries.sort((a, b) => b.date.compareTo(a.date));

    final bmiJson = await StorageService.getBmiRecords();
    _bmiRecords = bmiJson.map((e) => BmiRecord.fromJson(e)).toList();
    _bmiRecords.sort((a, b) => b.date.compareTo(a.date));

    final profileJson = await StorageService.getUserProfile();
    if (profileJson != null) {
      _userProfile = UserProfile.fromMap(jsonDecode(profileJson));
    }

    final unlocked = await StorageService.getUnlockedBadges();
    if (unlocked.isNotEmpty) {
      for (final badge in _badges) {
        if (unlocked.contains(badge.id)) {
          _badges[_badges.indexOf(badge)] =
              badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
        }
      }
    }

    _checkAndUnlockAchievements();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveWeightEntries() async {
    final list = _weightEntries.map((e) => e.toJson()).toList();
    await StorageService.saveWeightEntries(list);
  }

  Future<void> _saveBmiRecords() async {
    final list = _bmiRecords.map((e) => e.toJson()).toList();
    await StorageService.saveBmiRecords(list);
  }

  Future<void> resetData() async {
    _weightEntries = [];
    _bmiRecords = [];
    _goalWeight = 70.0;
    _userProfile = UserProfile();
    _initBadges();
    await StorageService.saveWeightEntries([]);
    await StorageService.saveBmiRecords([]);
    await StorageService.saveGoalWeight(70.0);
    await StorageService.saveUserProfile(jsonEncode(_userProfile.toMap()));
    await StorageService.saveUnlockedBadges([]);
    notifyListeners();
  }

  Future<void> setGoalWeight(double weight) async {
    _goalWeight = weight;
    await StorageService.saveGoalWeight(weight);
    _checkAndUnlockAchievements();
    notifyListeners();
  }

  Future<void> addWeightEntry(
      double weight, DateTime date, String notes) async {
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

  Future<void> updateWeightEntry(
      String id, double weight, DateTime date, String notes) async {
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

  Future<void> addBmiRecord(
      double score, String category, double height, double weight) async {
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

  Future<void> updateUserProfile(
      {String? name,
      double? heightCm,
      double? weightKg,
      int? age,
      String? gender}) async {
    _userProfile = _userProfile.copyWith(
      name: name,
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      gender: gender,
    );
    await StorageService.saveUserProfile(jsonEncode(_userProfile.toMap()));
    notifyListeners();
  }

  Map<String, double> calculateCalories({
    required double height,
    required double weight,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    double bmr = 0;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    double multiplexer = 1.2;
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

    return {'maintenance': maintenance, 'loss': loss, 'gain': gain};
  }

  int get trackingStreak {
    if (_weightEntries.isEmpty) return 0;

    final chronList = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final uniqueDates = chronList
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();

    int streak = 0;
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

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
    final chronEntries = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    return chronEntries.last.weight - chronEntries.first.weight;
  }

  double get goalProgressPercentage {
    if (_weightEntries.isEmpty) return 0.0;
    final currentWeight = _weightEntries.first.weight;
    final chronEntries = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final startWeight = chronEntries.first.weight;

    if ((startWeight - _goalWeight).abs() < 0.1) return 100.0;

    final totalToLoseOrGain = startWeight - _goalWeight;
    final currentProgress = startWeight - currentWeight;

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
      } else if (badge.id == 'badge_consistency_champion' &&
          _weightEntries.length >= 5) {
        trigger = true;
      } else if (badge.id == 'badge_goal_achieved' &&
          _weightEntries.isNotEmpty) {
        final currentWeight = _weightEntries.first.weight;
        final chronEntries = List<WeightEntry>.from(_weightEntries)
          ..sort((a, b) => a.date.compareTo(b.date));
        final startWeight = chronEntries.first.weight;

        if (startWeight >= _goalWeight) {
          if (currentWeight <= _goalWeight) trigger = true;
        } else {
          if (currentWeight >= _goalWeight) trigger = true;
        }
      }

      if (trigger) {
        _badges[i] =
            badge.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
        updated = true;
      }
    }

    if (updated) {
      _saveBadgesToPrefs();
    }
  }

  Future<void> _saveBadgesToPrefs() async {
    final unlockedBadges =
        _badges.where((b) => b.isUnlocked).map((b) => b.id).toList();
    await StorageService.saveUnlockedBadges(unlockedBadges);
  }
}
