import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_digest_model.dart';
import '../services/activity_service.dart';

class DigestService {
  static const String _digestHistoryKey = 'digest_history';
  static const String _lastDigestShownKey = 'last_digest_shown';
  static const int _endOfDayHour = 21; // 9 PM

  final ActivityService _activityService = ActivityService();

  // Get the current day's digest data
  Future<DailyDigestModel> getCurrentDigest() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTime = prefs.getInt('screenTime') ?? 0;
    final postsViewed = prefs.getInt('total_posts_viewed') ?? 0;
    final interactions = prefs.getInt('total_interactions') ?? 0;
    final breathersTaken = prefs.getInt('total_breathers_completed') ?? 0;

    // Create activity distribution map
    final Map<String, int> activityDistribution = {
      'Browsing': (screenTime * 0.6).round(), // 60% of time spent browsing
      'Interactions': (screenTime * 0.3).round(), // 30% of time spent interacting
      'Other': (screenTime * 0.1).round(), // 10% on other activities
    };

    // Generate insights based on usage patterns
    final List<String> insights = _generateInsights(
      screenTime: screenTime,
      postsViewed: postsViewed,
      interactions: interactions,
      breathersTaken: breathersTaken,
    );

    // Get reflection data
    final digestData = await _activityService.getDailyDigestData();
    final reflectionStreak = digestData['reflectionStreak'] ?? 0;
    final timeSpentToday = digestData['timeSpentToday'] ?? 0;
    final timeLimitMinutes = digestData['timeLimitMinutes'];
    final todayReflection = digestData['todayReflection'];
    final todayReflections = digestData['todayReflections'] ?? [];

    return DailyDigestModel(
      screenTime: screenTime,
      postsViewed: postsViewed,
      interactions: interactions,
      breathersTaken: breathersTaken,
      date: DateTime.now(),
      activityDistribution: activityDistribution,
      insights: insights,
      reflectionStreak: reflectionStreak,
      timeSpentToday: timeSpentToday,
      timeLimitMinutes: timeLimitMinutes,
      todayReflection: todayReflection,
      todayReflections: List<Map<String, dynamic>>.from(todayReflections),
    );
  }

  // Save the digest to history
  Future<void> saveDigestToHistory(DailyDigestModel digest) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing history
    final List<String> historyJson = prefs.getStringList(_digestHistoryKey) ?? [];

    // Convert digest to JSON and add to history
    final digestJson = jsonEncode(digest.toJson());
    historyJson.add(digestJson);

    // Save updated history
    await prefs.setStringList(_digestHistoryKey, historyJson);

    // Update last shown timestamp
    await prefs.setInt(_lastDigestShownKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get digest history
  Future<List<DailyDigestModel>> getDigestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_digestHistoryKey) ?? [];

    // Convert JSON strings to digest models
    return historyJson.map((json) {
      final Map<String, dynamic> digestMap = jsonDecode(json);
      return DailyDigestModel.fromJson(digestMap);
    }).toList();
  }

  // Check if it's time to show the end-of-day digest
  Future<bool> shouldShowDigest() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // Get the timestamp when digest was last shown
    final lastShown = prefs.getInt(_lastDigestShownKey) ?? 0;
    final lastShownDate = DateTime.fromMillisecondsSinceEpoch(lastShown);

    // Check if it's after 9 PM (end of day) and we haven't shown a digest today
    return now.hour >= _endOfDayHour &&
           (lastShownDate.day != now.day ||
            lastShownDate.month != now.month ||
            lastShownDate.year != now.year);
  }

  // Generate personalized insights based on usage patterns
  List<String> _generateInsights({
    required int screenTime,
    required int postsViewed,
    required int interactions,
    required int breathersTaken,
  }) {
    final List<String> insights = [];

    // Screen time insights
    if (screenTime > 7200) { // More than 2 hours
      insights.add('You spent over 2 hours on the app today. Consider setting a timer for your social media use.');
    } else if (screenTime < 1800) { // Less than 30 minutes
      insights.add('Great job keeping your screen time under 30 minutes today!');
    }

    // Posts and interactions insights
    if (postsViewed > 50) {
      insights.add('You viewed $postsViewed posts today. Try to be more mindful of what content you consume.');
    }

    if (interactions > 30) {
      insights.add('You had $interactions interactions today. Quality over quantity matters in social engagement.');
    } else if (interactions < 5 && postsViewed > 20) {
      insights.add('You viewed many posts but interacted with few. Try to engage more meaningfully with content you enjoy.');
    }

    // Breathers insights
    if (breathersTaken > 0) {
      insights.add('You completed $breathersTaken breathers today. Great job taking breaks!');
    } else if (screenTime > 3600) { // More than 1 hour
      insights.add('Consider taking breathing breaks during your scrolling sessions to reduce stress.');
    }

    // Add a default insight if none were generated
    if (insights.isEmpty) {
      insights.add('You had a balanced social media usage today. Keep it up!');
    }

    return insights;
  }

  // Reset daily metrics (call this at midnight)
  Future<void> resetDailyMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('screenTime', 0);
  }

  // Reflection methods - delegating to ActivityService

  Future<String> getRandomReflectionPrompt() async {
    return await _activityService.getRandomReflectionPrompt();
  }

  Future<void> saveReflection(String content) async {
    await _activityService.saveReflection(content);
  }

  Future<List<Map<String, dynamic>>> getReflections() async {
    return await _activityService.getReflections();
  }

  Future<void> setReflectionReminder(bool enabled) async {
    await _activityService.setReflectionReminder(enabled);
  }

  Future<bool> getReflectionReminderEnabled() async {
    return await _activityService.getReflectionReminderEnabled();
  }

  Future<void> setPreferredReflectionTime(int hour) async {
    await _activityService.setPreferredReflectionTime(hour);
  }

  Future<int> getPreferredReflectionTime() async {
    return await _activityService.getPreferredReflectionTime();
  }

  // New methods for multiple reflections

  Future<List<Map<String, dynamic>>> getTodayReflections() async {
    final date = DateTime.now();
    return await _activityService.getReflectionsForDate(date);
  }

  Future<bool> deleteReflection(int timestamp) async {
    return await _activityService.deleteReflection(timestamp);
  }

  Future<bool> editReflection(int timestamp, String newContent) async {
    return await _activityService.editReflection(timestamp, newContent);
  }

  Future<List<Map<String, dynamic>>> getReflectionsForDate(DateTime date) async {
    return await _activityService.getReflectionsForDate(date);
  }
}