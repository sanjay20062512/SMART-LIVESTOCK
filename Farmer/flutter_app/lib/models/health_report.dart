// Health Report data model

enum RiskLevel { low, medium, high, critical }

enum CaseStatus {
  open,
  underReview,
  vetAssigned,
  visitScheduled,
  sampleCollected,
  labReferred,
  investigation,
  treatmentStarted,
  escalated,
  closed
}

extension RiskLevelExt on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.medium:
        return 'MEDIUM';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.critical:
        return 'CRITICAL';
    }
  }
}

extension CaseStatusExt on CaseStatus {
  String get displayName {
    switch (this) {
      case CaseStatus.open:
        return 'Submitted';
      case CaseStatus.underReview:
        return 'Under Review';
      case CaseStatus.vetAssigned:
        return 'Vet Assigned';
      case CaseStatus.visitScheduled:
        return 'Visit Scheduled';
      case CaseStatus.sampleCollected:
        return 'Sample Collected';
      case CaseStatus.labReferred:
        return 'Lab Referred';
      case CaseStatus.investigation:
        return 'Investigation';
      case CaseStatus.treatmentStarted:
        return 'Treatment Started';
      case CaseStatus.escalated:
        return 'Escalated to Govt';
      case CaseStatus.closed:
        return 'Case Closed';
    }
  }
}

class HealthReport {
  final String id;
  final String animalId;
  final String animalTag; // denormalised for display
  final String? species;
  final String? breed;
  final String? age;
  final List<String> symptoms;
  final String? duration; // "Today", "Yesterday", "2–3 days", etc.
  final String? eatingStatus; // "Yes", "Less than usual", "No", "Not sure"
  final String? drinkingStatus; // "Yes", "Less than usual", "No", "Not sure"
  final String? affectedCount; // "1", "2–5", "6–10", "More than 10"
  final bool? isPregnant;
  final bool? isLactating;
  final RiskLevel riskLevel;
  final String title;
  final String advice;
  final String recommendedAction;
  final String? description;
  final String? photoPath; // placeholder
  final String? voicePath; // placeholder
  final bool hasVoiceNote;
  final bool hasPhoto;
  final bool hasVideo;
  final String? location;
  CaseStatus caseStatus;
  final DateTime createdAt;

  HealthReport({
    required this.id,
    required this.animalId,
    required this.animalTag,
    this.species,
    this.breed,
    this.age,
    required this.symptoms,
    this.duration,
    this.eatingStatus,
    this.drinkingStatus,
    this.affectedCount,
    this.isPregnant,
    this.isLactating,
    required this.riskLevel,
    required this.title,
    required this.advice,
    required this.recommendedAction,
    this.description,
    this.photoPath,
    this.voicePath,
    this.hasVoiceNote = false,
    this.hasPhoto = false,
    this.hasVideo = false,
    this.location,
    this.caseStatus = CaseStatus.open,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'animalTag': animalTag,
        'species': species,
        'breed': breed,
        'age': age,
        'symptoms': symptoms,
        'duration': duration,
        'eatingStatus': eatingStatus,
        'drinkingStatus': drinkingStatus,
        'affectedCount': affectedCount,
        'isPregnant': isPregnant,
        'isLactating': isLactating,
        'riskLevel': riskLevel.name,
        'title': title,
        'advice': advice,
        'recommendedAction': recommendedAction,
        'description': description,
        'hasVoiceNote': hasVoiceNote,
        'hasPhoto': hasPhoto,
        'hasVideo': hasVideo,
        'location': location,
        'caseStatus': caseStatus.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
