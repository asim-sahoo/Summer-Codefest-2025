import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../services/digest_service.dart';
import '../services/feedback_digest_service.dart';
import '../services/mood_service.dart'; // Add the mood service
import '../models/feedback_digest_model.dart';
import '../models/mood_model.dart'; // Add the mood model
import '../config/app_theme.dart';
import '../widgets/loading_animation.dart';
import '../widgets/engagement_summary_card.dart';
import '../widgets/end_of_day_summary_dialog.dart';
import '../widgets/mood_trend_card.dart'; // Add the mood trend card
import '../screens/daily_digest_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ActivityService _activityService = ActivityService();
  final DigestService _digestService = DigestService();
  final FeedbackDigestService _feedbackDigestService = FeedbackDigestService();
  final MoodService _moodService = MoodService(); // Add mood service
  Map<String, dynamic> _activityData = {
    'screenTime': 0,
    'totalPostsViewed': 0,
    'totalInteractions': 0,
    'totalBreathersCompleted': 0
  };
  FeedbackDigestModel _feedbackDigest = FeedbackDigestModel.empty();
  List<MoodEntry> _moodEntries = []; // Add mood entries list
  bool _isLoading = true;
  bool _isLoadingFeedback = true;
  bool _isLoadingMoods = true; // Add loading state for moods
  // Add auto-refresh timer
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
    _loadFeedbackDigest();
    _loadMoodEntries(); // Load mood entries

    // Set up auto-refresh for engagement data every 2 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) {
        _loadFeedbackDigest();
        _loadMoodEntries(); // Refresh mood entries
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadActivityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _activityService.getActivityData();
      if (mounted) {
        setState(() {
          _activityData = Map<String, dynamic>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading activity data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFeedbackDigest() async {
    setState(() {
      _isLoadingFeedback = true;
    });

    try {
      // Check if we should fetch a new digest or use the cached one
      final shouldFetch = await _feedbackDigestService.shouldFetchNewDigest();

      if (shouldFetch) {
        // Fetch new digest from server
        final digest = await _feedbackDigestService.getDailyDigest();

        // Save it locally for offline access
        await _feedbackDigestService.saveDigestLocally(digest);

        if (mounted) {
          setState(() {
            _feedbackDigest = digest;
            _isLoadingFeedback = false;
          });
        }
      } else {
        // Get cached digest
        final cachedDigest = await _feedbackDigestService.getLocalDigest();

        if (mounted) {
          setState(() {
            _feedbackDigest = cachedDigest ?? FeedbackDigestModel.empty();
            _isLoadingFeedback = false;
          });
        }
      }
    } catch (e) {
      print('Error loading feedback digest: $e');

      // Try to load from cache if network request failed
      try {
        final cachedDigest = await _feedbackDigestService.getLocalDigest();

        if (mounted) {
          setState(() {
            _feedbackDigest = cachedDigest ?? FeedbackDigestModel.empty();
            _isLoadingFeedback = false;
          });
        }
      } catch (cacheError) {
        if (mounted) {
          setState(() {
            _feedbackDigest = FeedbackDigestModel.empty();
            _isLoadingFeedback = false;
          });
        }
      }
    }
  }

  Future<void> _loadMoodEntries() async {
    setState(() {
      _isLoadingMoods = true;
    });

    try {
      final entries = await _moodService.getMoodsForLastDays(30);
      if (mounted) {
        setState(() {
          // Sort by most recent first
          _moodEntries = entries..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _isLoadingMoods = false;
        });
      }
    } catch (e) {
      print('Error loading mood entries: $e');
      if (mounted) {
        setState(() {
          _isLoadingMoods = false;
        });
      }
    }
  }

  void _showAllMoodEntries() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mood History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _moodEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No mood entries yet',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _moodEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _moodEntries[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: entry.color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              entry.icon,
                              color: entry.color,
                            ),
                          ),
                          title: Text(
                            entry.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            'Recorded on ${_formatDate(entry.timestamp)}',
                            style: TextStyle(
                              color: textColor.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _testEndOfDaySummary() async {
    try {
      setState(() {
        _isLoadingFeedback = true;
      });

      // Generate test engagement data first to ensure we have data to show
      await _feedbackDigestService.generateTestEngagement();

      // Fetch the updated digest with the test data
      final digest = await _feedbackDigestService.getDailyDigest();

      // Show the end-of-day summary dialog with the current digest data
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EndOfDaySummaryDialog(
            digest: digest,
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        );

        setState(() {
          _isLoadingFeedback = false;
          _feedbackDigest = digest;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFeedback = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing end-of-day summary: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatScreenTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
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
      body: _isLoading
        ? Center(
            child: LoadingAnimation(
              size: 40,
              primaryColor: primaryColor,
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              await _loadActivityData();
              await _loadMoodEntries();
              await _loadFeedbackDigest();
            },
            color: primaryColor,
            backgroundColor: surfaceColor,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Feedback Digest Card (new)
                _isLoadingFeedback
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Using our new EngagementSummaryCard
                        EngagementSummaryCard(
                          digest: _feedbackDigest,
                          onRefresh: _loadFeedbackDigest,
                        ),
                        const SizedBox(height: 16),

                        // Mood Trend Card (NEW)
                        _isLoadingMoods
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            )
                          : MoodTrendCard(
                              moodEntries: _moodEntries,
                              onViewAllTap: _showAllMoodEntries,
                            ),

                        const SizedBox(height: 16),

                        // Test button for end-of-day summary
                        ElevatedButton.icon(
                          onPressed: _testEndOfDaySummary,
                          icon: const Icon(Icons.celebration_outlined),
                          label: const Text('Test End-of-Day Summary'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.withOpacity(0.2),
                            foregroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(double.infinity, 36),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Daily engagement messages summary
                        Card(
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
                                        Icons.message_rounded,
                                        color: Colors.purple,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Engagement Highlights',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ..._feedbackDigest.messages.take(3).map((message) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: textColor.withOpacity(0.6),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textColor.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                if (_feedbackDigest.messages.length > 3)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        // Show full message list
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: surfaceColor,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) => Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'All Engagement Messages',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Expanded(
                                                  child: ListView.builder(
                                                    itemCount: _feedbackDigest.messages.length,
                                                    itemBuilder: (context, index) {
                                                      return ListTile(
                                                        leading: Icon(
                                                          Icons.message_outlined,
                                                          color: primaryColor,
                                                        ),
                                                        title: Text(
                                                          _feedbackDigest.messages[index],
                                                          style: TextStyle(color: textColor),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('View all messages'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                const SizedBox(height: 24),

                // Activity metrics grid
                Text(
                  'Usage Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 16),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 8, // Reduced from 16 to 8
                  crossAxisSpacing: 8, // Reduced from 16 to 8
                  childAspectRatio: 1.1,
                  children: [
                    _buildMetricCard(
                      context: context,
                      title: 'Screen Time',
                      value: _formatScreenTime(_activityData['screenTime']!),
                      icon: Icons.timer_rounded,
                      color: Colors.blue,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      isDarkMode: isDarkMode,
                    ),
                    _buildMetricCard(
                      context: context,
                      title: 'Posts Viewed',
                      value: _activityData['totalPostsViewed'].toString(),
                      icon: Icons.visibility_rounded,
                      color: Colors.green,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      isDarkMode: isDarkMode,
                    ),
                    _buildMetricCard(
                      context: context,
                      title: 'Interactions',
                      value: _activityData['totalInteractions'].toString(),
                      icon: Icons.touch_app_rounded,
                      color: Colors.orange,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      isDarkMode: isDarkMode,
                    ),
                    _buildMetricCard(
                      context: context,
                      title: 'Breathers',
                      value: _activityData['totalBreathersCompleted'].toString(),
                      icon: Icons.self_improvement_rounded,
                      color: Colors.purple,
                      surfaceColor: surfaceColor,
                      textColor: textColor,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),

                // Add explicit spacing between grid and chart
                // const SizedBox(height: 8), // Reduced from 24 to 8 to minimize gap

                // Activity Distribution Chart - removing all spacing
                Transform.translate(
                  offset: const Offset(0, -90), // Apply negative vertical offset to move chart up
                  child: _buildChartCard(
                    context: context,
                    title: 'Activity Distribution',
                    icon: Icons.pie_chart_rounded,
                    color: Colors.deepPurple,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                    isDarkMode: isDarkMode,
                    screenTime: _activityData['screenTime']!,
                    postsViewed: _activityData['totalPostsViewed']!,
                    interactions: _activityData['totalInteractions']!,
                  ),
                ),

                // Daily Digest Button
                Transform.translate(
                  offset: const Offset(0, -70),

                child: Card(
                  elevation: 0,
                  color: primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.95,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          builder: (_, controller) => Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: const DailyDigestScreen(),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.insights_rounded,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'View Daily Digest',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: textColor.withOpacity(0.6),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8), // Reduced from 12 to 8
                          Flexible(
                            child: Text(
                              'See a detailed summary of your social media usage and get personalized insights.',
                              style: TextStyle(
                                fontSize: 13, // Reduced from 14
                                color: textColor.withOpacity(0.7),
                                height: 1.3, // Reduced from 1.4
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
                const SizedBox(height: 24),

                // Reset button
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: surfaceColor,
                        title: Text(
                          'Reset Activity Data',
                          style: TextStyle(color: textColor),
                        ),
                        content: Text(
                          'This will reset all your activity data. Are you sure you want to continue?',
                          style: TextStyle(color: textColor.withOpacity(0.8)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: textColor.withOpacity(0.8)),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _activityService.resetActivityData();
                              _loadActivityData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Activity data reset successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Reset Activity Data',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                // Add extra padding to prevent button from being hidden behind the bottom nav bar
                const SizedBox(height: 100),
              ],
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
    required String description,
    required bool isDarkMode,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  value: _formatScreenTime(_activityData['screenTime']!),
                  label: 'Screen Time',
                  icon: Icons.timer_outlined,
                  textColor: textColor,
                ),
                _buildSummaryItem(
                  value: _activityData['totalPostsViewed'].toString(),
                  label: 'Posts Viewed',
                  icon: Icons.visibility_outlined,
                  textColor: textColor,
                ),
                _buildSummaryItem(
                  value: _activityData['totalInteractions'].toString(),
                  label: 'Interactions',
                  icon: Icons.touch_app_outlined,
                  textColor: textColor,
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required bool isDarkMode,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
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
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.6),
              ),
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
    required int screenTime,
    required int postsViewed,
    required int interactions,
  }) {
    // Calculate total activity for percentage distribution
    final double totalActivity = screenTime / 60 + postsViewed + interactions;
    final double screenTimePercent = totalActivity > 0 ? (screenTime / 60) / totalActivity * 100 : 0;
    final double postsPercent = totalActivity > 0 ? postsViewed / totalActivity * 100 : 0;
    final double interactionsPercent = totalActivity > 0 ? interactions / totalActivity * 100 : 0;

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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0), // Reduced from all(20.0) for a more compact layout
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
            const SizedBox(height: 12), // Reduced from 24 to 12 for a more compact layout
            SizedBox(
              height: 180,
              child: totalActivity > 0
                ? Row(
                    children: [
                      // Pie chart
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.blue,
                                value: screenTimePercent,
                                title: '${screenTimePercent.toStringAsFixed(1)}%',
                                radius: 50,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.green,
                                value: postsPercent,
                                title: '${postsPercent.toStringAsFixed(1)}%',
                                radius: 50,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: interactionsPercent,
                                title: '${interactionsPercent.toStringAsFixed(1)}%',
                                radius: 50,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Legend
                      Expanded(
                        flex:2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(
                              color: Colors.blue,
                              label: 'Screen Time',
                              textColor: textColor,
                            ),
                            const SizedBox(height: 16),
                            _buildLegendItem(
                              color: Colors.green,
                              label: 'Posts Viewed',
                              textColor: textColor,
                            ),
                            const SizedBox(height: 16),
                            _buildLegendItem(
                              color: Colors.orange,
                              label: 'Interactions',
                              textColor: textColor,
                            ),
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
}