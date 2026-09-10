// Smart Livestock — Shared Color Design Tokens
// All three modules (Farmer, Vet, Government) reference these constants.
// DO NOT add module-specific logic here — keep it purely declarative.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Brand ─────────────────────────────────────────────────────────
  /// Primary teal — used for buttons, active states, and primary actions
  static const Color primary = Color(0xFF0D9488);

  /// Darker teal — pressed states, gradients, AppBar backgrounds
  static const Color primaryDark = Color(0xFF0F766E);

  /// Lighter teal — selected backgrounds, badges, chip fills
  static const Color primaryLight = Color(0xFFCCFBF1);

  /// Faint teal — hover backgrounds, card borders
  static const Color primaryFaint = Color(0xFFEFFEFD);

  // ─── Neutral Backgrounds ───────────────────────────────────────────────────
  /// Page background — very light grey-blue
  static const Color background = Color(0xFFF8FAFC);

  /// Card / surface background
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle surface — section headers, list separators
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  // ─── Text ──────────────────────────────────────────────────────────────────
  /// Headings, labels, strong emphasis
  static const Color textPrimary = Color(0xFF111827);

  /// Body text, card descriptions
  static const Color textSecondary = Color(0xFF4B5563);

  /// Captions, hints, metadata
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textTertiary = textMuted;

  /// Disabled / placeholder text
  static const Color textDisabled = Color(0xFF9CA3AF);

  // ─── UI Chrome ─────────────────────────────────────────────────────────────
  /// Default border for inputs, cards, dividers
  static const Color border = Color(0xFFE5E7EB);

  /// Subtle divider lines inside cards
  static const Color divider = Color(0xFFF3F4F6);
  static const Color borderLight = divider;

  /// Shadow base colour (use with opacity)
  static const Color shadowBase = Color(0xFF111827);

  // ─── Semantic — Status Colors ──────────────────────────────────────────────
  /// Success green — resolved cases, vaccines administered, online indicators
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);

  /// Warning amber — pending actions, moderate risk, vaccination due
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309);

  /// Error red — critical cases, mortality events, emergency actions
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  /// Info blue — vet professional accent, informational badges
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  // ─── Role-Specific Accents (layout emphasis only) ──────────────────────────
  /// Farmer: High-visibility emergency red for the primary "Report" action
  static const Color farmerEmergency = Color(0xFFC62828);
  static const Color farmerEmergencyLight = Color(0xFFFFEBEE);

  /// Veterinary: Professional blue accent — NOT the same as Info blue
  static const Color vetAccent = Color(0xFF1E40AF);
  static const Color vetAccentLight = Color(0xFFEFF6FF);
  static const Color vetAccentSurface = Color(0xFFF0F4FF);

  /// Government: Navy sidebar background
  static const Color govtNavy = Color(0xFF0B192C);
  static const Color govtNavyDark = Color(0xFF060E18);
  static const Color govtNavyBorder = Color(0xFF1E3A5F);

  // ─── Risk Severity Scale (used by Vet + Govt modules) ─────────────────────
  static const Color riskLow = Color(0xFF16A34A);       // == success
  static const Color riskModerate = Color(0xFFD97706);  // == warning
  static const Color riskMedium = riskModerate;
  static const Color riskElevated = Color(0xFFF57C00);
  static const Color riskHigh = Color(0xFFE65100);
  static const Color riskCritical = Color(0xFFDC2626);  // == error

  static Color getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return riskCritical;
      case 'HIGH':
        return riskHigh;
      case 'ELEVATED':
        return riskElevated;
      case 'MEDIUM':
      case 'MODERATE':
        return riskModerate;
      default:
        return riskLow;
    }
  }

  static Color getRiskBgColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return errorLight;
      case 'HIGH':
        return const Color(0xFFFFF3E0);
      case 'ELEVATED':
        return const Color(0xFFFFF8F0);
      case 'MEDIUM':
      case 'MODERATE':
        return warningLight;
      default:
        return successLight;
    }
  }

  static IconData getRiskIcon(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return Icons.crisis_alert_rounded;
      case 'HIGH':
        return Icons.warning_rounded;
      case 'MEDIUM':
      case 'MODERATE':
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }
}
