import 'package:flutter/material.dart';
import '../models/feedback_digest_model.dart';
import '../config/app_theme.dart';

class EngagementSummaryCard extends StatelessWidget {
  final FeedbackDigestModel digest;
  final VoidCallback onRefresh;
  // final VoidCallback? onTest;

  const EngagementSummaryCard({
    super.key,
    required this.digest,
    required this.onRefresh,
    // this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;

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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Engagement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Summary of how people interact with your content',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: textColor.withOpacity(0.6)),
                  onPressed: onRefresh,
                  tooltip: 'Refresh engagement data',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Engagement metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEngagementMetric(
                  value: digest.likesReceived.toString(),
                  label: 'Likes',
                  icon: Icons.thumb_up_alt_rounded,
                  color: Colors.blue,
                  textColor: textColor,
                ),
                _buildEngagementMetric(
                  value: digest.commentsReceived.toString(),
                  label: 'Comments',
                  icon: Icons.comment_rounded,
                  color: Colors.green,
                  textColor: textColor,
                ),
                _buildEngagementMetric(
                  value: digest.uniqueEngagers.toString(),
                  label: 'Engagers',
                  icon: Icons.people_rounded,
                  color: Colors.orange,
                  textColor: textColor,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Detailed reactions
            Text(
              'Reaction Breakdown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Reaction progress bars
            _buildReactionBar(
              label: 'Likes',
              value: digest.reactionsReceived['like'] ?? 0,
              color: Colors.blue,
              textColor: textColor,
              total: _calculateTotalReactions(digest),
            ),
            const SizedBox(height: 8),
            _buildReactionBar(
              label: 'Hearts',
              value: digest.reactionsReceived['heart'] ?? 0,
              color: Colors.red,
              textColor: textColor,
              total: _calculateTotalReactions(digest),
            ),
            const SizedBox(height: 8),
            _buildReactionBar(
              label: 'Smiles',
              value: digest.reactionsReceived['smile'] ?? 0,
              color: Colors.amber,
              textColor: textColor,
              total: _calculateTotalReactions(digest),
            ),
            const SizedBox(height: 8),
            _buildReactionBar(
              label: 'Fire',
              value: digest.reactionsReceived['fire'] ?? 0,
              color: Colors.deepOrange,
              textColor: textColor,
              total: _calculateTotalReactions(digest),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Live update time
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.update,
                  size: 14,
                  color: textColor.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Last updated: ${_formatDateTime(digest.date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            // Add test button if provided
            // if (onTest != null)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 12.0),
            //     child: SizedBox(
            //       width: double.infinity,
            //       child: ElevatedButton.icon(
            //         onPressed: onTest,
            //         icon: const Icon(Icons.bug_report, size: 18),
            //         label: const Text('Generate Test Data'),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.teal.withOpacity(0.2),
            //           foregroundColor: Colors.teal,
            //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetric({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionBar({
    required String label,
    required int value,
    required Color color,
    required Color textColor,
    required int total,
  }) {
    // Calculate percentage for bar width
    final double percentage = total > 0 ? value / total : 0;
    final double width = percentage * 100;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Background bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Value bar
              Container(
                height: 8,
                width: percentage * 100 <= 0 ? 0 : percentage * 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  int _calculateTotalReactions(FeedbackDigestModel digest) {
    int total = 0;
    digest.reactionsReceived.forEach((key, value) {
      total += value;
    });
    return total > 0 ? total : 1; // Prevent division by zero
  }

  String _formatDateTime(DateTime dateTime) {
    // Format the time as HH:MM AM/PM
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}