import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/screen_time_limit_model.dart';

class ActivityService {
  // Constants for the service
  static const int _defaultPostThreshold = 5;
  static const int _defaultMinBreatherIntervalSeconds = 50; // Seconds (20 minutes)
  static const int _defaultTimeThresholdSeconds = 10; // Seconds (15 minutes)
  static const String _lastBreatherCompletedKey = 'last_breather_completed'; // New key to track completions

  // Key names for preferences
  static const String _lastBreatherShownKey = 'last_breather_shown';
  static const String _postsViewedSinceBreatherKey = 'posts_viewed_since_breather';
  static const String _totalPostsViewedKey = 'total_posts_viewed';
  static const String _totalInteractionsKey = 'total_interactions';
  static const String _sessionStartTimeKey = 'session_start_time';
  static const String _totalBreathersCompletedKey = 'total_breathers_completed';
  static const String _preferredBreatherPatternKey = 'preferred_breather_pattern';
  static const String _preferredBreatherThemeKey = 'preferred_breather_theme';
  static const String _preferredBreatherDurationKey = 'preferred_breather_duration';
  static const String _shouldShowMoodCheckInKey = 'should_show_mood_check_in'; // New key for mood check-in
  static const String _screenTimeLimitKey = 'screen_time_limit'; // New key for screen time limit
  static const String _lastContinuePromptTimeKey = 'last_continue_prompt_time'; // Track when last prompt was shown
  static const String _feedSessionStartTimeKey = 'feed_session_start_time'; // Track feed session start time

  // Daily reflection keys
  static const String _lastReflectionTimeKey = 'last_reflection_time';
  static const String _shouldShowReflectionKey = 'should_show_reflection';
  static const String _totalReflectionsCompletedKey = 'total_reflections_completed';
  static const String _reflectionContentKey = 'reflection_content';
  static const String _reflectionReminderEnabledKey = 'reflection_reminder_enabled';
  static const String _preferredReflectionTimeKey = 'preferred_reflection_time';
  static const String _reflectionStreakKey = 'reflection_streak';

  // New breather customization options
  static const List<String> breatherPatterns = [
    'Box Breathing (4-4-4-4)',
    '4-7-8 Breathing',
    'Equal Breathing (5-5)',
    'Deep Calm (6-3-6-3)',
    'Relaxing Breath (2-1-4-1)'
  ];

  static const List<String> breatherThemes = [
    'Calm Blue',
    'Forest Green',
    'Sunset Orange',
    'Lavender Purple',
    'Ocean Teal'
  ];

