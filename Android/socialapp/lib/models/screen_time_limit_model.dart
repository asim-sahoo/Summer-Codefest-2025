class ScreenTimeLimit {
  final int minutes;
  final bool enabled;
  final bool showContinuePrompt;

  ScreenTimeLimit({
    required this.minutes,
    required this.enabled,
    required this.showContinuePrompt,
  });

  ScreenTimeLimit.defaultLimit()
      : minutes = 15,
        enabled = true,  // Change default to true so it's enabled by default
        showContinuePrompt = true;

  factory ScreenTimeLimit.fromJson(Map<String, dynamic> json) {
    return ScreenTimeLimit(
      minutes: json['minutes'] ?? 15,
      enabled: json['enabled'] ?? true,  // Default to true if not specified
      showContinuePrompt: json['showContinuePrompt'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minutes': minutes,
      'enabled': enabled,
      'showContinuePrompt': showContinuePrompt,
    };
  }

  ScreenTimeLimit copyWith({
    int? minutes,
    bool? enabled,
    bool? showContinuePrompt,
  }) {
    return ScreenTimeLimit(
      minutes: minutes ?? this.minutes,
      enabled: enabled ?? this.enabled,
      showContinuePrompt: showContinuePrompt ?? this.showContinuePrompt,
    );
  }
}