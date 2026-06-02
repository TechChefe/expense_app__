// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand palette — same in both modes ──────────────────────────────────
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4834A6);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color accent = Color(0xFF00D2A8);
  static const Color accentDark = Color(0xFF00B894);

  // ── Status (same in both modes) ─────────────────────────────────────────
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF00D2A8);
  static const Color warning = Color(0xFFFDCB6E);

  // ── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF4834A6)],
  );
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D2A8), Color(0xFF00B894)],
  );
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFA06B)],
  );

  // ── Per-category fallback palette ───────────────────────────────────────
  static const List<Color> palette = [
    Color(0xFF6C5CE7),
    Color(0xFF00D2A8),
    Color(0xFFFF6B6B),
    Color(0xFF0984E3),
    Color(0xFFFDCB6E),
    Color(0xFFE17055),
    Color(0xFF00B894),
    Color(0xFFFD79A8),
    Color(0xFF74B9FF),
    Color(0xFFA29BFE),
  ];

  // ═══ DYNAMIC COLORS — read from Theme.of(context).brightness ════════════
  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  static Color background(BuildContext c) => isDark(c)
      ? const Color(0xFF0F0F1E)
      : const Color(0xFFF4F5FB);

  static Color surface(BuildContext c) => isDark(c)
      ? const Color(0xFF1E1E2E)
      : const Color(0xFFFFFFFF);

  static Color surfaceAlt(BuildContext c) => isDark(c)
      ? const Color(0xFF252539)
      : const Color(0xFFF8F9FE);

  static Color textPrimary(BuildContext c) => isDark(c)
      ? const Color(0xFFF4F5FB)
      : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext c) => isDark(c)
      ? const Color(0xFFA0A3B8)
      : const Color(0xFF6B7280);

  static Color textTertiary(BuildContext c) => isDark(c)
      ? const Color(0xFF6B6E80)
      : const Color(0xFF9CA3AF);

  static Color divider(BuildContext c) => isDark(c)
      ? const Color(0xFF2A2A3E)
      : const Color(0xFFE5E7EB);

  // ═══ THEMES ════════════════════════════════════════════════════════════
  static ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);
  static ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final bgColor =
        isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF4F5FB);
    final surfColor =
        isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFFFF);
    final surfAltColor =
        isDark ? const Color(0xFF252539) : const Color(0xFFF8F9FE);
    final textPri =
        isDark ? const Color(0xFFF4F5FB) : const Color(0xFF1A1A2E);
    final textSec =
        isDark ? const Color(0xFFA0A3B8) : const Color(0xFF6B7280);
    final textTer =
        isDark ? const Color(0xFF6B6E80) : const Color(0xFF9CA3AF);
    final dividerColor =
        isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE5E7EB);

    return base.copyWith(
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: surfColor,
        onSurface: textPri,
        error: error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPri,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textPri,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPri),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfAltColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSec, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: textTer),
      ),
      cardTheme: CardThemeData(
        color: surfColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfColor,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSec,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return IconThemeData(color: textSec);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfAltColor,
        selectedColor: primary,
        disabledColor: dividerColor,
        labelStyle:
            TextStyle(color: textPri, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textPri,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfColor,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
