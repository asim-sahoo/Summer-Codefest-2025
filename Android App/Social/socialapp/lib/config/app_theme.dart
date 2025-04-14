import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Modern color palette
  static const Color primaryColor = Color(0xFF6750A4); // Vibrant purple
  static const Color secondaryColor = Color(0xFF9C27B0); // Deep purple
  static const Color accentColor = Color(0xFFD0BCFF); // Light purple
  static const Color tertiaryColor = Color(0xFFEFB8C8); // Pink accent

  // Text colors
  static const Color lightTextColor = Color(0xFF1C1B1F);
  static const Color darkTextColor = Color(0xFFE6E0E9);
  static const Color mutedTextColor = Color(0xFF79747E);

  // Background colors
  static const Color backgroundColorLight = Color(0xFFFFFBFE);
  static const Color backgroundColorDark = Color(0xFF1C1B1F);
  static const Color surfaceColorLight = Color(0xFFF7F2FA);
  static const Color surfaceColorDark = Color(0xFF2D2C30);

  // Additional colors
  static const Color errorColor = Color(0xFFB3261E);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: surfaceColorLight,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: lightTextColor,
      onSurface: lightTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColorLight,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
      titleTextStyle: const TextStyle(
        color: primaryColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: primaryColor),
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColorLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: mutedTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Colors.white),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return primaryColor.withOpacity(0.5);
          }
          if (states.contains(WidgetState.pressed)) {
            return primaryColor.withOpacity(0.8);
          }
          return primaryColor;
        }),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0;
          return 2;
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
        shadowColor: WidgetStateProperty.all(primaryColor.withOpacity(0.5)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(primaryColor),
        side: WidgetStateProperty.all(
          const BorderSide(color: primaryColor, width: 1.5),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        overlayColor: WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(primaryColor),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        overlayColor: WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColorLight,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: mutedTextColor),
      hintStyle: const TextStyle(color: mutedTextColor),
      errorStyle: const TextStyle(color: errorColor, fontWeight: FontWeight.w500),
      prefixIconColor: mutedTextColor,
      suffixIconColor: mutedTextColor,
      floatingLabelStyle: const TextStyle(color: primaryColor),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColorLight,
      disabledColor: surfaceColorLight.withOpacity(0.5),
      selectedColor: primaryColor.withOpacity(0.2),
      secondarySelectedColor: secondaryColor.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelStyle: const TextStyle(color: lightTextColor),
      secondaryLabelStyle: const TextStyle(color: secondaryColor),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: lightTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: lightTextColor,
        letterSpacing: 0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: lightTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: lightTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: lightTextColor,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightTextColor,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightTextColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: lightTextColor,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: lightTextColor,
        letterSpacing: 0.5,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightTextColor,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: lightTextColor,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceColorLight,
      contentTextStyle: const TextStyle(color: lightTextColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      actionTextColor: primaryColor,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E1E6),
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: lightTextColor,
      iconColor: mutedTextColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.3);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: mutedTextColor, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      secondary: Color(0xFFCFBCFF),
      tertiary: tertiaryColor,
      surface: surfaceColorDark,
      error: Color(0xFFCF6679),
      onPrimary: lightTextColor,
      onSecondary: lightTextColor,
      onTertiary: lightTextColor,
      onSurface: darkTextColor,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: backgroundColorDark,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: accentColor,
      titleTextStyle: const TextStyle(
        color: accentColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: accentColor),
      shadowColor: Colors.black45,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColorDark,
      selectedItemColor: accentColor,
      unselectedItemColor: Color(0xFFAEA9B4),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(lightTextColor),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return accentColor.withOpacity(0.5);
          }
          if (states.contains(WidgetState.pressed)) {
            return accentColor.withOpacity(0.8);
          }
          return accentColor;
        }),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0;
          return 2;
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        overlayColor: WidgetStateProperty.all(Colors.black.withOpacity(0.1)),
        shadowColor: WidgetStateProperty.all(Colors.black),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(accentColor),
        side: WidgetStateProperty.all(
          const BorderSide(color: accentColor, width: 1.5),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        overlayColor: WidgetStateProperty.all(accentColor.withOpacity(0.1)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(accentColor),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        overlayColor: WidgetStateProperty.all(accentColor.withOpacity(0.1)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColorDark,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFCF6679)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFFAEA9B4)),
      hintStyle: const TextStyle(color: Color(0xFFAEA9B4)),
      errorStyle: const TextStyle(color: Color(0xFFCF6679), fontWeight: FontWeight.w500),
      prefixIconColor: const Color(0xFFAEA9B4),
      suffixIconColor: const Color(0xFFAEA9B4),
      floatingLabelStyle: const TextStyle(color: accentColor),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: surfaceColorDark,
      surfaceTintColor: surfaceColorDark,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColorDark,
      disabledColor: surfaceColorDark.withOpacity(0.5),
      selectedColor: accentColor.withOpacity(0.2),
      secondarySelectedColor: const Color(0xFFCFBCFF).withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelStyle: const TextStyle(color: darkTextColor),
      secondaryLabelStyle: const TextStyle(color: Color(0xFFCFBCFF)),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: darkTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: darkTextColor,
        letterSpacing: 0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: darkTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: darkTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: darkTextColor,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: darkTextColor,
        letterSpacing: 0.5,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surfaceColorDark,
      surfaceTintColor: surfaceColorDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: darkTextColor,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF37343A),
      contentTextStyle: const TextStyle(color: darkTextColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      actionTextColor: accentColor,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3F3C42),
      thickness: 1,
      space: 1,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: darkTextColor,
      iconColor: Color(0xFFAEA9B4),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: accentColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return const Color(0xFFAEA9B4);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor.withOpacity(0.5);
        }
        return const Color(0xFF4D4D4D);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.black),
      side: const BorderSide(color: Color(0xFFAEA9B4), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );

  // Helper methods for theme extensions
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? mutedTextColor
        : const Color(0xFFAEA9B4);
  }

  static Color getCardBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey.withOpacity(0.1)
        : Colors.white.withOpacity(0.1);
  }
}