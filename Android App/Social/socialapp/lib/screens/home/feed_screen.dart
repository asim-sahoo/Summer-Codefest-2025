import 'dart:async';
import 'dart:math'; // Import Random
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:audioplayers/audioplayers.dart'; // Add audioplayers import
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/post_service.dart';
import '../../services/user_service.dart';
import '../../services/mood_service.dart'; // Add mood service
import '../../widgets/post_card.dart';
import '../../services/activity_service.dart';
import '../../config/app_theme.dart';
import '../../widgets/loading_animation.dart';
import '../../models/screen_time_limit_model.dart'; // Add import for ScreenTimeLimit
import '../mood/mood_check_in_screen.dart'; // Add mood check-in screen
import '../screen_time_limit_settings_screen.dart'; // Import settings screen

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final ActivityService _activityService = ActivityService();
  final MoodService _moodService = MoodService(); // Add mood service
  final Set<String> _viewedPostIds = {};
  final ScrollController _scrollController = ScrollController();

  List<Post> _posts = [];
  List<Post> _filteredPosts = []; // To store filtered posts
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Content filter options
  ContentType? _selectedContentFilter; // null means show all posts
  bool _showContentFilterOptions = false;

  // Breather Feature
  bool _showBreatherButton = false;
  Timer? _scrollTimer;
  bool _breatherModalVisible = false;
  Timer? _breatherCheckTimer;

  Timer? _screenTimeTimer;

  // Feed time limit features
  Timer? _feedTimerCheckTimer;
  bool _feedTimeLimitReached = false;
  ScreenTimeLimit? _screenTimeLimit;
  int _timeSpentInFeedMinutes = 0;

  // Track whether we've shown the popup recently to avoid spamming the user
  bool _breatherPopupShown = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
    _scrollController.addListener(_onScroll);

    _startScrollTimer();
    _startBreatherCheck();

    // Initialize session
    _activityService.initSession();

    // Start feed session timer
    _startFeedSession();

    // Start screen time timer
    _startScreenTimeTimer();

    // Check if we should show a mood check-in (from a previously completed breather)
    _checkForMoodPrompt();

    // Load screen time limit settings
    _loadScreenTimeLimit();

    // Start feed timer check
    _startFeedTimerCheck();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollTimer?.cancel();
    _breatherCheckTimer?.cancel();
    _screenTimeTimer?.cancel();
    _feedTimerCheckTimer?.cancel();
    super.dispose();
  }

  // Apply content filter and update the filtered posts list
  void _applyContentFilter() {
    setState(() {
      if (_selectedContentFilter == null) {
        // Show all posts if no filter is selected
        _filteredPosts = List.from(_posts);
      } else {
        // Filter posts based on selected content type
        _filteredPosts = _posts.where((post) =>
          post.contentType == _selectedContentFilter
        ).toList();
      }
    });
  }

  // Start feed session timer
  Future<void> _startFeedSession() async {
    await _activityService.startFeedSession();
    _updateFeedTimeSpent();
  }

  // Load screen time limit settings
  Future<void> _loadScreenTimeLimit() async {
    try {
      final limit = await _activityService.getScreenTimeLimit();
      if (mounted) {
        setState(() {
          _screenTimeLimit = limit;
          print("Screen time limit loaded: ${limit.enabled}, ${limit.minutes} minutes");
        });

        // Restart the feed timer with the new settings
        _startFeedTimerCheck();
      }
    } catch (e) {
      print("Error loading screen time limit: $e");
      // Set a default limit if there's an error
      if (mounted) {
        setState(() {
          _screenTimeLimit = ScreenTimeLimit.defaultLimit();
        });
      }
    }
  }

  // Update time spent on feed
  Future<void> _updateFeedTimeSpent() async {
    final minutes = await _activityService.getTimeSpentOnFeedInMinutes();
    if (mounted) {
      setState(() {
        _timeSpentInFeedMinutes = minutes;
      });
    }
  }

  // Start feed timer check
  void _startFeedTimerCheck() {
    // Cancel any existing timer
    _feedTimerCheckTimer?.cancel();

    // Only start the timer if the feed timer is enabled
    if (_screenTimeLimit?.enabled ?? true) {
      _feedTimerCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        await _updateFeedTimeSpent();

        // Check if we should show the continue prompt
        if (!_feedTimeLimitReached) {
          final shouldShow = await _activityService.shouldShowContinuePrompt();
          if (shouldShow && mounted) {
            setState(() {
              _feedTimeLimitReached = true;
            });
            _showContinuePrompt();
          }
        }
      });
    }
  }

  // Show continue prompt when time limit is reached
  Future<void> _showContinuePrompt() async {
    if (!mounted) return;

    // Record that prompt was shown
    await _activityService.recordContinuePromptShown();

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: backgroundColor,
        title: Row(
          children: [
            Icon(
              Icons.timer_off,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Time Limit Reached',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'ve spent $_timeSpentInFeedMinutes minutes browsing your feed. Taking regular breaks is good for your wellbeing.',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to continue browsing or take a break?',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScreenTimeLimitSettingsScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: const Text('Adjust Settings'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Show breather as an alternative to scrolling more
              _showBreatherDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Take a Break'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _feedTimeLimitReached = false;
              });
              Navigator.of(context).pop();
              // Reset the feed session timer
              _activityService.resetFeedSession();
              _startFeedSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // Check if we should show a mood check-in prompt
  Future<void> _checkForMoodPrompt() async {
    final shouldShow = await _activityService.shouldShowMoodCheckIn();
    if (shouldShow && mounted) {
      // Small delay to let the UI fully load
      await Future.delayed(const Duration(milliseconds: 500));
      _showMoodCheckIn();
    }
  }

  // Show mood check-in screen
  void _showMoodCheckIn() {
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MoodCheckInScreen(
          onComplete: () {
            // Reset the mood check-in flag once completed
            _activityService.setShowMoodCheckIn(false);
          },
        ),
      ),
    );
  }

  // Start timer to periodically check if we should show the breather
  void _startBreatherCheck() {
    // Check every 30 seconds if we should show the breather
    _breatherCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_breatherModalVisible && mounted) {
        final shouldShow = await _activityService.shouldShowBreather();
        if (shouldShow) {
          _showBreatherDialog();
        }
      }
    });
  }

  void _startScrollTimer() {
    _scrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Check if controller is attached before accessing position
      if (_scrollController.hasClients &&
          _scrollController.position.userScrollDirection != ScrollDirection.idle) {
        // Instead of showing the floating button, show a popup after detecting scrolling
        if (!_breatherModalVisible && mounted && !_breatherPopupShown) {
          _maybeShowBreatherPopup();
        }
      }
    });
  }

  // Check if we should show the breather popup
  Future<void> _maybeShowBreatherPopup() async {
    // Only show the popup if the user has scrolled enough
    if (_scrollController.position.pixels > 500) {
      // Add a random chance element to make it less predictable (creates friction)
      // Only show the popup 1/3 of the time the conditions are met
      final randomValue = Random().nextInt(3);
      if (randomValue == 0) {
        setState(() {
          _breatherPopupShown = true;
        });

        // Show the popup
        await _showBreatherPrompt();

        // Reset the flag after a delay to allow showing it again later
        Future.delayed(const Duration(minutes: 5), () {
          if (mounted) {
            setState(() {
              _breatherPopupShown = false;
            });
          }
        });
      }
    }
  }

  void _startScreenTimeTimer() {
    _screenTimeTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _activityService.incrementScreenTime(const Duration(seconds: 10));
    });
  }

  // Show a dialog for breather
  Future<void> _showBreatherDialog() async {
    if (_breatherModalVisible) return;

    setState(() {
      _breatherModalVisible = true;
    });

    await _activityService.recordBreatherShown();

    if (!mounted) return;

    // Get user preferences
    final preferredPattern = await _activityService.getPreferredBreatherPattern();
    final preferredTheme = await _activityService.getPreferredBreatherTheme();
    final preferredDuration = await _activityService.getPreferredBreatherDuration();
    final stats = await _activityService.getBreatherStats();

    if (!mounted) return;

    // Define theme colors based on preference
    Color primaryColor;
    Color secondaryColor;
    Color backgroundColor;

    switch (preferredTheme) {
      case 'Forest Green':
        primaryColor = Colors.green[700]!;
        secondaryColor = Colors.green[300]!;
        backgroundColor = Colors.green[50]!;
        break;
      case 'Sunset Orange':
        primaryColor = Colors.orange[700]!;
        secondaryColor = Colors.orange[300]!;
        backgroundColor = Colors.orange[50]!;
        break;
      case 'Lavender Purple':
        primaryColor = Colors.purple[700]!;
        secondaryColor = Colors.purple[300]!;
        backgroundColor = Colors.purple[50]!;
        break;
      case 'Ocean Teal':
        primaryColor = Colors.teal[700]!;
        secondaryColor = Colors.teal[300]!;
        backgroundColor = Colors.teal[50]!;
        break;
      default: // Calm Blue
        primaryColor = Colors.blue[700]!;
        secondaryColor = Colors.blue[300]!;
        backgroundColor = Colors.blue[50]!;
    }

    // Parse breathing pattern instructions
    List<int> breathingPattern = [4, 4, 4, 4]; // Default box breathing
    String patternInstructions = 'Inhale, Hold, Exhale, Hold';

    if (preferredPattern.contains('4-7-8')) {
      breathingPattern = [4, 7, 8, 0];
      patternInstructions = 'Inhale for 4, Hold for 7, Exhale for 8';
    } else if (preferredPattern.contains('Equal Breathing')) {
      breathingPattern = [5, 0, 5, 0];
      patternInstructions = 'Inhale for 5, Exhale for 5';
    } else if (preferredPattern.contains('Deep Calm')) {
      breathingPattern = [6, 3, 6, 3];
      patternInstructions = 'Inhale for 6, Hold for 3, Exhale for 6, Hold for 3';
    } else if (preferredPattern.contains('Relaxing Breath')) {
      breathingPattern = [2, 1, 4, 1];
      patternInstructions = 'Inhale for 2, Hold for 1, Exhale for 4, Hold for 1';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BreatherDialog(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          backgroundColor: backgroundColor,
          breathingPattern: breathingPattern,
          patternInstructions: patternInstructions,
          preferredDuration: preferredDuration,
          pattern: preferredPattern,
          theme: preferredTheme,
          stats: stats,
          onComplete: () {
            _activityService.recordBreatherCompleted();
            setState(() {
              _breatherModalVisible = false;
              _showBreatherButton = false; // Hide button after completing breather
            });

            // Show mood check-in immediately after breather is completed
            _showMoodCheckIn();
          },
          onChangeSettings: () async {
            // First close current dialog
            Navigator.of(context).pop();

            // Open settings dialog
            await _showBreatherSettingsDialog();

            // Re-open breather dialog with new settings if still appropriate
            if (mounted) {
              setState(() {
                _breatherModalVisible = false;
              });
              _showBreatherDialog();
            }
          },
        );
      },
    );
  }

  // Dialog to customize breather settings
  Future<void> _showBreatherSettingsDialog() async {
    final currentPattern = await _activityService.getPreferredBreatherPattern();
    final currentTheme = await _activityService.getPreferredBreatherTheme();
    final currentDuration = await _activityService.getPreferredBreatherDuration();

    String selectedPattern = currentPattern;
    String selectedTheme = currentTheme;
    int selectedDuration = currentDuration;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize Your Breather'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Breathing Pattern:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedPattern,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedPattern = newValue;
                        });
                      }
                    },
                    items: ActivityService.breatherPatterns
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Theme:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedTheme,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedTheme = newValue;
                        });
                      }
                    },
                    items: ActivityService.breatherThemes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Duration (seconds):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedDuration,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedDuration = newValue;
                        });
                      }
                    },
                    items: ActivityService.breatherDurations
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value seconds'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save user preferences
              await _activityService.setPreferredBreatherPattern(selectedPattern);
              await _activityService.setPreferredBreatherTheme(selectedTheme);
              await _activityService.setPreferredBreatherDuration(selectedDuration);
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show a popup that prompts the user to take a breather (instead of a floating button)
  Future<void> _showBreatherPrompt() async {
    if (!mounted) return;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;

    // Show dialog with deliberate friction: multiple steps/confirmations
    final bool takeBreather = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: backgroundColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement_rounded,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Take a Mindful Break?',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'ve been scrolling for a while. A short breathing break can help refresh your mind.',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to take a brief moment to breathe?',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Add some benefits as bullet points
            ..._buildBulletPoints([
              'Reduces stress and anxiety',
              'Improves focus and attention',
              'Takes only 30-60 seconds',
            ], textColor),
          ],
        ),
        actions: [
          // Deliberate friction design: place "No" first so it's not the default option
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            // Use more descriptive text that requires active decision
            child: const Text('Not right now'),
          ),
          // Secondary confirmation for "No" to increase friction
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              // Show a brief toast or message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No problem. We\'ll remind you later.'),
                  backgroundColor: Colors.grey[700],
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('Maybe later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Take a Break'),
          ),
        ],
      ),
    ) ?? false;

    if (takeBreather && mounted) {
      _showBreatherDialog();
    }
  }

  // Helper method to build bullet points
  List<Widget> _buildBulletPoints(List<String> points, Color textColor) {
    return points.map((point) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              point,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  void _onScroll() {
    // Check if we should show the breather based on scroll activity
    if (!_breatherModalVisible && _scrollController.position.pixels > 500) {
      _activityService.shouldShowBreather().then((shouldShow) {
        if (shouldShow && mounted) {
          _showBreatherDialog();
        }
      });
    }
  }

  Future<void> _loadTimeline() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasError = false;
    });

    try {
      final posts = await _postService.getTimelinePosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _filteredPosts = posts; // Initialize filtered posts with all posts
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load posts: ${e.toString()}';
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<User> _getUserData(String userId) async {
    try {
      // Add debug logging to diagnose the issue
      print('Fetching user data for userId: $userId');
      final user = await _userService.getUserById(userId);
      print('Successfully retrieved user data for userId: $userId');
      return user;
    } catch (e) {
      print('Error fetching user data for userId: $userId - Error: $e');
      throw Exception('Failed to load user data: $e');
    }
  }

  Widget _buildPostItem(Post post) {
    return VisibilityDetector(
      key: Key('post-${post.id}'),
      onVisibilityChanged: (info) {
        var percent = info.visibleFraction * 100;
        if (percent > 50 && !_viewedPostIds.contains(post.id)) {
          _activityService.incrementPostsViewed();
          _viewedPostIds.add(post.id);
        }
      },
      child: FutureBuilder<User>(
        future: _getUserData(post.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 150, child: LoadingAnimation(size: 24));
          }

          // If there's an error, create a minimal user object with the userId
          // This prevents the "Error loading post" message and shows a basic post card instead
          final user = snapshot.hasData ? snapshot.data! : User(
            id: post.userId,
            firstname: "User",
            lastname: "",
            email: "unknown@example.com",
            followers: [],
            following: [],
            profilePicture: "",
            coverPicture: "",
            about: "",
            livesin: "",
            worksAt: "",
            relationship: "",
          );

          return PostCard(
            post: post,
            user: user,
            onLike: () async {
              await _postService.likePost(post.id);
              _activityService.incrementInteractions();
              final updated = await _postService.getPostById(post.id);
              setState(() {
                final i = _posts.indexWhere((p) => p.id == post.id);
                if (i != -1) _posts[i] = updated;

                // Also update the post in filtered posts
                final filteredIndex = _filteredPosts.indexWhere((p) => p.id == post.id);
                if (filteredIndex != -1) _filteredPosts[filteredIndex] = updated;
              });
            },
            onDelete: post.userId == user.id
                ? () async {
                    await _postService.deletePost(post.id);
                    setState(() {
                      _posts.removeWhere((p) => p.id == post.id);
                      _filteredPosts.removeWhere((p) => p.id == post.id);
                    });
                  }
                : null,
          );
        },
      ),
    );
  }

  // Build the content filter chip
  Widget _buildContentFilterChip(ContentType contentType) {
    final bool isSelected = _selectedContentFilter == contentType;

    // Set icon and colors based on content type
    IconData icon;
    Color chipColor;

    switch (contentType) {
      case ContentType.uplifting:
        icon = Icons.sentiment_very_satisfied;
        chipColor = Colors.green;
        break;
      case ContentType.sensitive:
        icon = Icons.sentiment_dissatisfied;
        chipColor = Colors.orange;
        break;
      case ContentType.neutral:
      default:
        icon = Icons.sentiment_neutral;
        chipColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 4),
            Text(contentTypeToString(contentType).capitalize()),
          ],
        ),
        selectedColor: chipColor,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: chipColor.withOpacity(0.5),
        ),
        backgroundColor: chipColor.withOpacity(0.1),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedContentFilter = contentType;
            } else {
              // If unselecting the current filter, set to null (show all)
              _selectedContentFilter = null;
            }
            _applyContentFilter();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;
    final surfaceColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;

    // Default to 15 minutes if screen time limit is not loaded yet
    final int limitMinutes = _screenTimeLimit?.minutes ?? 15;
    final bool isTimerEnabled = _screenTimeLimit?.enabled ?? true;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Always show the timer widget
          Container(
            width: double.infinity,
            color: surfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Feed Timer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isTimerEnabled)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _timeSpentInFeedMinutes >= limitMinutes
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_timeSpentInFeedMinutes/$limitMinutes min',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _timeSpentInFeedMinutes >= limitMinutes
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Disabled',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (isTimerEnabled)
                        LinearProgressIndicator(
                          value: _timeSpentInFeedMinutes / limitMinutes,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeSpentInFeedMinutes >= limitMinutes
                                ? Colors.red
                                : primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        )
                      else
                        LinearProgressIndicator(
                          value: 0,
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  color: textColor.withOpacity(0.7),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ScreenTimeLimitSettingsScreen(),
                      ),
                    ).then((_) {
                      // Reload settings when returning from settings screen
                      _loadScreenTimeLimit();
                    });
                  },
                ),
              ],
            ),
          ),

          // Content filter section
          Container(
            width: double.infinity,
            color: surfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.filter_alt_outlined,
                            color: primaryColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Content Filter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _showContentFilterOptions
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 18
                      ),
                      color: textColor.withOpacity(0.7),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _showContentFilterOptions = !_showContentFilterOptions;
                        });
                      },
                    ),
                  ],
                ),

                // Show filter options if expanded
                if (_showContentFilterOptions) ...[
                  const SizedBox(height: 8),
                  // Replace Row with Wrap widget to handle overflow
                  Wrap(
                    spacing: 8, // Horizontal space between chips
                    runSpacing: 8, // Vertical space between lines
                    children: [
                      // Show all filter chip
                      FilterChip(
                        selected: _selectedContentFilter == null,
                        label: const Text('All Posts'),
                        selectedColor: primaryColor,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: _selectedContentFilter == null ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor: primaryColor.withOpacity(0.1),
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _selectedContentFilter = null;
                              _applyContentFilter();
                            });
                          }
                        },
                      ),

                      // Content type filters
                      _buildContentFilterChip(ContentType.uplifting),
                      _buildContentFilterChip(ContentType.neutral),
                      _buildContentFilterChip(ContentType.sensitive),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),

          // Feed Content
          Expanded(
            child: RefreshIndicator(
              backgroundColor: isDarkMode ? AppTheme.surfaceColorDark : Colors.white,
              color: primaryColor,
              onRefresh: _loadTimeline,
              child: _hasError
                  ? Center(child: Text(_errorMessage))
                  : _filteredPosts.isEmpty && !_isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedContentFilter != null
                                    ? Icons.filter_alt_off
                                    : Icons.feed_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedContentFilter != null
                                    ? "No ${contentTypeToString(_selectedContentFilter!)} posts found"
                                    : "Your feed is empty.",
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              if (_selectedContentFilter != null) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedContentFilter = null;
                                      _applyContentFilter();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Show All Posts'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          key: const Key('feedList'),
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 120), // Increased bottom padding
                          itemCount: _filteredPosts.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredPosts.length && _isLoading) {
                              return const Center(child: Padding(
                                padding: EdgeInsets.all(24),
                                child: LoadingAnimation(size: 32, primaryColor: Colors.blue),
                              ));
                            }

                            final post = _filteredPosts[index];
                            return _buildPostItem(post);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class BreatherDialog extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final List<int> breathingPattern;
  final String patternInstructions;
  final int preferredDuration;
  final String pattern;
  final String theme;
  final Map<String, dynamic> stats;
  final VoidCallback onComplete;
  final VoidCallback onChangeSettings;

  const BreatherDialog({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.breathingPattern,
    required this.patternInstructions,
    required this.preferredDuration,
    required this.pattern,
    required this.theme,
    required this.stats,
    required this.onComplete,
    required this.onChangeSettings,
  });

  @override
  _BreatherDialogState createState() => _BreatherDialogState();
}

