import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand — exact color from uploaded image
  static const Color primary = Color(0xFF1A2744);
  static const Color primaryDark = Color(0xFF111B30);
  static const Color primaryLight = Color(0xFF2B3F63);
  static const Color primaryContainer = Color(0xFFE1E7F0);

  // Secondary
  static const Color secondary = Color(0xFF1A2744);
  static const Color secondaryDark = Color(0xFF111B30);
  static const Color secondaryLight = Color(0xFF293B5C);
  static const Color secondaryContainer = Color(0xFFE1E7F0);

  // Gold Accent
  static const Color accent = Color(0xFFF5A623);
  static const Color accentDark = Color(0xFFD4891A);
  static const Color accentLight = Color(0xFFFDD27A);
  static const Color accentContainer = Color(0xFFFFF3D6);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF3D6);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF1A2744);
  static const Color infoLight = Color(0xFFE1E7F0);

  // Neutrals
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

  // Light Theme
  static const Color lightBackground = Color(0xFFF0F4FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDDE3F0);
  static const Color lightTextPrimary = Color(0xFF0B1629);
  static const Color lightTextSecondary = Color(0xFF4A5568);
  static const Color lightTextHint = Color(0xFF9CA3AF);

  // Dark Theme
  static const Color darkBackground = Color(0xFF1A2744);
  static const Color darkSurface = Color(0xFF1A2744);
  static const Color darkCard = Color(0xFF1A2744);
  static const Color darkBorder = Color(0xFF344A70);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0C1E0);
  static const Color darkTextHint = Color(0xFF8798B5);

  // Policy Status
  static const Color statusActive = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF5A623);
  static const Color statusExpired = Color(0xFFEF4444);
  static const Color statusCancelled = Color(0xFF6B7280);
  static const Color statusNew = Color(0xFF1A2744);
  static const Color statusReview = Color(0xFFF5A623);

  // Claim Status
  static const Color claimSubmitted = Color(0xFF1A2744);
  static const Color claimUnderReview = Color(0xFFF5A623);
  static const Color claimApproved = Color(0xFF10B981);
  static const Color claimRejected = Color(0xFFEF4444);
  static const Color claimPaid = Color(0xFF059669);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF1A2744),
    Color(0xFF263B5E),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF1A2744),
    Color(0xFF111B30),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF1A2744),
    Color(0xFF344A70),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFD4891A),
    Color(0xFFF5A623),
  ];

  static const List<Color> successGradient = [
    Color(0xFF059669),
    Color(0xFF10B981),
  ];
}
// import 'package:flutter/material.dart';

// /// Brand color palette for Mekenet Insurance
// /// Derived from the app mockup: deep navy background, royal blue primary, gold accent
// class AppColors {
//   AppColors._();

//   // ── Primary Brand (Logo Navy Blue) ───────────────────────
//   static const Color primary = Color(0xFF0F1F5C);        // Logo Navy – main CTA, active cards
//   static const Color primaryDark = Color(0xFF091547);    // Deeper navy – pressed states
//   static const Color primaryLight = Color(0xFF2D4494);   // Lighter navy – icons on dark bg
//   static const Color primaryContainer = Color(0xFFDDE3F5); // Soft navy tint – chip/container bg

//   // ── Secondary (Navy) ──────────────────────────────────────
//   static const Color secondary = Color(0xFF0F1F5C);      // Same as primary – scaffold background
//   static const Color secondaryDark = Color(0xFF091547);  // Slightly deeper navy
//   static const Color secondaryLight = Color(0xFF1A3280); // Lighter navy – surface on dark
//   static const Color secondaryContainer = Color(0xFFDDE3F5);

//   // ── Gold Accent ───────────────────────────────────────────
//   static const Color accent = Color(0xFFF5A623);         // Gold – badges, highlights, icons
//   static const Color accentDark = Color(0xFFD4891A);     // Dark Gold – pressed accent
//   static const Color accentLight = Color(0xFFFDD27A);    // Light Gold – tinted backgrounds
//   static const Color accentContainer = Color(0xFFFFF3D6); // Pale Gold – chip/container bg