  static const List<int> breatherDurations = [30, 60, 90, 120, 180]; // in seconds

  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    // If this is a new session, reset the session start time
    if (prefs.getInt(_sessionStartTimeKey) == null ||
        _isNewSession(prefs.getInt(_sessionStartTimeKey) ?? 0)) {
      await prefs.setInt(_sessionStartTimeKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_postsViewedSinceBreatherKey, 0);
    }
  }

  bool _isNewSession(int lastSessionTime) {
    // If more than 4 hours have passed, consider it a new session
    return DateTime.now().millisecondsSinceEpoch - lastSessionTime > 4 * 60 * 60 * 1000;
  }

  Future<void> incrementScreenTime(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = prefs.getInt('screenTime') ?? 0;
    prefs.setInt('screenTime', currentTime + duration.inSeconds);
  }

  Future<void> incrementPostsViewed() async {
    final prefs = await SharedPreferences.getInstance();

    // Initialize session if needed
    await initSession();

    // Increment post counts
    int currentPostsViewed = prefs.getInt(_postsViewedSinceBreatherKey) ?? 0;
    int totalPostsViewed = prefs.getInt(_totalPostsViewedKey) ?? 0;

    await prefs.setInt(_postsViewedSinceBreatherKey, currentPostsViewed + 1);
    await prefs.setInt(_totalPostsViewedKey, totalPostsViewed + 1);
  }

  Future<void> incrementInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    int totalInteractions = prefs.getInt(_totalInteractionsKey) ?? 0;
    await prefs.setInt(_totalInteractionsKey, totalInteractions + 1);
  }

  Future<Map<String, dynamic>> getActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'screenTime': prefs.getInt('screenTime') ?? 0,
      'totalPostsViewed': prefs.getInt(_totalPostsViewedKey) ?? 0,
      'totalInteractions': prefs.getInt(_totalInteractionsKey) ?? 0,
      'totalBreathersCompleted': prefs.getInt(_totalBreathersCompletedKey) ?? 0,
    };
  }

  Future<void> resetActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('screenTime');
    await prefs.remove(_totalPostsViewedKey);
    await prefs.remove(_totalInteractionsKey);
  }

  Future<bool> shouldShowBreather() async {
    final prefs = await SharedPreferences.getInstance();

    // Initialize session if needed
    await initSession();

    final lastBreatherShown = prefs.getInt(_lastBreatherShownKey) ?? 0;
    final lastBreatherCompleted = prefs.getInt(_lastBreatherCompletedKey) ?? 0;
    final postsViewedSinceBreather = prefs.getInt(_postsViewedSinceBreatherKey) ?? 0;

    // Current time in milliseconds
    final now = DateTime.now().millisecondsSinceEpoch;

    // Time since last breather in seconds
    final secondsSinceLastBreather = (now - lastBreatherShown) / 1000;

    // Time since last breather completion in seconds
    final secondsSinceLastCompletion = (now - lastBreatherCompleted) / 1000;

    // Never show a breather shortly after completing one
    if (secondsSinceLastCompletion < _defaultMinBreatherIntervalSeconds) {
      return false;
    }

    // Check if minimum interval has passed since last shown
    if (secondsSinceLastBreather < _defaultMinBreatherIntervalSeconds) {
      return false;
    }

    // Check if user has viewed enough posts
    if (postsViewedSinceBreather >= _defaultPostThreshold) {
      return true;
    }

    // Check if enough time has passed since last breather
    if (secondsSinceLastBreather >= _defaultTimeThresholdSeconds) {
      return true;
    }

    return false;
  }

  Future<void> recordBreatherShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBreatherShownKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_postsViewedSinceBreatherKey, 0);
  }

  Future<void> recordBreatherCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    // Record the completion time
    await prefs.setInt(_lastBreatherCompletedKey, DateTime.now().millisecondsSinceEpoch);

    // Update total breathers completed count
    int totalCompleted = prefs.getInt(_totalBreathersCompletedKey) ?? 0;
    await prefs.setInt(_totalBreathersCompletedKey, totalCompleted + 1);

    // Set flag to show mood check-in
    await setShowMoodCheckIn(true);
  }

  // New methods for mood check-in
  Future<bool> shouldShowMoodCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shouldShowMoodCheckInKey) ?? false;
  }

  Future<void> setShowMoodCheckIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shouldShowMoodCheckInKey, value);
  }

  // Get breather statistics
  Future<Map<String, dynamic>> getBreatherStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalBreathersCompleted': prefs.getInt(_totalBreathersCompletedKey) ?? 0,
      'totalPostsViewed': prefs.getInt(_totalPostsViewedKey) ?? 0,
      'totalInteractions': prefs.getInt(_totalInteractionsKey) ?? 0,
    };
  }

  // Methods for breather preferences
  Future<String> getPreferredBreatherPattern() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredBreatherPatternKey) ?? breatherPatterns[0];
  }

  Future<void> setPreferredBreatherPattern(String pattern) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredBreatherPatternKey, pattern);
  }

  Future<String> getPreferredBreatherTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_preferredBreatherThemeKey) ?? breatherThemes[0];
  }

  Future<void> setPreferredBreatherTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredBreatherThemeKey, theme);
  }

  Future<int> getPreferredBreatherDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_preferredBreatherDurationKey) ?? breatherDurations[1]; // Default 60s
  }

  Future<void> setPreferredBreatherDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_preferredBreatherDurationKey, duration);
  }

  // Feed time limit methods
  Future<ScreenTimeLimit> getScreenTimeLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_screenTimeLimitKey);

    if (jsonString == null) {
      return ScreenTimeLimit.defaultLimit();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return ScreenTimeLimit.fromJson(json);
    } catch (e) {
      // If there's an error parsing, return default
      return ScreenTimeLimit.defaultLimit();
    }
  }

  Future<void> saveScreenTimeLimit(ScreenTimeLimit limit) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(limit.toJson());
    await prefs.setString(_screenTimeLimitKey, jsonString);
  }

  Future<void> startFeedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_feedSessionStartTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> shouldShowContinuePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final screenTimeLimit = await getScreenTimeLimit();

    // If the feature is disabled, don't show prompt
    if (!screenTimeLimit.enabled) {
      return false;
    }

    final feedSessionStartTime = prefs.getInt(_feedSessionStartTimeKey) ?? DateTime.now().millisecondsSinceEpoch;
    final lastPromptTime = prefs.getInt(_lastContinuePromptTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Calculate time spent on feed in minutes
    final timeSpentInFeedInMinutes = (now - feedSessionStartTime) / (1000 * 60);

    // Check if the time limit is exceeded
    if (timeSpentInFeedInMinutes >= screenTimeLimit.minutes) {
      // Check if sufficient time has passed since last prompt (at least 5 minutes)
      final minutesSinceLastPrompt = (now - lastPromptTime) / (1000 * 60);
      if (minutesSinceLastPrompt >= 5 || lastPromptTime == 0) {
        return true;
      }
    }

    return false;
  }

  Future<void> recordContinuePromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastContinuePromptTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Reset feed session
  Future<void> resetFeedSession() async {
    await startFeedSession();
  }

  // Get time spent on feed in the current session
  Future<int> getTimeSpentOnFeedInMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final feedSessionStartTime = prefs.getInt(_feedSessionStartTimeKey) ?? DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now().millisecondsSinceEpoch;

    return ((now - feedSessionStartTime) / (1000 * 60)).round();
  }

  // Daily reflection methods
  Future<bool> shouldShowDailyReflection() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReflectionTime = prefs.getInt(_lastReflectionTimeKey) ?? 0;
    final reflectionReminderEnabled = prefs.getBool(_reflectionReminderEnabledKey) ?? true;

    if (!reflectionReminderEnabled) {
      return false;
    }

    final now = DateTime.now();
    final lastReflection = DateTime.fromMillisecondsSinceEpoch(lastReflectionTime);

    // Check if it's a new day since last reflection
    final isNewDay = now.day != lastReflection.day ||
                     now.month != lastReflection.month ||
                     now.year != lastReflection.year;

    // Use preferred time if set, otherwise default to evening (8 PM)
    final preferredHour = prefs.getInt(_preferredReflectionTimeKey) ?? 20;

    // Only show after preferred hour
    final isAfterPreferredTime = now.hour >= preferredHour;

    return (isNewDay && isAfterPreferredTime) || lastReflectionTime == 0;
  }

  Future<void> setReflectionReminder(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reflectionReminderEnabledKey, enabled);
  }

  Future<bool> getReflectionReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reflectionReminderEnabledKey) ?? true;
  }

  Future<void> setPreferredReflectionTime(int hour) async {
    if (hour < 0 || hour > 23) {
      throw ArgumentError('Hour must be between 0 and 23');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_preferredReflectionTimeKey, hour);
  }

  Future<int> getPreferredReflectionTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_preferredReflectionTimeKey) ?? 20; // Default to 8 PM
  }

  Future<void> saveReflection(String content) async {
    if (content.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Save the reflection with timestamp
    final reflectionEntry = {
      'timestamp': now,
      'content': content,
    };

    // Get existing reflections
    List<Map<String, dynamic>> reflections = await getReflections();
    reflections.add(reflectionEntry);

    // Save updated list
    await prefs.setString(_reflectionContentKey, jsonEncode(reflections));

    // Update last reflection time
    await prefs.setInt(_lastReflectionTimeKey, now);

    // Increment total reflections completed
    int totalCompleted = prefs.getInt(_totalReflectionsCompletedKey) ?? 0;
    await prefs.setInt(_totalReflectionsCompletedKey, totalCompleted + 1);

    // Update streak
    await _updateReflectionStreak();
  }

  Future<List<Map<String, dynamic>>> getReflections() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_reflectionContentKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.cast<Map<String, dynamic>>();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  Future<int> getReflectionStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reflectionStreakKey) ?? 0;
  }

  Future<void> _updateReflectionStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReflectionTime = prefs.getInt(_lastReflectionTimeKey) ?? 0;

    if (lastReflectionTime == 0) {
      // First reflection, start streak at 1
      await prefs.setInt(_reflectionStreakKey, 1);
      return;
    }

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastReflection = DateTime.fromMillisecondsSinceEpoch(lastReflectionTime);
    final lastReflectionDate = DateTime(lastReflection.year, lastReflection.month, lastReflection.day);

    // Check if last reflection was yesterday
    if (lastReflectionDate.isAtSameMomentAs(yesterday)) {
      // Continue streak
      int currentStreak = prefs.getInt(_reflectionStreakKey) ?? 0;
      await prefs.setInt(_reflectionStreakKey, currentStreak + 1);
    } else if (lastReflectionDate.isBefore(yesterday)) {
      // Streak broken, reset to 1
      await prefs.setInt(_reflectionStreakKey, 1);
    }
    // If last reflection was today, streak stays the same
  }

  // Get a random reflection prompt
  Future<String> getRandomReflectionPrompt() async {
    final List<String> prompts = [
      'What was the most meaningful interaction you had today?',
      'Did you learn something new from your feed today?',
      'How did your social media use make you feel today?',
      'What content inspired you the most today?',
      'Did you notice any habits in how you used the app today?',
      'How does your app usage today compare to what you intended?',
      'Whats one thing you would like to change about how you used social media today?',
      'Did you discover any new interests through your social media today?',
      'What distracted you the most from being present today?',
      'How did taking breathers affect your experience today?'
    ];

    // Select a random prompt
    final random = DateTime.now().millisecondsSinceEpoch % prompts.length;
    return prompts[random];
  }

  // Get daily digest data
  Future<Map<String, dynamic>> getDailyDigestData() async {
    final activityData = await getActivityData();
    final screenTimeLimit = await getScreenTimeLimit();
    final timeSpent = await getTimeSpentOnFeedInMinutes();
    final reflectionStreak = await getReflectionStreak();
    final reflections = await getReflections();

    // Get today's reflections
    List<Map<String, dynamic>> todayReflections = [];
    if (reflections.isNotEmpty) {
      final now = DateTime.now();
      for (final reflection in reflections.reversed) {
        final reflectionTime = DateTime.fromMillisecondsSinceEpoch(reflection['timestamp']);
        if (reflectionTime.day == now.day &&
            reflectionTime.month == now.month &&
            reflectionTime.year == now.year) {
          todayReflections.add(reflection);
        }
      }
    }

    return {
      ...activityData,
      'reflectionStreak': reflectionStreak,
      'timeSpentToday': timeSpent,
      'timeLimitMinutes': screenTimeLimit.enabled ? screenTimeLimit.minutes : null,
      'todayReflections': todayReflections,
      'todayReflection': todayReflections.isNotEmpty ? todayReflections.first : null, // For backward compatibility
    };
  }

  // Delete a reflection by its timestamp
  Future<bool> deleteReflection(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> reflections = await getReflections();

    // Find the index of the reflection with the given timestamp
    final index = reflections.indexWhere((reflection) => reflection['timestamp'] == timestamp);

    if (index == -1) {
      return false; // Reflection not found
    }

    // Remove the reflection
    reflections.removeAt(index);

    // Save the updated list
    await prefs.setString(_reflectionContentKey, jsonEncode(reflections));

    // Update last reflection time if needed
    if (reflections.isNotEmpty) {
      // Sort reflections by timestamp in descending order
      reflections.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      await prefs.setInt(_lastReflectionTimeKey, reflections.first['timestamp']);
    } else {
      // No reflections left
      await prefs.setInt(_lastReflectionTimeKey, 0);
    }

    return true;
  }

  // Edit an existing reflection
  Future<bool> editReflection(int timestamp, String newContent) async {
    if (newContent.trim().isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> reflections = await getReflections();

    // Find the index of the reflection with the given timestamp
    final index = reflections.indexWhere((reflection) => reflection['timestamp'] == timestamp);

    if (index == -1) {
      return false; // Reflection not found
    }

    // Update the reflection content
    reflections[index]['content'] = newContent;

    // Save the updated list
    await prefs.setString(_reflectionContentKey, jsonEncode(reflections));

    return true;
  }

  // Get reflections for a specific date
  Future<List<Map<String, dynamic>>> getReflectionsForDate(DateTime date) async {
    List<Map<String, dynamic>> reflections = await getReflections();
    List<Map<String, dynamic>> filteredReflections = [];

    for (final reflection in reflections) {
      final reflectionTime = DateTime.fromMillisecondsSinceEpoch(reflection['timestamp']);
      if (reflectionTime.day == date.day &&
          reflectionTime.month == date.month &&
          reflectionTime.year == date.year) {
        filteredReflections.add(reflection);
      }
    }

    // Sort by timestamp (newest first)
    filteredReflections.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

    return filteredReflections;
  }
}