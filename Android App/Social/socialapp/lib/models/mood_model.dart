import 'package:flutter/material.dart';

enum MoodType {
  happy,
  neutral,
  stressed,
}

class MoodEntry {
  final DateTime timestamp;
  final MoodType mood;
  final String? note;

  MoodEntry({
    required this.timestamp,
    required this.mood,
    this.note,
  });

  // Convert to Map for storage
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'mood': mood.toString().split('.').last,
      'note': note,
    };
  }

  // Create from Map for retrieval
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      timestamp: DateTime.parse(json['timestamp']),
      mood: MoodType.values.firstWhere(
        (e) => e.toString().split('.').last == json['mood'],
        orElse: () => MoodType.neutral,
      ),
      note: json['note'],
    );
  }

  // Helper to get mood icon
  IconData get icon {
    switch (mood) {
      case MoodType.happy:
        return Icons.sentiment_very_satisfied;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.stressed:
        return Icons.sentiment_dissatisfied;
    }
  }

  // Helper to get mood color
  Color get color {
    switch (mood) {
      case MoodType.happy:
        return Colors.green;
      case MoodType.neutral:
        return Colors.blue;
      case MoodType.stressed:
        return Colors.orange;
    }
  }

  // Helper to get mood name
  String get name {
    switch (mood) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.stressed:
        return 'Stressed';
    }
  }
}