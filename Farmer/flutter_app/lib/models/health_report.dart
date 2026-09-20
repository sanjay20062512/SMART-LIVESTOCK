// Health Report data model
import '../services/localization_service.dart';

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
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case RiskLevel.low:
            return 'कम जोखिम';
          case RiskLevel.medium:
            return 'मध्यम जोखिम';
          case RiskLevel.high:
            return 'उच्च जोखिम';
          case RiskLevel.critical:
            return 'गंभीर जोखिम';
        }
      case AppLanguage.marathi:
        switch (this) {
          case RiskLevel.low:
            return 'कमी जोखीम';
          case RiskLevel.medium:
            return 'मध्यम जोखीम';
          case RiskLevel.high:
            return 'उच्च जोखीम';
          case RiskLevel.critical:
            return 'गंभीर जोखीम';
        }
      case AppLanguage.english:
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
}

extension CaseStatusExt on CaseStatus {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case CaseStatus.open:
            return 'दर्ज किया गया';
          case CaseStatus.underReview:
            return 'समीक्षाधीन';
          case CaseStatus.vetAssigned:
            return 'पशु चिकित्सक नियुक्त';
          case CaseStatus.visitScheduled:
            return 'दौरा निर्धारित';
          case CaseStatus.sampleCollected:
            return 'नमूना एकत्रित';
          case CaseStatus.labReferred:
            return 'प्रयोगशाला भेजा गया';
          case CaseStatus.investigation:
            return 'जांच जारी';
          case CaseStatus.treatmentStarted:
            return 'उपचार शुरू';
          case CaseStatus.escalated:
            return 'शासन को भेजा गया';
          case CaseStatus.closed:
            return 'केस बंद';
        }
      case AppLanguage.marathi:
        switch (this) {
          case CaseStatus.open:
            return 'नोंदवले गेले';
          case CaseStatus.underReview:
            return 'पुनरावलोकनाधीन';
          case CaseStatus.vetAssigned:
            return 'पशुवैद्यक नियुक्त';
          case CaseStatus.visitScheduled:
            return 'भेट नियोजित';
          case CaseStatus.sampleCollected:
            return 'नमुना गोळा केला';
          case CaseStatus.labReferred:
            return 'प्रयोगशाळेत पाठवले';
          case CaseStatus.investigation:
            return 'तपास सुरू';
          case CaseStatus.treatmentStarted:
            return 'उपचार सुरू';
          case CaseStatus.escalated:
            return 'शासकीय स्तरावर पाठवले';
          case CaseStatus.closed:
            return 'प्रकरण बंद';
        }
      case AppLanguage.english:
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
  final String? photoPath;
  final String? voicePath;
  final String? videoPath;
  final String? voiceTranscript;
  final String? voiceUrl;
  final List<String>? photoUrls;
  final String? videoUrl;
  final bool hasVoiceNote;
  final bool hasPhoto;
  final bool hasVideo;
  final String? location;
  final double? latitude;
  final double? longitude;
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
    this.videoPath,
    this.voiceTranscript,
    this.voiceUrl,
    this.photoUrls,
    this.videoUrl,
    this.hasVoiceNote = false,
    this.hasPhoto = false,
    this.hasVideo = false,
    this.location,
    this.latitude,
    this.longitude,
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
        'photoPath': photoPath,
        'voicePath': voicePath,
        'videoPath': videoPath,
        'voiceTranscript': voiceTranscript,
        'voiceUrl': voiceUrl,
        'photoUrls': photoUrls,
        'videoUrl': videoUrl,
        'hasVoiceNote': hasVoiceNote,
        'hasPhoto': hasPhoto,
        'hasVideo': hasVideo,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'caseStatus': caseStatus.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
