import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool hasBorder;
  final Gradient? gradient;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 2,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.hasBorder = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = backgroundColor ??
        (isDarkMode ? AppTheme.surfaceColorDark : Colors.white);
    final borderRadiusValue = borderRadius ?? BorderRadius.circular(20);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: gradient != null ? null : cardColor,
        gradient: gradient,
        borderRadius: borderRadiusValue,
        border: hasBorder
            ? Border.all(
                color: AppTheme.getCardBorderColor(context),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: elevation * 2,
            spreadRadius: elevation / 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadiusValue,
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}