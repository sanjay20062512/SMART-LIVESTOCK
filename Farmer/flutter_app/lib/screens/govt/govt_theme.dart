// Smart Livestock — Government Module Design System
// Completely light, clean, trustworthy, and visually consistent with Farmer & Veterinary modules.

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GovtColors {
  GovtColors._();

  // Backgrounds & Surfaces (Clean Light Theme)
  static const Color pageBackground = AppColors.background; // #F8FAFC
  static const Color surface = AppColors.surface;           // #FFFFFF
  static const Color surfaceSubtle = AppColors.surfaceSubtle; // #F1F5F9

  // Text Hierarchy
  static const Color textPrimary = AppColors.textPrimary;     // #111827
  static const Color textSecondary = AppColors.textSecondary; // #4B5563
  static const Color textMuted = AppColors.textMuted;         // #6B7280
  static const Color textDisabled = AppColors.textDisabled;   // #9CA3AF

  // Institutional Brand (Teal - Shared with Farmer/Vet)
  static const Color brand = AppColors.primary;               // #0D9488
  static const Color brandDark = AppColors.primaryDark;       // #0F766E
  static const Color brandLight = AppColors.primaryLight;     // #CCFBF1
  static const Color brandFaint = AppColors.primaryFaint;     // #EFFEFD

  // 4-Tier Disease Risk Heat Scale (User Specified)
  // LOW: 0–30% (Green)
  static const Color riskLow = Color(0xFF16A34A);
  static const Color riskLowLight = Color(0xFFDCFCE7);

  // MEDIUM: 31–55% (Yellow/Amber)
  static const Color riskMedium = Color(0xFFD97706);
  static const Color riskModerate = riskMedium;
  static const Color riskMediumLight = Color(0xFFFEF3C7);

  // HIGH: 56–75% (Orange)
  static const Color riskHigh = Color(0xFFE65100);
  static const Color riskHighLight = Color(0xFFFFEDD5);

  // CRITICAL: 76–100% (Red)
  static const Color riskCritical = Color(0xFFDC2626);
  static const Color riskCriticalLight = Color(0xFFFEE2E2);

  static Color getHeatmapColor(int score) {
    if (score <= 30) return riskLow;
    if (score <= 55) return riskMedium;
    if (score <= 75) return riskHigh;
    return riskCritical;
  }

  static Color getHeatmapLightColor(int score) {
    if (score <= 30) return riskLowLight;
    if (score <= 55) return riskMediumLight;
    if (score <= 75) return riskHighLight;
    return riskCriticalLight;
  }

  static String getSeverityLabel(int score) {
    if (score <= 30) return 'LOW';
    if (score <= 55) return 'MEDIUM';
    if (score <= 75) return 'HIGH';
    return 'CRITICAL';
  }

  // UI Chrome & Borders
  static const Color border = AppColors.border;             // #E5E7EB
  static const Color divider = AppColors.divider;           // #F3F4F6
  static const Color shadow = Color(0x0A111827);

  // Semantics
  static const Color critical = riskCritical;
  static const Color criticalLight = riskCriticalLight;
  static const Color warning = riskMedium;
  static const Color warningLight = riskMediumLight;
  static const Color success = riskLow;
  static const Color successLight = riskLowLight;
  static const Color info = AppColors.info;
  static const Color infoLight = AppColors.infoLight;
  // Legacy Compatibility Tokens
  static const Color accent = brand;
  static const Color riskSevere = riskCritical;
  static const Color navyPrimary = Color(0xFF0F172A);
  static const Color navyCard = Color(0xFF1E293B);
  static const Color navyBorder = Color(0xFF334155);
}

extension GovtRiskStringExtension on String {
  Color get riskColor {
    final lower = toLowerCase();
    if (lower.contains('critical') || lower.contains('severe') || lower.contains('red')) {
      return GovtColors.riskCritical;
    }
    if (lower.contains('high') || lower.contains('orange')) {
      return GovtColors.riskHigh;
    }
    if (lower.contains('medium') || lower.contains('moderate') || lower.contains('warning') || lower.contains('yellow')) {
      return GovtColors.riskMedium;
    }
    return GovtColors.riskLow;
  }

  Color get riskBgColor {
    final lower = toLowerCase();
    if (lower.contains('critical') || lower.contains('severe') || lower.contains('red')) {
      return GovtColors.riskCriticalLight;
    }
    if (lower.contains('high') || lower.contains('orange')) {
      return GovtColors.riskHighLight;
    }
    if (lower.contains('medium') || lower.contains('moderate') || lower.contains('warning') || lower.contains('yellow')) {
      return GovtColors.riskMediumLight;
    }
    return GovtColors.riskLowLight;
  }
}

class GovtTypography {
  GovtTypography._();

  static const String fontFamily = 'Roboto';

  // Page title: 24–28px, semibold/bold
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: GovtColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // Section title: 16–18px, semibold
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: GovtColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.3,
  );

  // Card title: 14–16px, semibold
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: GovtColors.textPrimary,
    letterSpacing: 0,
    height: 1.35,
  );

  // Large KPI Number: 20–26px, bold
  static const TextStyle metricValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: GovtColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.15,
  );

  // KPI Label: 11–12px, semibold
  static const TextStyle metricLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: GovtColors.textMuted,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // Body: 13–14px
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: GovtColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: GovtColors.textPrimary,
    height: 1.45,
  );

  // Supporting text / Caption: 11–12px
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: GovtColors.textSecondary,
    height: 1.35,
  );

  // Button text
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.2,
  );
}

class GovtRadius {
  GovtRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;

  static final BorderRadius xsRadius = BorderRadius.circular(xs);
  static final BorderRadius smRadius = BorderRadius.circular(sm);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius lgRadius = BorderRadius.circular(lg);
}

class GovtSpacing {
  GovtSpacing._();

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const EdgeInsets cardPadding = EdgeInsets.all(14);
}
