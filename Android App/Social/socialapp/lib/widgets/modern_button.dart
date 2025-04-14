import 'package:flutter/material.dart';
import '../config/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class ModernButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool iconTrailing;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final BorderRadius? borderRadius;

  const ModernButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.iconTrailing = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
    this.borderRadius,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _controller.forward();
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp() {
    _controller.reverse();
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Button padding based on size
    EdgeInsets getPadding() {
      switch (widget.size) {
        case ButtonSize.small:
          return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
        case ButtonSize.medium:
          return const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
        case ButtonSize.large:
          return const EdgeInsets.symmetric(vertical: 16, horizontal: 32);
      }
    }

    // Text style based on variant
    TextStyle getTextStyle() {
      final baseTextStyle = Theme.of(context).textTheme.labelLarge!;

      switch (widget.variant) {
        case ButtonVariant.primary:
          return baseTextStyle.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          );
        case ButtonVariant.secondary:
          return baseTextStyle.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          );
        case ButtonVariant.outlined:
          return baseTextStyle.copyWith(
            color: widget.customColor ?? (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor),
            fontWeight: FontWeight.w600,
          );
        case ButtonVariant.text:
          return baseTextStyle.copyWith(
            color: widget.customColor ?? (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor),
            fontWeight: FontWeight.w600,
          );
      }
    }

    // Button decoration based on variant
    BoxDecoration getDecoration() {
      final borderRadiusValue = widget.borderRadius ?? BorderRadius.circular(28);

      switch (widget.variant) {
        case ButtonVariant.primary:
          return BoxDecoration(
            color: widget.customColor ?? (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor),
            borderRadius: borderRadiusValue,
            boxShadow: _isPressed || widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: (widget.customColor ??
                          (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor))
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          );
        case ButtonVariant.secondary:
          return BoxDecoration(
            color: widget.customColor ??
                (isDarkMode ? AppTheme.secondaryColor : AppTheme.secondaryColor),
            borderRadius: borderRadiusValue,
            boxShadow: _isPressed || widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: (widget.customColor ??
                          (isDarkMode ? AppTheme.secondaryColor : AppTheme.secondaryColor))
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          );
        case ButtonVariant.outlined:
          return BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadiusValue,
            border: Border.all(
              color: widget.customColor ??
                  (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor),
              width: 1.5,
            ),
          );
        case ButtonVariant.text:
          return BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadiusValue,
          );
      }
    }

    final buttonContent = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.iconTrailing) ...[
          Icon(widget.icon, size: 20, color: getTextStyle().color),
          const SizedBox(width: 8),
        ],
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(getTextStyle().color!),
            ),
          )
        else
          Text(
            widget.text,
            style: getTextStyle(),
          ),
        if (widget.icon != null && widget.iconTrailing) ...[
          const SizedBox(width: 8),
          Icon(widget.icon, size: 20, color: getTextStyle().color),
        ],
      ],
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: _onTapUp,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              padding: getPadding(),
              decoration: getDecoration(),
              child: buttonContent,
            ),
          ),
        );
      },
    );
  }
}