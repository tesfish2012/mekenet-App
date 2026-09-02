import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system — Poppins + Inter
///
/// Colors resolve against [brightness] so text stays visible in both light
/// and dark theme (and on dark branding backgrounds). Set [brightness] when
/// the app theme is resolved (see `main.dart`).
class AppTextStyles {
  AppTextStyles._();

  /// Tracks the active theme brightness so static styles resolve correct colors.
  static Brightness brightness = Brightness.light;

  static bool get _isDark => brightness == Brightness.dark;

  static Color get _textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color get _textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  static Color get _textHint =>
      _isDark ? AppColors.darkTextHint : AppColors.lightTextHint;

  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: _textPrimary,
      );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: _textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: _textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _textHint,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: _textHint,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: _textHint,
      );
}