class _BreatherDialogState extends State<BreatherDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentStep = 0;
  String _currentInstruction = "Get Ready";
  int _remainingTime = 0;
  Timer? _timer;
  int _cyclesCompleted = 0;
  bool _showStats = false;

  // Add AudioPlayer instance
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.preferredDuration;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.breathingPattern[0]),
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start breathing cycle after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startBreathingCycle();
      }
    });

    // Set up the countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            widget.onComplete();
          }
        });
      }
    });

    // Play audio when the dialog appears
    _playAudio();
  }

  // Method to play audio
  Future<void> _playAudio() async {
    try {
      await _audioPlayer.play(AssetSource('audio.mp3'));
      setState(() {
        _isAudioPlaying = true;
      });

      // Set looping for continuous playback throughout the breathing exercise
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // Method to stop audio
  Future<void> _stopAudio() async {
    if (_isAudioPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

  void _startBreathingCycle() {
    if (!mounted) return;

    // Reset controller
    _controller.reset();

    // Set current step instruction
    setState(() {
      switch (_currentStep) {
        case 0:
          _currentInstruction = "Inhale";
          _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
            ),
          );
          break;
        case 1:
          _currentInstruction = "Hold";
          _animation = Tween<double>(begin: 1.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.linear,
            ),
          );
          break;
        case 2:
          _currentInstruction = "Exhale";
          _animation = Tween<double>(begin: 1.0, end: 0.5).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
            ),
          );
          break;
        case 3:
          _currentInstruction = "Hold";
          _animation = Tween<double>(begin: 0.5, end: 0.5).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.linear,
            ),
          );
          break;
      }
    });

    // Set animation duration
    int duration = widget.breathingPattern[_currentStep];
    if (duration <= 0) {
      // Skip steps with 0 duration (like patterns without holds)
      _moveToNextStep();
      return;
    }

    _controller.duration = Duration(seconds: duration);

    // Start animation
    _controller.forward().then((_) {
      _moveToNextStep();
    });
  }

  void _moveToNextStep() {
    if (!mounted) return;

    setState(() {
      _currentStep = (_currentStep + 1) % 4;
      if (_currentStep == 0) {
        _cyclesCompleted++;
      }
    });

    _startBreathingCycle();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _stopAudio(); // Stop audio when the dialog is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: _showStats ? _buildStatsView() : _buildBreathingView(),
      ),
    );
  }

  Widget _buildBreathingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Fix the overflow by using Expanded to constrain the text
            Expanded(
              child: Text(
                "Pattern: ${widget.pattern}",
                style: TextStyle(
                  color: widget.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Add overflow handling
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.settings, color: widget.primaryColor),
                  onPressed: widget.onChangeSettings,
                  tooltip: "Change Settings",
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40), // Smaller constraints
                ),
                IconButton(
                  icon: Icon(Icons.bar_chart, color: widget.primaryColor),
                  onPressed: () {
                    setState(() {
                      _showStats = true;
                    });
                  },
                  tooltip: "View Statistics",
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40), // Smaller constraints
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _currentInstruction,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: widget.primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.patternInstructions,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: widget.primaryColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 30),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: widget.primaryColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 180 * _animation.value,
                  height: 180 * _animation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.secondaryColor.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Text(
                      "$_cyclesCompleted",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        Text(
          "Time Remaining: $_remainingTime seconds",
          style: TextStyle(
            fontSize: 16,
            color: widget.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Stop audio playback
            _stopAudio();

            // Cancel any active timers before completing
            _timer?.cancel();
            _controller.stop();

            // Close the dialog first
            Navigator.of(context).pop();

            // Then call the completion handler after a brief delay
            // This gives the dialog time to properly dismiss
            Future.delayed(const Duration(milliseconds: 100), () {
              // This calls recordBreatherCompleted() in the parent widget
              widget.onComplete();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Done"),
        ),
      ],
    );
  }

  Widget _buildStatsView() {
    final int totalBreathers = widget.stats['totalBreathers'] ?? 0;
    final int totalBreatherMinutes = widget.stats['totalBreatherMinutes'] ?? 0;
    final int longestStreak = widget.stats['longestStreak'] ?? 0;
    final int currentStreak = widget.stats['currentStreak'] ?? 0;
    final String mostUsedPattern = widget.stats['mostUsedPattern'] ?? 'Box Breathing';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Breather Stats",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.primaryColor,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: widget.primaryColor),
              onPressed: () {
                setState(() {
                  _showStats = false;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildStatItem(Icons.timer, "Total Breathers Taken", "$totalBreathers sessions"),
        _buildStatItem(Icons.access_time, "Total Breathing Time", "$totalBreatherMinutes minutes"),
        _buildStatItem(Icons.trending_up, "Longest Streak", "$longestStreak days"),
        _buildStatItem(Icons.local_fire_department, "Current Streak", "$currentStreak days"),
        _buildStatItem(Icons.favorite, "Most Used Pattern", mostUsedPattern),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showStats = false;
            });

            // Make sure audio is playing when returning to breathing view
            if (!_isAudioPlaying) {
              _playAudio();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Back to Breathing"),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: widget.primaryColor, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.primaryColor.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
