// filepath: d:\Files\Code\flutter_projects\Social\socialapp\lib\widgets\feedback_digest_card.dart
import 'package:flutter/material.dart';
import '../models/feedback_digest_model.dart';
import '../config/app_theme.dart';

class FeedbackDigestCard extends StatelessWidget {
  final FeedbackDigestModel digest;
  final VoidCallback onRefresh;

  const FeedbackDigestCard({
    super.key,
    required this.digest,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppTheme.backgroundColorDark
        : AppTheme.backgroundColorLight;
    final surfaceColor = isDarkMode
        ? AppTheme.surfaceColorDark
        : Colors.white;
    final textColor = isDarkMode
        ? AppTheme.darkTextColor
        : AppTheme.lightTextColor;
    final accentColor = isDarkMode
        ? AppTheme.accentColor
        : AppTheme.primaryColor;

    return Card(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode
              ? Colors.grey.shade800.withOpacity(0.5)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Daily Feedback Digest',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: textColor.withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: onRefresh,
                  tooltip: 'Refresh digest',
                ),
              ],
            ),
            const SizedBox(height: 20),
            digest.hasActivity
                ? _buildDigestContent(context, textColor, accentColor)
                : _buildEmptyDigest(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDigestContent(BuildContext context, Color textColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Messages section
        for (String message in digest.messages)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getIconForMessage(message),
                  size: 22,
                  color: _getColorForMessage(message, accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (digest.uniqueEngagers > 0) ...[
          const SizedBox(height: 16),
          Text(
            "People who engaged with your content: ${digest.uniqueEngagers}",
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],

        // Explanation text
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "We collect reactions throughout the day and deliver them in this daily digest to help you maintain a healthy relationship with social media.",
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyDigest(Color textColor) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Image.asset(
              'assets/empty_digest.png',
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.inbox_outlined,
                size: 60,
                color: textColor.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No activity recorded yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Share something today to connect with others!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMessage(String message) {
    if (message.toLowerCase().contains('smile')) {
      return Icons.mood;
    } else if (message.toLowerCase().contains('heart') ||
               message.toLowerCase().contains('love')) {
      return Icons.favorite;
    } else if (message.toLowerCase().contains('connect') ||
               message.toLowerCase().contains('resonated')) {
      return Icons.connect_without_contact;
    } else if (message.toLowerCase().contains('comment')) {
      return Icons.chat_bubble_outline_rounded;
    } else if (message.toLowerCase().contains('appreciate')) {
      return Icons.thumb_up_outlined;
    } else {
      return Icons.star_outline_rounded;
    }
  }

  Color _getColorForMessage(String message, Color defaultColor) {
    if (message.toLowerCase().contains('smile')) {
      return Colors.amber;
    } else if (message.toLowerCase().contains('heart') ||
               message.toLowerCase().contains('love')) {
      return Colors.red;
    } else if (message.toLowerCase().contains('connect') ||
               message.toLowerCase().contains('resonated')) {
      return Colors.purple;
    } else if (message.toLowerCase().contains('comment')) {
      return Colors.blue;
    } else if (message.toLowerCase().contains('appreciate')) {
      return Colors.green;
    } else {
      return defaultColor;
    }
  }
}