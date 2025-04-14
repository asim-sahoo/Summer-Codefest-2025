class DailyDigestModel {
  final int screenTime; // in seconds
  final int postsViewed;
  final int interactions; // likes, comments, shares
  final int breathersTaken;
  final DateTime date;
  final Map<String, int> activityDistribution; // categorized activity
  final List<String> insights; // personalized insights based on usage
  final int reflectionStreak; // streak of daily reflections
  final Map<String, dynamic>? todayReflection; // today's reflection if it exists (for backward compatibility)
  final List<Map<String, dynamic>> todayReflections; // all of today's reflections
  final int? timeSpentToday; // time spent in minutes today
  final int? timeLimitMinutes; // screen time limit if set

  DailyDigestModel({
    required this.screenTime,
    required this.postsViewed,
    required this.interactions,
    required this.breathersTaken,
    required this.date,
    required this.activityDistribution,
    required this.insights,
    this.reflectionStreak = 0,
    this.todayReflection,
    this.todayReflections = const [],
    this.timeSpentToday,
    this.timeLimitMinutes,
  });

  factory DailyDigestModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> reflectionsList = [];
    if (json['todayReflections'] != null) {
      reflectionsList = List<Map<String, dynamic>>.from(json['todayReflections']);
    }

    return DailyDigestModel(
      screenTime: json['screenTime'] ?? 0,
      postsViewed: json['postsViewed'] ?? 0,
      interactions: json['interactions'] ?? 0,
      breathersTaken: json['breathersTaken'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      activityDistribution: Map<String, int>.from(json['activityDistribution'] ?? {}),
      insights: List<String>.from(json['insights'] ?? []),
      reflectionStreak: json['reflectionStreak'] ?? 0,
      todayReflection: json['todayReflection'],
      todayReflections: reflectionsList,
      timeSpentToday: json['timeSpentToday'],
      timeLimitMinutes: json['timeLimitMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'screenTime': screenTime,
      'postsViewed': postsViewed,
      'interactions': interactions,
      'breathersTaken': breathersTaken,
      'date': date.toIso8601String(),
      'activityDistribution': activityDistribution,
      'insights': insights,
      'reflectionStreak': reflectionStreak,
      'todayReflection': todayReflection,
      'todayReflections': todayReflections,
      'timeSpentToday': timeSpentToday,
      'timeLimitMinutes': timeLimitMinutes,
    };
  }

  // Helper method to format screen time
  String formatScreenTime() {
    final hours = screenTime ~/ 3600;
    final minutes = (screenTime % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  // Method to check if usage is excessive
  bool isExcessiveUsage() {
    // Define thresholds for excessive usage
    const int excessiveScreenTimeThreshold = 7200; // 2 hours
    const int excessivePostsThreshold = 50;
    const int excessiveInteractionsThreshold = 30;

    return screenTime > excessiveScreenTimeThreshold ||
           postsViewed > excessivePostsThreshold ||
           interactions > excessiveInteractionsThreshold;
  }
}