// Triage Service — Rule-based health risk assessment prototype.
//
// IMPORTANT: This is a prototype rule-based system only.
// It is NOT a medically validated AI system.
// This service is structured so a future AI disease risk model
// or API can replace the rule logic without changing callers.

import '../models/health_report.dart';

/// Result returned by the triage engine.
class TriageResult {
  final RiskLevel riskLevel;
  final String title;
  final String advice;
  final String recommendedAction;

  const TriageResult({
    required this.riskLevel,
    required this.title,
    required this.advice,
    required this.recommendedAction,
  });
}

/// Critical symptoms in farmer-friendly terminology
const List<String> _criticalSymptoms = [
  'Breathing problem',
  'Excessive salivation',
  'Weakness',
  'Skin lesions',
  'Bleeding',
  'Breathing difficulty', // backward compat
];

class TriageService {
  TriageService._();

  /// Assess symptoms and parameters reported by the farmer.
  static TriageResult assess({
    required List<String> symptoms,
    String? affectedCount,
    bool isMortalityRelated = false,
    bool notEating = false,
    bool notDrinking = false,
  }) {
    if (isMortalityRelated) {
      return const TriageResult(
        riskLevel: RiskLevel.critical,
        title: 'CRITICAL HEALTH RISK',
        advice: 'Animal death reported. Please avoid moving animals from the affected area.',
        recommendedAction: 'Keep other animals isolated. Contact a veterinarian immediately for investigation.',
      );
    }

    if (symptoms.isEmpty) {
      return const TriageResult(
        riskLevel: RiskLevel.low,
        title: 'LOW HEALTH RISK',
        advice: 'Continue monitoring the animal.',
        recommendedAction: 'Keep observing the animal daily. Ensure clean water and feed.',
      );
    }

    // Check critical symptom matches (support icon labels and clean names)
    final criticalMatches = symptoms.where((s) {
      final clean = s.replaceAll(RegExp(r'^[^\w]+'), '').trim().toLowerCase();
      return _criticalSymptoms.any((cs) =>
          clean.contains(cs.toLowerCase()) || cs.toLowerCase().contains(clean));
    }).length;

    final isMultipleAffected = affectedCount != null &&
        (affectedCount.contains('2–5') ||
         affectedCount.contains('6–10') ||
         affectedCount.contains('More than 10') ||
         affectedCount.contains('2-5') ||
         affectedCount.contains('6-10') ||
         affectedCount.contains('10'));

    // 1. CRITICAL
    if (criticalMatches >= 2 || (criticalMatches >= 1 && isMultipleAffected)) {
      return const TriageResult(
        riskLevel: RiskLevel.critical,
        title: 'CRITICAL HEALTH RISK',
        advice: 'Immediate veterinary attention is required. Isolate the animal now.',
        recommendedAction:
            'Please keep the affected animal separate from the herd and contact a veterinarian urgently. Avoid moving other animals.',
      );
    }

    // 2. HIGH
    if (criticalMatches >= 1 || symptoms.length >= 3 || isMultipleAffected || (notEating && notDrinking)) {
      return const TriageResult(
        riskLevel: RiskLevel.high,
        title: 'HIGH HEALTH RISK',
        advice: 'Please isolate the affected animal and contact a veterinarian.',
        recommendedAction:
            'Separate this animal to prevent disease spread. Request veterinarian assistance and provide clean drinking water.',
      );
    }

    // 3. MEDIUM
    if (symptoms.length >= 2 || notEating || notDrinking) {
      return const TriageResult(
        riskLevel: RiskLevel.medium,
        title: 'MEDIUM HEALTH RISK',
        advice: 'Monitor the animal closely and prepare to contact a veterinarian if needed.',
        recommendedAction:
            'Check the animal twice daily. Provide adequate feed, clean water, and shelter.',
      );
    }

    // 4. LOW
    return const TriageResult(
      riskLevel: RiskLevel.low,
      title: 'LOW HEALTH RISK',
      advice: 'Continue monitoring the animal.',
      recommendedAction:
          'No immediate action needed. Keep observing the animal and check again tomorrow.',
    );
  }
}
