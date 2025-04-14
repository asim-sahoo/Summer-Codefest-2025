import 'package:flutter/material.dart';
import '../../models/mood_model.dart';
import '../../services/mood_service.dart';
import '../../config/app_theme.dart';

class MoodCheckInScreen extends StatefulWidget {
  final Function? onComplete;

  const MoodCheckInScreen({
    super.key,
    this.onComplete,
  });

  @override
  _MoodCheckInScreenState createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> with SingleTickerProviderStateMixin {
  final MoodService _moodService = MoodService();
  MoodType? _selectedMood;
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Submit the selected mood
  Future<void> _submitMood() async {
    if (_selectedMood == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create a new mood entry
      final entry = MoodEntry(
        timestamp: DateTime.now(),
        mood: _selectedMood!,
      );

      // Save it
      await _moodService.saveMood(entry);

      // Call the completion callback if provided
      if (widget.onComplete != null) {
        widget.onComplete!();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your mood has been recorded!'),
            backgroundColor: Colors.green,
          ),
        );
        // Close this screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error saving mood: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save your mood: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Build a mood option button
  Widget _buildMoodOption(MoodType mood) {
    final bool isSelected = _selectedMood == mood;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Get mood-specific data
    String emojiText;
    String moodText;
    Color moodColor;

    switch (mood) {
      case MoodType.happy:
        emojiText = '😊';
        moodText = 'Happy';
        moodColor = Colors.green;
        break;
      case MoodType.neutral:
        emojiText = '😐';
        moodText = 'Neutral';
        moodColor = Colors.blue;
        break;
      case MoodType.stressed:
        emojiText = '😓';
        moodText = 'Stressed';
        moodColor = Colors.orange;
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 110,
        decoration: BoxDecoration(
          color: isSelected
              ? moodColor.withOpacity(isDarkMode ? 0.3 : 0.1)
              : isDarkMode
                  ? Colors.grey.shade800.withOpacity(0.2)
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? moodColor.withOpacity(0.8)
                : isDarkMode
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emojiText,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              moodText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? moodColor
                    : isDarkMode
                        ? Colors.white
                        : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;
    final surfaceColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Mood Check-In', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'How are you feeling?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the emoji that best represents your current mood',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMoodOption(MoodType.happy),
                    _buildMoodOption(MoodType.neutral),
                    _buildMoodOption(MoodType.stressed),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedMood == null || _isSubmitting
                      ? null
                      : _submitMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.darkTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.darkTextColor,
                          ),
                        )
                      : const Text('Submit'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: textColor.withOpacity(0.7),
                  ),
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}