import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/daily_digest_model.dart';
import '../services/digest_service.dart';
import '../config/app_theme.dart';
import '../widgets/loading_animation.dart';

class DailyDigestScreen extends StatefulWidget {
  const DailyDigestScreen({super.key});

  @override
  State<DailyDigestScreen> createState() => _DailyDigestScreenState();
}

class _DailyDigestScreenState extends State<DailyDigestScreen> with SingleTickerProviderStateMixin {
  final DigestService _digestService = DigestService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  DailyDigestModel? _digest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _loadDigest();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDigest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final digest = await _digestService.getCurrentDigest();

      if (mounted) {
        setState(() {
          _digest = digest;
          _isLoading = false;
        });
        _animationController.forward();

        // Save this digest to history
        await _digestService.saveDigestToHistory(digest);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading digest: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;
    final surfaceColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Daily Digest',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
        ? Center(
            child: LoadingAnimation(
              size: 40,
              primaryColor: primaryColor,
            ),
          )
        : _digest == null
          ? Center(
              child: Text(
                'No digest data available',
                style: TextStyle(color: textColor),
              ),
            )
          : FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Text(
                    'Summary for ${_formatDate(_digest!.date)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Insights
                  _buildInsightsCard(
                    context: context,
                    title: 'Personal Insights',
                    icon: Icons.lightbulb_outline,
                    color: Colors.amber,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                    isDarkMode: isDarkMode,
                    insights: _digest!.insights,
                  ),

                  const SizedBox(height: 24),

                  // End of day reflection prompt
                  _buildReflectionCard(
                    context: context,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                    isDarkMode: isDarkMode,
                    isExcessive: _digest!.isExcessiveUsage(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required bool isDarkMode,
    required DailyDigestModel digest,
  }) {
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  value: digest.formatScreenTime(),
                  label: 'Screen Time',
                  icon: Icons.timer_outlined,
                  textColor: textColor,
                ),
                _buildSummaryItem(
                  value: digest.postsViewed.toString(),
                  label: 'Posts Viewed',
                  icon: Icons.visibility_outlined,
                  textColor: textColor,
                ),
                _buildSummaryItem(
                  value: digest.interactions.toString(),
                  label: 'Interactions',
                  icon: Icons.touch_app_outlined,
                  textColor: textColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSummaryItem(
                  value: digest.breathersTaken.toString(),
                  label: 'Breathers Taken',
                  icon: Icons.self_improvement_rounded,
                  textColor: textColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required bool isDarkMode,
    required DailyDigestModel digest,
  }) {
    // Get activity distribution
    final Map<String, int> distribution = digest.activityDistribution;
    final double totalSeconds = distribution.values.fold(0, (sum, item) => sum + item).toDouble();

    // Colors for different activities
    final List<Color> activityColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];

    // Prepare chart sections
    final List<PieChartSectionData> sections = [];
    int index = 0;

    distribution.forEach((key, value) {
      if (totalSeconds > 0) {
        final double percentage = (value / totalSeconds) * 100;
        sections.add(
          PieChartSectionData(
            color: activityColors[index % activityColors.length],
            value: percentage,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        );
      }
      index++;
    });

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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: totalSeconds > 0
                ? Row(
                    children: [
                      // Pie chart
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: sections,
                          ),
                        ),
                      ),
                      // Legend
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...distribution.entries.map((entry) {
                              final index = distribution.keys.toList().indexOf(entry.key);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildLegendItem(
                                  color: activityColors[index % activityColors.length],
                                  label: entry.key,
                                  textColor: textColor,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'No activity data yet',
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required bool isDarkMode,
    required List<String> insights,
  }) {
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.brightness_1,
                    size: 10,
                    color: textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard({
    required BuildContext context,
    required Color surfaceColor,
    required Color textColor,
    required bool isDarkMode,
    required bool isExcessive,
  }) {
    final Color cardColor = isExcessive
        ? Colors.orange.withOpacity(isDarkMode ? 0.2 : 0.1)
        : Colors.blue.withOpacity(isDarkMode ? 0.2 : 0.1);

    final Color iconColor = isExcessive ? Colors.orange : Colors.blue;

    // Check if there are reflections for today
    final hasReflections = _digest?.todayReflections.isNotEmpty ?? false;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: iconColor.withOpacity(0.3),
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
                Icon(
                  isExcessive ? Icons.psychology : Icons.sentiment_satisfied_alt,
                  color: iconColor,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    hasReflections
                        ? 'Today\'s Reflections'
                        : (isExcessive ? 'Time for a Reflection' : 'Reflection of the Day'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                if (hasReflections)
                  Text(
                    _getReflectionStreakText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Display reflections if there are any
            if (hasReflections)
              ..._buildReflectionsList(textColor, iconColor, isDarkMode)
            else
              Text(
                isExcessive
                    ? 'Your usage seems to be higher than average today. Take a moment to reflect: Did social media enhance your life today or did it distract you from what matters?'
                    : 'Take a moment to reflect on your social media use today. How did it make you feel? Did it add value to your day?',
                style: TextStyle(
                  fontSize: 15,
                  color: textColor.withOpacity(0.8),
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 16),

            // Button to add a new reflection
            OutlinedButton(
              onPressed: () => _showReflectionDialog(context, iconColor, textColor, isDarkMode, null),
              style: OutlinedButton.styleFrom(
                foregroundColor: iconColor,
                side: BorderSide(color: iconColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Add Reflection',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: iconColor,
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

  List<Widget> _buildReflectionsList(Color textColor, Color accentColor, bool isDarkMode) {
    final reflections = _digest!.todayReflections;
    if (reflections.isEmpty) return [];

    return reflections.map((reflection) {
      final timestamp = reflection['timestamp'] as int;
      final content = reflection['content'] as String;
      final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black12 : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    // Edit button
                    IconButton(
                      icon: Icon(Icons.edit, size: 18, color: accentColor),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      splashRadius: 20,
                      onPressed: () => _showReflectionDialog(
                        context,
                        accentColor,
                        textColor,
                        isDarkMode,
                        reflection,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    IconButton(
                      icon: Icon(Icons.delete, size: 18, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      splashRadius: 20,
                      onPressed: () => _showDeleteConfirmationDialog(
                        context,
                        timestamp,
                        textColor,
                        isDarkMode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: textColor.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    int timestamp,
    Color textColor,
    bool isDarkMode,
  ) {
    final backgroundColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Delete Reflection',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this reflection?',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: textColor.withOpacity(0.7)),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete the reflection
              final success = await _digestService.deleteReflection(timestamp);

              if (mounted) {
                Navigator.pop(context);

                if (success) {
                  // Reload the digest to update UI
                  _loadDigest();

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reflection deleted'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                } else {
                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete reflection'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getReflectionStreakText() {
    final streak = _digest?.reflectionStreak ?? 0;
    if (streak <= 1) return '';
    return '🔥 $streak day streak';
  }

  void _showReflectionDialog(BuildContext context, Color accentColor, Color textColor, bool isDarkMode, Map<String, dynamic>? existingReflection) async {
    // Get a random prompt for the reflection
    final String prompt = await _digestService.getRandomReflectionPrompt();

    // Get existing reflection if any
    final String initialReflection = existingReflection?['content'] ?? '';

    final TextEditingController reflectionController = TextEditingController(text: initialReflection);
    final backgroundColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Daily Reflection',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prompt
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prompt,
                        style: TextStyle(
                          color: textColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Text field for reflection
              Expanded(
                child: TextField(
                  controller: reflectionController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(color: textColor),
                  cursorColor: accentColor,
                  decoration: InputDecoration(
                    hintText: 'Write your reflection here...',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: textColor.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: accentColor),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: textColor.withOpacity(0.7)),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final String reflection = reflectionController.text.trim();
              if (reflection.isEmpty) {
                return;
              }

              // Save the reflection
              if (existingReflection != null) {
                await _digestService.editReflection(existingReflection['timestamp'], reflection);
              } else {
                await _digestService.saveReflection(reflection);
              }

              // Reload the digest to update UI
              if (mounted) {
                Navigator.pop(context);
                _loadDigest();

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existingReflection != null ? 'Reflection updated!' : 'Reflection saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String value,
    required String label,
    required IconData icon,
    required Color textColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: textColor.withOpacity(0.7), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}