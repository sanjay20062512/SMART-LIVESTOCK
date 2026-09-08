// Government Module Design System
// Clean, premium, white-first design for a national animal health surveillance platform.

import 'package:flutter/material.dart';

// ─── Colour Palette ───────────────────────────────────────────────────────────

class GovtColors {
  GovtColors._();

  // Backgrounds
  static const Color pageBackground = Color(0xFFF7F9F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F4);

  // Text
  static const Color textPrimary = Color(0xFF173F3A);
  static const Color textSecondary = Color(0xFF65736F);
  static const Color textDisabled = Color(0xFFA0ACA9);

  // Brand - Deep Navy & Government Teal
  static const Color navyPrimary = Color(0xFF0B192C);
  static const Color navyDark = Color(0xFF060E18);
  static const Color navyCard = Color(0xFF132743);
  static const Color navyBorder = Color(0xFF1E3A5F);
  static const Color brand = Color(0xFF087F73);
  static const Color brandDark = Color(0xFF065E55);
  static const Color brandLight = Color(0xFFE0F2F0);
  static const Color accent = Color(0xFF7D9E38);
  static const Color accentLight = Color(0xFFEDF3D9);

  // Semantic & Risk severity (Heat Scale: Low 0-20%, Moderate 21-40%, Elevated 41-60%, High 61-80%, Critical 81-100%)
  static const Color riskLow = Color(0xFF2E7D5B);       // GREEN -> LOW (0–20%)
  static const Color riskModerate = Color(0xFFD98B00);  // YELLOW -> MODERATE (21–40%)
  static const Color riskElevated = Color(0xFFF57C00);  // ORANGE -> ELEVATED (41–60%)
  static const Color riskHigh = Color(0xFFE65100);      // DEEP ORANGE -> HIGH (61–80%)
  static const Color riskCritical = Color(0xFFC62828);  // RED -> CRITICAL (81–100%)
  static const Color riskSevere = Color(0xFF8B0000);    // DARK RED -> SEVERE OUTBREAK

  static Color getHeatmapColor(int score) {
    if (score <= 20) return riskLow;
    if (score <= 40) return riskModerate;
    if (score <= 60) return riskElevated;
    if (score <= 80) return riskHigh;
    return riskCritical;
  }

  static String getSeverityLabel(int score) {
    if (score <= 20) return 'LOW';
    if (score <= 40) return 'MODERATE';
    if (score <= 60) return 'ELEVATED';
    if (score <= 80) return 'HIGH';
    return 'CRITICAL';
  }

  static const Color critical = Color(0xFFC62828);
  static const Color criticalLight = Color(0xFFFDECEC);
  static const Color warning = Color(0xFFD98B00);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color success = Color(0xFF2E7D5B);
  static const Color successLight = Color(0xFFE8F5EE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3EEF9);

  // UI chrome
  static const Color border = Color(0xFFE3E9E7);
  static const Color divider = Color(0xFFEDF1F0);
  static const Color shadow = Color(0x0A173F3A);
}

// ─── Typography ────────────────────────────────────────────────────────────────

class GovtTypography {
  GovtTypography._();

  static const String fontFamily = 'Roboto';

  // Page title: 28–32px Bold
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: GovtColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.2,
  );

  // Section heading: 17–20px Semi-bold
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: GovtColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // Card title: 13–15px Medium/Semi-bold
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: GovtColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.3,
  );

  // Large KPI: 26–34px Bold
  static const TextStyle metricValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: GovtColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.1,
  );

  static const TextStyle metricLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: GovtColors.textSecondary,
    letterSpacing: 0.6,
    height: 1.3,
  );

  // Supporting text: 11–13px
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: GovtColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: GovtColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: GovtColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: GovtColors.textSecondary,
    letterSpacing: 0.6,
    height: 1.3,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.2,
  );
}

// ─── Spacing ───────────────────────────────────────────────────────────────────

class GovtSpacing {
  GovtSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(12);
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 16);
}

// ─── Radius ────────────────────────────────────────────────────────────────────

class GovtRadius {
  GovtRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
}

// ─── Risk colour helpers ────────────────────────────────────────────────────────

extension RiskLevelExt on String {
  Color get riskColor {
    switch (toUpperCase()) {
      case 'CRITICAL':
        return GovtColors.riskCritical;
      case 'HIGH':
        return GovtColors.riskHigh;
      case 'MEDIUM':
      case 'MODERATE':
        return GovtColors.riskModerate;
      default:
        return GovtColors.riskLow;
    }
  }

  Color get riskBgColor {
    switch (toUpperCase()) {
      case 'CRITICAL':
        return GovtColors.criticalLight;
      case 'HIGH':
        return const Color(0xFFFFF3E0);
      case 'MEDIUM':
      case 'MODERATE':
        return GovtColors.warningLight;
      default:
        return GovtColors.successLight;
    }
  }

  IconData get riskIcon {
    switch (toUpperCase()) {
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
