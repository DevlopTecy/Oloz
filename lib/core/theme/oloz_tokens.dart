import 'package:flutter/material.dart';

/// Oloz design system color tokens implemented as a ThemeExtension.
/// No hex literals should be used outside this file.
@immutable
class OlozColors extends ThemeExtension<OlozColors> {
  const OlozColors({
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.primary,
    required this.chart,
    required this.primarySoft,
    required this.reel,
    required this.reelSoft,
    required this.onReelSoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.shadowColor,
  });

  final Color bg;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color primary;
  final Color chart;
  final Color primarySoft;
  final Color reel;
  final Color reelSoft;
  final Color onReelSoft;
  final Color success;
  final Color warning;
  final Color danger;
  final Color shadowColor;

  Color get onPrimary => Colors.white;
  Color get chartSoft => primarySoft;
  Color get error => danger;

  static const light = OlozColors(
    bg: Color(0xFFF6F5F2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEEDE9),
    border: Color(0xFFE4E2DC),
    text: Color(0xFF23262B),
    textSecondary: Color(0xFF6E727A),
    primary: Color(0xFF5870C2),
    chart: Color(0xFF6B83D6),
    primarySoft: Color(0xFFE3E8F8),
    reel: Color(0xFFF0A98E),
    reelSoft: Color(0xFFFBE9E1),
    onReelSoft: Color(0xFF79452F),
    success: Color(0xFF7FB69A),
    warning: Color(0xFFE6C27A),
    danger: Color(0xFFD98A8A),
    shadowColor: Color.fromRGBO(35, 38, 43, 0.05),
  );

  static const dark = OlozColors(
    bg: Color(0xFF14161A),
    surface: Color(0xFF1C1F25),
    surfaceMuted: Color(0xFF262A32),
    border: Color(0xFF2E323B),
    text: Color(0xFFECEDEF),
    textSecondary: Color(0xFF9AA0AA),
    primary: Color(0xFF8FA3E8),
    chart: Color(0xFF8FA3E8),
    primarySoft: Color(0xFF242C42),
    reel: Color(0xFFF2B49B),
    reelSoft: Color(0xFF352622),
    onReelSoft: Color(0xFFFBE9E1),
    success: Color(0xFF7FB69A),
    warning: Color(0xFFE6C27A),
    danger: Color(0xFFD98A8A),
    shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
  );

  @override
  OlozColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? text,
    Color? textSecondary,
    Color? primary,
    Color? chart,
    Color? primarySoft,
    Color? reel,
    Color? reelSoft,
    Color? onReelSoft,
    Color? success,
    Color? warning,
    Color? danger,
    Color? shadowColor,
  }) {
    return OlozColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      primary: primary ?? this.primary,
      chart: chart ?? this.chart,
      primarySoft: primarySoft ?? this.primarySoft,
      reel: reel ?? this.reel,
      reelSoft: reelSoft ?? this.reelSoft,
      onReelSoft: onReelSoft ?? this.onReelSoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  OlozColors lerp(ThemeExtension<OlozColors>? other, double t) {
    if (other is! OlozColors) return this;
    return OlozColors(
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      text: Color.lerp(text, other.text, t) ?? text,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      chart: Color.lerp(chart, other.chart, t) ?? chart,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t) ?? primarySoft,
      reel: Color.lerp(reel, other.reel, t) ?? reel,
      reelSoft: Color.lerp(reelSoft, other.reelSoft, t) ?? reelSoft,
      onReelSoft: Color.lerp(onReelSoft, other.onReelSoft, t) ?? onReelSoft,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
    );
  }
}

/// Spacing, radius, and duration constants for Oloz.
abstract class OlozSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  static const double cardPadding = 20;

  static const double screenPaddingMobile = 20;
  static const double screenPaddingDesktop = 32;
  static const double maxContentWidthDesktop = 1200;

  static const double radiusCard = 20;
  static const double radiusButton = 14;
  static const double radiusAppIcon = 12;
  static const double radiusPill = 999;
}

abstract class OlozDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 250);
}

/// App brand icon token pairings defined exclusively in tokens.
abstract class OlozBrandColors {
  static const instagramBg = Color(0xFFFDE8E1);
  static const instagramFg = Color(0xFFD64D68);

  static const tiktokBg = Color(0xFFE5F7F7);
  static const tiktokFg = Color(0xFF009688);

  static const youtubeBg = Color(0xFFFFEBEA);
  static const youtubeFg = Color(0xFFE53935);

  static const facebookBg = Color(0xFFE8EEF9);
  static const facebookFg = Color(0xFF1877F2);

  static const whatsappBg = Color(0xFFE7F7ED);
  static const whatsappFg = Color(0xFF25D366);

  static const redditBg = Color(0xFFFFEFEA);
  static const redditFg = Color(0xFFFF4500);

  static const chromeBg = Color(0xFFE8F0FE);
  static const chromeFg = Color(0xFF1A73E8);

  // Preview overlay gradient colors
  static const mockVideoGradientStart = Color(0xFF1E2430);
  static const mockVideoGradientMid = Color(0xFF2C1E26);
  static const mockVideoGradientEnd = Color(0xFF161922);
}

extension OlozColorsContext on BuildContext {
  OlozColors get olozColors =>
      Theme.of(this).extension<OlozColors>() ?? OlozColors.light;
}

