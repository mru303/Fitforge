import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _goalWeightKey = 'goal_weight';
  static const String _weightEntriesKey = 'weight_entries';
  static const String _bmiRecordsKey = 'bmi_records';
  static const String _userProfileKey = 'user_profile';
  static const String _unlockedBadgesKey = 'unlocked_badges';

  static Future<SharedPreferences> get prefs async =>
      SharedPreferences.getInstance();

  static Future<double> getGoalWeight() async {
    final store = await prefs;
    return store.getDouble(_goalWeightKey) ?? 70.0;
  }

  static Future<void> saveGoalWeight(double value) async {
    final store = await prefs;
    await store.setDouble(_goalWeightKey, value);
  }

  static Future<List<String>> getWeightEntries() async {
    final store = await prefs;
    return store.getStringList(_weightEntriesKey) ?? <String>[];
  }

  static Future<void> saveWeightEntries(List<String> entries) async {
    final store = await prefs;
    await store.setStringList(_weightEntriesKey, entries);
  }

  static Future<List<String>> getBmiRecords() async {
    final store = await prefs;
    return store.getStringList(_bmiRecordsKey) ?? <String>[];
  }

  static Future<void> saveBmiRecords(List<String> entries) async {
    final store = await prefs;
    await store.setStringList(_bmiRecordsKey, entries);
  }

  static Future<void> saveUserProfile(String profileJson) async {
    final store = await prefs;
    await store.setString(_userProfileKey, profileJson);
  }

  static Future<String?> getUserProfile() async {
    final store = await prefs;
    return store.getString(_userProfileKey);
  }

  static Future<void> saveUnlockedBadges(List<String> badgeIds) async {
    final store = await prefs;
    await store.setStringList(_unlockedBadgesKey, badgeIds);
  }

  static Future<List<String>> getUnlockedBadges() async {
    final store = await prefs;
    return store.getStringList(_unlockedBadgesKey) ?? <String>[];
  }
}
