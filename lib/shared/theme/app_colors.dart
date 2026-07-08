import 'package:flutter/material.dart';

/// Brand color palette for SafeInsurance
class AppColors {
  AppColors._();

  // ── Primary Brand ─────────────────────────────────────────
  static const Color primary = Color(0xFF1A56DB);       // Deep Insurance Blue
  static const Color primaryDark = Color(0xFF1345B7);
  static const Color primaryLight = Color(0xFF4D80F0);
  static const Color primaryContainer = Color(0xFFDEEAFF);

  // ── Secondary ─────────────────────────────────────────────
  static const Color secondary = Color(0xFF0EA5E9);     // Sky Blue
  static const Color secondaryDark = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color secondaryContainer = Color(0xFFE0F2FE);

  // ── Accent ────────────────────────────────────────────────
  static const Color accent = Color(0xFF6366F1);        // Indigo
  static const Color accentContainer = Color(0xFFEEF2FF);

  // ── Status Colors ─────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

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
  static const Color lightBackground = Color(0xFFF8FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8EDF5);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextHint = Color(0xFF94A3B8);

  // ── Dark Theme ────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0F1E);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1A2235);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextHint = Color(0xFF64748B);

  // ── Policy Status ─────────────────────────────────────────
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusExpired = Color(0xFFEF4444);
  static const Color statusCancelled = Color(0xFF6B7280);
  static const Color statusNew = Color(0xFF3B82F6);
  static const Color statusReview = Color(0xFF8B5CF6);

  // ── Claim Status ──────────────────────────────────────────
  static const Color claimSubmitted = Color(0xFF3B82F6);
  static const Color claimUnderReview = Color(0xFFF59E0B);
  static const Color claimApproved = Color(0xFF10B981);
  static const Color claimRejected = Color(0xFFEF4444);
  static const Color claimPaid = Color(0xFF059669);

  // ── Gradients ─────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF1A56DB),
    Color(0xFF4D80F0),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF0F2042),
    Color(0xFF1A56DB),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF1A56DB),
    Color(0xFF6366F1),
  ];

  static const List<Color> successGradient = [
    Color(0xFF059669),
    Color(0xFF10B981),
  ];
}