//   // ── Status Colors ─────────────────────────────────────────
//   static const Color success = Color(0xFF10B981);
//   static const Color successLight = Color(0xFFD1FAE5);
//   static const Color warning = Color(0xFFF5A623);        // Reuse brand gold for warnings
//   static const Color warningLight = Color(0xFFFFF3D6);
//   static const Color error = Color(0xFFEF4444);
//   static const Color errorLight = Color(0xFFFEE2E2);
//   static const Color info = Color(0xFF0F1F5C);
//   static const Color infoLight = Color(0xFFDDE3F5);

//   // ── Neutrals ─────────────────────────────────────────────
//   static const Color grey50 = Color(0xFFF9FAFB);
//   static const Color grey100 = Color(0xFFF3F4F6);
//   static const Color grey200 = Color(0xFFE5E7EB);
//   static const Color grey300 = Color(0xFFD1D5DB);
//   static const Color grey400 = Color(0xFF9CA3AF);
//   static const Color grey500 = Color(0xFF6B7280);
//   static const Color grey600 = Color(0xFF4B5563);
//   static const Color grey700 = Color(0xFF374151);
//   static const Color grey800 = Color(0xFF1F2937);
//   static const Color grey900 = Color(0xFF111827);

//   // ── Light Theme ───────────────────────────────────────────
//   static const Color lightBackground = Color(0xFFF0F4FF);  // Soft blue-white
//   static const Color lightSurface = Color(0xFFFFFFFF);     // Pure white cards
//   static const Color lightCard = Color(0xFFFFFFFF);
//   static const Color lightBorder = Color(0xFFDDE3F0);
//   static const Color lightTextPrimary = Color(0xFF0B1629);  // Navy text
//   static const Color lightTextSecondary = Color(0xFF4A5568);
//   static const Color lightTextHint = Color(0xFF9CA3AF);

//   // ── Dark Theme (matches logo navy) ───────────────────────
//   static const Color darkBackground = primary;
//   static const Color darkSurface = primary;
//   static const Color darkCard = Color(0xFF0F1F5C);          // Card on dark bg
//   static const Color darkBorder = Color(0xFF2D4494);
//   static const Color darkTextPrimary = Color(0xFFFFFFFF);
//   static const Color darkTextSecondary = Color(0xFFB0C1E0);
//   static const Color darkTextHint = Color(0xFF6B82A8);

//   // ── Policy Status ─────────────────────────────────────────
//   static const Color statusActive = Color(0xFF10B981);
//   static const Color statusPending = Color(0xFFF5A623);
//   static const Color statusExpired = Color(0xFFEF4444);
//   static const Color statusCancelled = Color(0xFF6B7280);
//   static const Color statusNew = Color(0xFF0F1F5C);
//   static const Color statusReview = Color(0xFFF5A623);

//   // ── Claim Status ──────────────────────────────────────────
//   static const Color claimSubmitted = Color(0xFF0F1F5C);
//   static const Color claimUnderReview = Color(0xFFF5A623);
//   static const Color claimApproved = Color(0xFF10B981);
//   static const Color claimRejected = Color(0xFFEF4444);
//   static const Color claimPaid = Color(0xFF059669);

//   // ── Gradients ─────────────────────────────────────────────
//   /// Logo navy gradient – primary cards, hero sections
//   static const List<Color> primaryGradient = [
//     Color(0xFF0F1F5C),
//     Color(0xFF1A3280),
//   ];

//   /// Deep navy gradient – scaffold header, dark backgrounds
//   static const List<Color> darkGradient = [
//     Color(0xFF0F1F5C),
//     Color(0xFF1A3280),
//   ];

//   /// Navy card gradient – policy/insurance card widget
//   static const List<Color> cardGradient = [
//     Color(0xFF0F1F5C),
//     Color(0xFF2D4494),
//   ];

//   /// Gold accent gradient – badges, highlights
//   static const List<Color> accentGradient = [
//     Color(0xFFD4891A),
//     Color(0xFFF5A623),
//   ];

//   static const List<Color> successGradient = [
//     Color(0xFF059669),
//     Color(0xFF10B981),
//   ];
// }
