import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.contentPadding,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (_isFocused && widget.validator != null) {
        _errorText = widget.validator!(widget.controller.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final Color backgroundColor = isDarkMode
        ? AppTheme.surfaceColorDark
        : AppTheme.surfaceColorLight;

    final Color textColor = isDarkMode
        ? AppTheme.darkTextColor
        : AppTheme.lightTextColor;

    final Color accentColor = isDarkMode
        ? AppTheme.accentColor
        : AppTheme.primaryColor;

    final Color hintColor = isDarkMode
        ? const Color(0xFFAEA9B4)
        : AppTheme.mutedTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: _isFocused ? accentColor : textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _errorText != null
                  ? theme.colorScheme.error
                  : _isFocused
                      ? accentColor
                      : backgroundColor,
              width: 2,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            textCapitalization: widget.textCapitalization,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: hintColor,
              ),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused ? accentColor : hintColor,
                        size: 22,
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? InkWell(
                      onTap: widget.onSuffixIconPressed,
                      borderRadius: BorderRadius.circular(50),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12, left: 8),
                        child: Icon(
                          widget.suffixIcon,
                          color: _isFocused ? accentColor : hintColor,
                          size: 22,
                        ),
                      ),
                    )
                  : null,
              counterText: "",
            ),
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
              if (widget.validator != null) {
                setState(() {
                  _errorText = widget.validator!(value);
                });
              }
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: (value) {
              if (widget.validator != null) {
                setState(() {
                  _errorText = widget.validator!(value);
                });
              }
              return _errorText;
            },
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}