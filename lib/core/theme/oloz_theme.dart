import 'package:flutter/material.dart';
import 'package:oloz/core/theme/oloz_tokens.dart';

abstract class OlozTheme {
  static const String fontFamily = 'Inter';

  static TextTheme _buildTextTheme(Color textColor, Color secondaryColor) {
    const fontFeatures = [FontFeature.tabularFigures()];

    return TextTheme(
      // Display 40/600
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 48 / 40,
        letterSpacing: -0.8,
        color: textColor,
        fontFeatures: fontFeatures,
      ),
      // Title 22/600
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        letterSpacing: -0.22,
        color: textColor,
        fontFeatures: fontFeatures,
      ),
      // Section 16/600
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: textColor,
        fontFeatures: fontFeatures,
      ),
      // Body medium 14/500
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: textColor,
        fontFeatures: fontFeatures,
      ),
      // Body default 14/400
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: textColor,
        fontFeatures: fontFeatures,
      ),
      // Caption 12/500
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: secondaryColor,
        fontFeatures: fontFeatures,
      ),
      // Micro caption 11/500
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        color: secondaryColor,
        fontFeatures: fontFeatures,
      ),
    );
  }

  static ThemeData lightTheme() {
    const colors = OlozColors.light;
    final textTheme = _buildTextTheme(colors.text, colors.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.light(
        surface: colors.surface,
        onSurface: colors.text,
        primary: colors.primary,
        secondary: colors.reel,
        onSecondary: colors.onReelSoft,
        error: colors.danger,
        outline: colors.border,
      ),
      extensions: const [colors],
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OlozSpacing.radiusCard),
          side: BorderSide(color: colors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OlozSpacing.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OlozSpacing.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    const colors = OlozColors.dark;
    final textTheme = _buildTextTheme(colors.text, colors.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.dark(
        surface: colors.surface,
        onSurface: colors.text,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.reel,
        onSecondary: colors.onReelSoft,
        error: colors.danger,
        outline: colors.border,
      ),
      extensions: const [colors],
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OlozSpacing.radiusCard),
          side: BorderSide(color: colors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OlozSpacing.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OlozSpacing.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
