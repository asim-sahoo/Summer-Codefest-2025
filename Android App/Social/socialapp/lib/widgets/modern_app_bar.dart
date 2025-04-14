import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'theme_toggle_button.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showThemeToggle;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Widget? leadingWidget;
  final VoidCallback? onBackPressed;
  final bool isTransparent;
  final Widget? flexibleSpace;
  final double height;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showThemeToggle = true,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.leadingWidget,
    this.onBackPressed,
    this.isTransparent = false,
    this.flexibleSpace,
    this.height = kToolbarHeight + 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Determine app bar colors based on theme and transparency
    final appBarColor = isTransparent
        ? Colors.transparent
        : backgroundColor ?? (isDarkMode
            ? AppTheme.backgroundColorDark
            : AppTheme.backgroundColorLight);

    final textColor = isDarkMode
        ? AppTheme.accentColor
        : AppTheme.primaryColor;

    // Build actions list
    final actionsList = <Widget>[
      ...(actions ?? []),
      if (showThemeToggle) ...[
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: ThemeToggleButton(),
        ),
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: appBarColor,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            if (flexibleSpace != null)
              Positioned.fill(child: flexibleSpace!),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Leading section (back button or custom widget)
                  Row(
                    children: [
                      if (showBackButton && Navigator.of(context).canPop())
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: textColor,
                            size: 20,
                          ),
                          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                          tooltip: 'Back',
                        )
                      else if (leadingWidget != null)
                        leadingWidget!,
                    ],
                  ),

                  // Title (centered or not based on centerTitle)
                  if (centerTitle)
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                  // Actions section
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actionsList,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}