import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_model.dart';

class MoodService {
  static const String _moodKey = 'mood_entries';

  // Save a new mood entry
  Future<void> saveMood(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getMoods();

    // Add new entry
    entries.add(entry);

    // Store updated list
    await prefs.setString(_moodKey, jsonEncode(
      entries.map((e) => e.toJson()).toList()
    ));
  }

  // Get all mood entries
  Future<List<MoodEntry>> getMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_moodKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((json) => MoodEntry.fromJson(json))
          .toList();
    } catch (e) {
      print('Error parsing mood entries: $e');
      return [];
    }
  }

  // Get mood entries for a specific date range
  Future<List<MoodEntry>> getMoodsForDateRange(DateTime start, DateTime end) async {
    final allEntries = await getMoods();

    return allEntries.where((entry) {
      return entry.timestamp.isAfter(start) &&
             entry.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get mood entries for the last n days
  Future<List<MoodEntry>> getMoodsForLastDays(int days) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);

    return getMoodsForDateRange(start, now);
  }

  // Clear all mood entries (for testing)
  Future<void> clearMoods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moodKey);
  }
}