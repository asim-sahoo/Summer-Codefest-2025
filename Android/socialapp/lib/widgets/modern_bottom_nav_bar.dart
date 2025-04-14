import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ModernBottomNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final double height;
  final double iconSize;
  final double selectedFontSize;
  final double unselectedFontSize;
  final bool showLabels;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final bool isFloating;
  final EdgeInsets margin;
  final BorderRadius? borderRadius;

  const ModernBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 72,
    this.iconSize = 24,
    this.selectedFontSize = 12,
    this.unselectedFontSize = 12,
    this.showLabels = true,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
    this.isFloating = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius,
  });

  @override
  State<ModernBottomNavBar> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<ModernBottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _createAnimations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ModernBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _createAnimations();
      _controller.reset();
      _controller.forward();
    }
  }

  void _createAnimations() {
    _animations = List.generate(
      widget.items.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: index == widget.currentIndex ? 1.0 : 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final backgroundColor = isDarkMode
        ? AppTheme.surfaceColorDark
        : Colors.white;

    final selectedColor = isDarkMode
        ? AppTheme.accentColor
        : AppTheme.primaryColor;

    final unselectedColor = isDarkMode
        ? const Color(0xFFAEA9B4)
        : AppTheme.mutedTextColor;

    // Set the border radius based on isFloating
    final borderRadiusValue = widget.borderRadius ??
        (widget.isFloating ? BorderRadius.circular(30) : BorderRadius.zero);

    return Container(
      height: widget.height + (widget.isFloating ? widget.margin.vertical : 0),
      padding: widget.isFloating ? widget.margin : EdgeInsets.zero,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadiusValue,
          boxShadow: widget.isFloating
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            widget.items.length,
            (index) => _buildNavItem(
              item: widget.items[index],
              index: index,
              isSelected: index == widget.currentIndex,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required int index,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    // Determine if labels should be shown
    final showLabel = widget.showLabels &&
        (isSelected ? widget.showSelectedLabels : widget.showUnselectedLabels);

    return Expanded(
      child: InkWell(
        onTap: () => widget.onTap(index),
        splashColor: selectedColor.withOpacity(0.1),
        highlightColor: selectedColor.withOpacity(0.05),
        child: AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return SizedBox(
              height: widget.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background indicator
                  if (isSelected)
                    Positioned(
                      top: 10,
                      child: Transform.scale(
                        scale: _animations[index].value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),

                  // Icon and label
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: widget.iconSize,
                        child: Icon(
                          isSelected ? item.activeIcon ?? item.icon : item.icon,
                          color: isSelected ? selectedColor : unselectedColor,
                          size: widget.iconSize,
                        ),
                      ),

                      // Label with animation
                      if (showLabel) ...[
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: isSelected
                                ? widget.selectedFontSize
                                : widget.unselectedFontSize,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ],
                  ),

                  // Top indicator dot
                  if (isSelected)
                    Positioned(
                      top: 10,
                      child: Transform.scale(
                        scale: _animations[index].value,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedColor,
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

class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final Widget? notificationBadge;

  const BottomNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.notificationBadge,
  });
}