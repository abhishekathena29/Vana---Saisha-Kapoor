import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens ported 1:1 from src/styles.css (oklch -> sRGB).
class AppColors {
  AppColors._();

  static const background = Color(0xFFFBF5EC);
  static const bone = Color(0xFFFBF5EC);
  static const foreground = Color(0xFF2A1C10);
  static const ink = Color(0xFF180F09);

  static const card = Color(0xFFFFFBF6);

  static const primary = Color(0xFF1B4222);
  static const primaryForeground = Color(0xFFFAF5E6);

  static const secondary = Color(0xFFEFE7D9);
  static const secondaryForeground = Color(0xFF372414);

  static const muted = Color(0xFFF0EAE0);
  static const mutedForeground = Color(0xFF706052);

  static const clay = Color(0xFFDF7752);
  static const clayForeground = Color(0xFFFEF8EA);

  static const leaf = Color(0xFF4E9A52);
  static const leafForeground = Color(0xFFFEFCF4);

  static const destructive = Color(0xFFCC3430);

  static const border = Color(0xFFDED6CB);
  static const input = Color(0xFFE4DDD3);
  static const ring = Color(0xFF1B4222);

  // Gradients
  static const gradientHero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x001B4222),
      Color(0xA60C2611),
      Color(0xEB041607),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  static const gradientClay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFED845B), Color(0xFFD15E49)],
  );

  static const gradientLeaf = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF255A2F), Color(0xFF0D3119)],
  );
}

class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const xl2 = 28.0;
  static const xl3 = 36.0;
  static const full = 999.0;
}

class AppShadows {
  AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x0F3D2A17), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x2E3D2A17), blurRadius: 40, offset: Offset(0, 12), spreadRadius: -18),
  ];

  static const lift = [
    BoxShadow(color: Color(0x593D2A17), blurRadius: 60, offset: Offset(0, 20), spreadRadius: -30),
  ];
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.foreground,
    double? height,
    double letterSpacing = -0.4,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.foreground,
    double? height,
    double letterSpacing = 0,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      error: AppColors.destructive,
    ),
    fontFamily: GoogleFonts.manrope().fontFamily,
    textTheme: GoogleFonts.manropeTextTheme(),
  );

  return base.copyWith(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    // Float snackbars above the floating bottom nav bar instead of under it.
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
