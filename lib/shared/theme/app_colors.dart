import 'package:flutter/material.dart';

/// Brand color palette for SafeInsurance
class AppColors {
  AppColors._();

  // ── Primary Brand ─────────────────────────────────────────
  static const Color primary = Color(0xFF0B2E8A);       // Primary Blue
  static const Color primaryDark = Color(0xFF081F66);   // Dark Blue
  static const Color primaryLight = Color(0xFF393F5F);  // Secondary Blue
  static const Color primaryContainer = Color(0xFFDEE8FB);

  // ── Secondary ─────────────────────────────────────────────
  static const Color secondary = Color(0xFF393F5F);     // Secondary Blue
  static const Color secondaryDark = Color(0xFF081F66);
  static const Color secondaryLight = Color(0xFF4F8FF7);
  static const Color secondaryContainer = Color(0xFFE0EAFF);

  // ── Accent ────────────────────────────────────────────────
  static const Color accent = Color(0xFF4F8FF7);        // Accent Blue
  static const Color accentContainer = Color(0xFFEEF3FF);

  // ── Status Colors ─────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF4F8FF7);
  static const Color infoLight = Color(0xFFE0EAFF);

  // ── Neutrals ─────────────────────────────────────────────
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ── Light Theme ───────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC); // Background
  static const Color lightSurface = Color(0xFFFFFFFF);    // White
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0B2E8A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextHint = Color(0xFF94A3B8);

  // ── Dark Theme ────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF081F66);  // Dark Blue
  static const Color darkSurface = Color(0xFF0B2E8A);     // Primary Blue
  static const Color darkCard = Color(0xFF0F3699);
  static const Color darkBorder = Color(0xFF393F5F);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0C4F5);
  static const Color darkTextHint = Color(0xFF7A9DE0);

  // ── Policy Status ─────────────────────────────────────────
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusExpired = Color(0xFFEF4444);
  static const Color statusCancelled = Color(0xFF6B7280);
  static const Color statusNew = Color(0xFF4F8FF7);
  static const Color statusReview = Color(0xFF393F5F);

  // ── Claim Status ──────────────────────────────────────────
  static const Color claimSubmitted = Color(0xFF4F8FF7);
  static const Color claimUnderReview = Color(0xFFF59E0B);
  static const Color claimApproved = Color(0xFF10B981);
  static const Color claimRejected = Color(0xFFEF4444);
  static const Color claimPaid = Color(0xFF059669);

  // ── Gradients ─────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF0B2E8A),
    Color(0xFF393F5F),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF081F66),
    Color(0xFF0B2E8A),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF0B2E8A),
    Color(0xFF4F8FF7),
  ];

  static const List<Color> successGradient = [
    Color(0xFF059669),
    Color(0xFF10B981),
  ];
}
