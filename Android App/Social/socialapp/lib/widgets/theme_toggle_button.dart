import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../main.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final MyAppState appState = context.findAncestorStateOfType<MyAppState>()!;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: appState.toggleTheme,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppTheme.surfaceColorDark
              : AppTheme.surfaceColorLight,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black26
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: appState.themeAnimationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: appState.rotationAnimation.value * 2.0 * 3.14159,
              child: Stack(
                children: [
                  AnimatedCrossFade(
                    firstChild: const Icon(
                      Icons.light_mode,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    secondChild: const Icon(
                      Icons.dark_mode,
                      color: AppTheme.accentColor,
                      size: 24,
                    ),
                    crossFadeState: isDarkMode
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  if (appState.themeAnimationController.value > 0 &&
                      appState.themeAnimationController.value < 1)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 30 * appState.themeAnimationController.value,
                          height: 30 * appState.themeAnimationController.value,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppTheme.accentColor.withOpacity(0.3)
                                : AppTheme.primaryColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}