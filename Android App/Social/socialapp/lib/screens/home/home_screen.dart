import 'package:flutter/material.dart';
import 'package:socialapp/screens/daily_digest_screen.dart';
import '../profile/profile_screen.dart';
import 'feed_screen.dart';
import 'create_post_screen.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import '../auth/login_screen.dart';
import '../dashboard_screen.dart';
import '../screen_time_limit_settings_screen.dart'; // Add import for screen time limit settings
import '../../services/activity_service.dart';
import '../../services/digest_service.dart';
import '../../services/feedback_digest_service.dart';
import '../../widgets/end_of_day_summary_dialog.dart';
import '../../widgets/modern_app_bar.dart';
import '../../widgets/modern_bottom_nav_bar.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final ActivityService _activityService = ActivityService();
  final DigestService _digestService = DigestService();
  final FeedbackDigestService _feedbackDigestService = FeedbackDigestService();
  late AnimationController _animationController;
  DateTime? _startTime;
  Timer? _endOfDayCheckTimer;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const FeedScreen(),
    const CreatePostScreen(),
    const ProfileScreen(),
    const DashboardScreen(),
  ];

  // Navigation items
  final List<BottomNavItem> _navItems = [
    const BottomNavItem(
      label: 'Feed',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    const BottomNavItem(
      label: 'Create',
      icon: Icons.add_box_outlined,
      activeIcon: Icons.add_box_rounded,
    ),
    const BottomNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
    const BottomNavItem(
      label: 'Insights',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
    ),
  ];

  // Screen titles
  final List<String> _titles = [
    'Feed',
    'Create Post',
    'Profile',
    'Insights',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTime = DateTime.now();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set up our app after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we should show the daily digest
      _checkForDailyDigest();

      // Set up timer to check for end-of-day summary
      _setupEndOfDayCheck();
    });
  }

  // Check if it's time to show the daily digest
  Future<void> _checkForDailyDigest() async {
    // Add a short delay to allow the app to load properly
    await Future.delayed(const Duration(seconds: 2));

    final shouldShow = await _digestService.shouldShowDigest();
    if (shouldShow && mounted) {
      _showDailyDigest();
    }
  }

  // Show the daily digest screen
  void _showDailyDigest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: const DailyDigestScreen(),
        ),
      ),
    );
  }

  // Set up a timer to check if it's time to show the end-of-day summary
  void _setupEndOfDayCheck() {
    // Cancel any existing timer
    _endOfDayCheckTimer?.cancel();

    // Set up timer to check every 15 minutes
    _endOfDayCheckTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _checkForEndOfDaySummary();
    });

    // Also check immediately
    _checkForEndOfDaySummary();
  }

  // Check if it's time to show the end-of-day summary
  Future<void> _checkForEndOfDaySummary() async {
    if (!mounted) return;

    bool shouldShow = await _feedbackDigestService.shouldShowEndOfDaySummary();

    if (shouldShow) {
      // Fetch latest digest to ensure we have the most up-to-date data
      final digest = await _feedbackDigestService.getDailyDigest();

      // Only show if there's actual engagement to report (at least 1 like or comment)
      if (digest.likesReceived > 0 || digest.commentsReceived > 0) {
        _showEndOfDaySummary(digest);
      }
    }
  }

  // Show the end-of-day summary dialog
  void _showEndOfDaySummary(digest) {
    if (!mounted) return;

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordScreenTime();
    _animationController.dispose();
    _pageController.dispose();
    _endOfDayCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _recordScreenTime();
      _startTime = null;
    } else if (state == AppLifecycleState.resumed) {
      _startTime = DateTime.now();
    }
  }

  void _recordScreenTime() {
    if (_startTime != null) {
      final duration = DateTime.now().difference(_startTime!);
      _activityService.incrementScreenTime(duration);
      print('Recorded screen time: ${duration.inSeconds} seconds');
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _logout() async {
    // Show confirmation dialog
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ) ?? false;

    if (confirm) {
      await _authService.logout();
      if (mounted) {
        NavigationService.navigateToAndRemoveUntil(const LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Build the app actions
    final List<Widget> appBarActions = [
      // Add timer settings icon
      if (_currentIndex == 0) // Show only on feed screen
        IconButton(
          icon: const Icon(Icons.timer_outlined),
          tooltip: 'Feed Timer Settings',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScreenTimeLimitSettingsScreen(),
              ),
            );
          },
        ),
      IconButton(
        icon: const Icon(Icons.exit_to_app),
        tooltip: 'Sign Out',
        onPressed: _logout,
      ),
    ];

    return Scaffold(
      appBar: ModernAppBar(
        title: _titles[_currentIndex],
        actions: appBarActions,
        showBackButton: false,
        elevation: 0,
        centerTitle: false,
        isTransparent: false,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _screens, // Disable swiping between pages
      ),
      bottomNavigationBar: ModernBottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        isFloating: true,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        showLabels: true,
      ),
      extendBody: true, // Important for floating nav bar
    );
  }
}