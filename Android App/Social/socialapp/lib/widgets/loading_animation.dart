import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class LoadingAnimation extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color? primaryColor;
  final Color? secondaryColor;

  const LoadingAnimation({
    super.key,
    this.size = 50,
    this.duration = const Duration(milliseconds: 1500),
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  LoadingAnimationState createState() => LoadingAnimationState();
}

class LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.70, curve: Curves.easeInOut),
      ),
    );

    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.80, curve: Curves.easeInOut),
      ),
    );

    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.90, curve: Curves.easeInOut),
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final color1 = widget.primaryColor ??
        (isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor);
    final color2 = widget.secondaryColor ??
        (isDarkMode ? AppTheme.tertiaryColor : AppTheme.secondaryColor);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size * 3.5,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size / 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(_animation1, color1),
              SizedBox(width: widget.size * 0.5),
              _buildDot(_animation2, color2),
              SizedBox(width: widget.size * 0.5),
              _buildDot(_animation3, color1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDot(Animation<double> animation, Color color) {
    return Transform.scale(
      scale: animation.value,
      child: Opacity(
        opacity: animation.value,
        child: Container(
          width: widget.size * 0.8,
          height: widget.size * 0.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.size / 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}