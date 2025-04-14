import 'package:flutter/material.dart';
import '../models/mood_model.dart';
import '../config/app_theme.dart';
import 'package:intl/intl.dart';

class MoodTrendCard extends StatelessWidget {
  final List<MoodEntry> moodEntries;
  final Function? onViewAllTap;

  const MoodTrendCard({
    super.key,
    required this.moodEntries,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final surfaceColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;

    // If no data available, show empty state
    if (moodEntries.isEmpty) {
      return Card(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mood,
                      color: Colors.purple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mood Trends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.mood_rounded,
                      size: 48,
                      color: textColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No mood data yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check in with your mood after taking a breather',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate mood stats
    final Map<MoodType, int> moodCounts = {
      MoodType.happy: 0,
      MoodType.neutral: 0,
      MoodType.stressed: 0,
    };

    for (var entry in moodEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    final totalEntries = moodEntries.length;
    final List<MoodEntry> recentEntries = moodEntries.length > 5
        ? moodEntries.sublist(0, 5)
        : moodEntries;

    // Get most frequent mood
    MoodType? mostFrequentMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentMood = mood;
      }
    });

    return Card(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mood,
                    color: Colors.purple,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mood Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (onViewAllTap != null)
                  TextButton(
                    onPressed: () => onViewAllTap!(),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Mood distribution
            Row(
              children: [
                _buildMoodStat(
                  context: context,
                  icon: Icons.sentiment_very_satisfied,
                  color: Colors.green,
                  count: moodCounts[MoodType.happy] ?? 0,
                  total: totalEntries,
                  label: 'Happy',
                  textColor: textColor,
                ),
                _buildMoodStat(
                  context: context,
                  icon: Icons.sentiment_neutral,
                  color: Colors.blue,
                  count: moodCounts[MoodType.neutral] ?? 0,
                  total: totalEntries,
                  label: 'Neutral',
                  textColor: textColor,
                ),
                _buildMoodStat(
                  context: context,
                  icon: Icons.sentiment_dissatisfied,
                  color: Colors.orange,
                  count: moodCounts[MoodType.stressed] ?? 0,
                  total: totalEntries,
                  label: 'Stressed',
                  textColor: textColor,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Recent entries
            Text(
              'Recent Check-ins',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            ...recentEntries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(
                    entry.icon,
                    color: entry.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, h:mm a').format(entry.timestamp),
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )),

            if (mostFrequentMood != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Insight based on most frequent mood
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMoodColor(mostFrequentMood!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMoodIcon(mostFrequentMood!),
                      color: _getMoodColor(mostFrequentMood!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getMoodInsight(mostFrequentMood!),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build a single mood stat with percentage
  Widget _buildMoodStat({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required int count,
    required int total,
    required String label,
    required Color textColor,
  }) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Get icon for mood type
  IconData _getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Icons.sentiment_very_satisfied;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.stressed:
        return Icons.sentiment_dissatisfied;
    }
  }

  // Get color for mood type
  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.green;
      case MoodType.neutral:
        return Colors.blue;
      case MoodType.stressed:
        return Colors.orange;
    }
  }

  // Get insight text based on most frequent mood
  String _getMoodInsight(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 'You\'ve been feeling happy most of the time. Keep up the positive energy!';
      case MoodType.neutral:
        return 'You\'ve been feeling balanced most of the time. Good job maintaining equilibrium.';
      case MoodType.stressed:
        return 'You\'ve been feeling stressed most of the time. Try taking more breathers and self-care.';
    }
  }
}