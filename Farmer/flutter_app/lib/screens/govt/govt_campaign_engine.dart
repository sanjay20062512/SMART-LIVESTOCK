// Smart Livestock — Government Campaign Priority Engine
// Decoupled rule-based priority and gap intelligence connecting
// epidemiological disease risk with district & village vaccination coverage.
// Can be substituted with an AI / backend ML inference endpoint.

enum CampaignPriority {
  critical,
  high,
  normal,
  monitoring,
}

extension CampaignPriorityX on CampaignPriority {
  String get label {
    switch (this) {
      case CampaignPriority.critical:
        return 'CRITICAL';
      case CampaignPriority.high:
        return 'HIGH PRIORITY';
      case CampaignPriority.normal:
        return 'NORMAL';
      case CampaignPriority.monitoring:
        return 'MONITORING';
    }
  }

  String get shortLabel {
    switch (this) {
      case CampaignPriority.critical:
        return 'Critical';
      case CampaignPriority.high:
        return 'High';
      case CampaignPriority.normal:
        return 'Normal';
      case CampaignPriority.monitoring:
        return 'Monitoring';
    }
  }
}

class CampaignSimulationResult {
  final int beforeRisk;
  final int afterRisk;
  final int beforeCoverage;
  final int afterCoverage;
  final String note;

  const CampaignSimulationResult({
    required this.beforeRisk,
    required this.afterRisk,
    required this.beforeCoverage,
    required this.afterCoverage,
    this.note = 'DEMO / MOCK DATA — Epidemiological simulation for response planning.',
  });

  int get riskReduction => (beforeRisk - afterRisk).clamp(0, 100);
  int get coverageGain => (afterCoverage - beforeCoverage).clamp(0, 100);
}

class GovtCampaignEngine {
  GovtCampaignEngine._();

  /// Standard herd immunity coverage threshold
  static const int standardCoverageTarget = 85;

  /// Evaluates campaign priority based on disease risk score and vaccination coverage
  static CampaignPriority evaluatePriority({
    required int riskScore,
    required int vaccinationCoverage,
  }) {
    if (riskScore >= 75 && vaccinationCoverage < 70) {
      return CampaignPriority.critical;
    } else if (riskScore >= 60 || vaccinationCoverage < 60) {
      return CampaignPriority.high;
    } else if (riskScore >= 40) {
      return CampaignPriority.normal;
    } else {
      return CampaignPriority.monitoring;
    }
  }

  /// Calculates percentage coverage gap against target (default 85%)
  static int calculateCoverageGap(int currentCoverage, {int target = standardCoverageTarget}) {
    final gap = target - currentCoverage;
    return gap > 0 ? gap : 0;
  }

  /// Determines if a district has an urgent vaccination gap
  static bool hasVaccinationGap({
    required int riskScore,
    required int vaccinationCoverage,
  }) {
    return (riskScore >= 60 && vaccinationCoverage < 75) || vaccinationCoverage < 55;
  }

  /// Formulates targeted operational recommendation
  static String getRecommendation({
    required String district,
    required String disease,
    required int riskScore,
    required int vaccinationCoverage,
  }) {
    if (district.toLowerCase() == 'pune' || disease == 'FMD') {
      return 'Launch targeted FMD vaccination campaign.';
    } else if (district.toLowerCase() == 'nashik' || disease == 'Brucellosis') {
      return 'Increase vaccination coverage.';
    } else if (riskScore >= 70) {
      return 'Immediate ring vaccination buffer recommended.';
    } else if (vaccinationCoverage < 60) {
      return 'Intensify active door-to-door herd immunization.';
    } else {
      return 'Continue routine surveillance and maintain coverage.';
    }
  }

  /// Simulates district disease risk reduction upon reaching campaign target coverage
  /// Strictly marked as DEMO / MOCK DATA
  static CampaignSimulationResult simulateRiskReduction({
    required int currentRisk,
    required int currentCoverage,
    required int targetCoverage,
  }) {
    final gain = (targetCoverage - currentCoverage).clamp(0, 100);
    // Demo rule: e.g. Before 78% -> After 64% for 61% -> 82%
    final rawDrop = (gain * 0.67).round();
    final afterRisk = (currentRisk - rawDrop).clamp(20, 100);

    return CampaignSimulationResult(
      beforeRisk: currentRisk,
      afterRisk: afterRisk,
      beforeCoverage: currentCoverage,
      afterCoverage: targetCoverage,
    );
  }
}
