// LivestockCase — shared case model used by Farmer, Veterinary, and Government modules.
import '../services/localization_service.dart';

enum FullCaseStatus {
  submitted,
  underReview,
  vetAssigned,
  visitScheduled,
  investigation,
  sampleCollected,
  labReferred,
  treatmentStarted,
  followUpDue,
  escalated,
  monitoring,
  contained,
  caseClosed,
}

extension FullCaseStatusExt on FullCaseStatus {
  String get displayName {
    final lang = LocalizationService.instance.currentLanguage;
    switch (lang) {
      case AppLanguage.hindi:
        switch (this) {
          case FullCaseStatus.submitted:
            return 'दर्ज किया गया';
          case FullCaseStatus.underReview:
            return 'समीक्षाधीन';
          case FullCaseStatus.vetAssigned:
            return 'पशु चिकित्सक नियुक्त';
          case FullCaseStatus.visitScheduled:
            return 'दौरा निर्धारित';
          case FullCaseStatus.investigation:
            return 'जांच जारी';
          case FullCaseStatus.sampleCollected:
            return 'नमूना एकत्रित';
          case FullCaseStatus.labReferred:
            return 'प्रयोगशाला भेजा गया';
          case FullCaseStatus.treatmentStarted:
            return 'उपचार शुरू';
          case FullCaseStatus.followUpDue:
            return 'फॉलो-अप देय';
          case FullCaseStatus.escalated:
            return 'शासन को भेजा गया';
          case FullCaseStatus.monitoring:
            return 'निगरानी जारी';
          case FullCaseStatus.contained:
            return 'नियंत्रित';
          case FullCaseStatus.caseClosed:
            return 'केस बंद';
        }
      case AppLanguage.marathi:
        switch (this) {
          case FullCaseStatus.submitted:
            return 'नोंदवले गेले';
          case FullCaseStatus.underReview:
            return 'पुनरावलोकनाधीन';
          case FullCaseStatus.vetAssigned:
            return 'पशुवैद्यक नियुक्त';
          case FullCaseStatus.visitScheduled:
            return 'भेट नियोजित';
          case FullCaseStatus.investigation:
            return 'तपास सुरू';
          case FullCaseStatus.sampleCollected:
            return 'नमुना गोळा केला';
          case FullCaseStatus.labReferred:
            return 'प्रयोगशाळेत पाठवले';
          case FullCaseStatus.treatmentStarted:
            return 'उपचार सुरू';
          case FullCaseStatus.followUpDue:
            return 'फॉलो-अप बाकी';
          case FullCaseStatus.escalated:
            return 'शासकीय स्तरावर पाठवले';
          case FullCaseStatus.monitoring:
            return 'निरीक्षण सुरू';
          case FullCaseStatus.contained:
            return 'नियंत्रित';
          case FullCaseStatus.caseClosed:
            return 'प्रकरण बंद';
        }
      case AppLanguage.english:
        switch (this) {
          case FullCaseStatus.submitted:
            return 'Submitted';
          case FullCaseStatus.underReview:
            return 'Under Review';
          case FullCaseStatus.vetAssigned:
            return 'Vet Assigned';
          case FullCaseStatus.visitScheduled:
            return 'Visit Scheduled';
          case FullCaseStatus.investigation:
            return 'Investigation';
          case FullCaseStatus.sampleCollected:
            return 'Sample Collected';
          case FullCaseStatus.labReferred:
            return 'Lab Referred';
          case FullCaseStatus.treatmentStarted:
            return 'Treatment Started';
          case FullCaseStatus.followUpDue:
            return 'Follow-up Due';
          case FullCaseStatus.escalated:
            return 'Escalated';
          case FullCaseStatus.monitoring:
            return 'Monitoring';
          case FullCaseStatus.contained:
            return 'Contained';
          case FullCaseStatus.caseClosed:
            return 'Case Closed';
        }
    }
  }

  bool get isActive => this != FullCaseStatus.caseClosed && this != FullCaseStatus.contained;
  bool get isCritical =>
      this == FullCaseStatus.escalated || this == FullCaseStatus.labReferred;
}

class CaseTimelineEvent {
  final String status;
  final String description;
  final DateTime timestamp;
  final String? actor; // 'Farmer', 'Veterinarian', 'Government'

  CaseTimelineEvent({
    required this.status,
    required this.description,
    DateTime? timestamp,
    this.actor,
  }) : timestamp = timestamp ?? DateTime.now();
}

class LivestockCase {
  final String caseId;
  final String reportId;
  final String farmerId;
  final String farmerName;
  final String farmName;
  final String? farmId;
  final String animalId;
  final String animalTag;
  final String species;
  final String? breed;
  final String? age;
  final String? gender;
  final List<String> symptoms;
  final String? duration;
  final String? affectedCount;
  final String? otherAnimalsAffected;
  final String? nearbyFarmsAffected;
  final String? recentMovement;
  final String riskLevel; // LOW / MEDIUM / HIGH / CRITICAL
  final String village;
  final String block;
  final String district;
  final String state;
  final double? latitude;
  final double? longitude;
  final bool hasVoiceNote;
  final String? voiceNoteUrl;
  final bool hasPhoto;
  final List<String>? photoUrls;
  final bool hasVideo;
  final String? videoUrl;
  final String? voiceTranscript;
  final String? localVoicePath;
  final String? localPhotoPath;
  final String? localVideoPath;
  FullCaseStatus status;
  String? assignedVetId;
  String? assignedVetName;
  DateTime? visitScheduledDate;
  String? clinicalObservation;
  String? treatmentSummary;
  String? sampleId;
  bool isEscalatedToGovt;
  final List<CaseTimelineEvent> timeline;
  final DateTime createdAt;
  DateTime updatedAt;

  LivestockCase({
    required this.caseId,
    required this.reportId,
    required this.farmerId,
    required this.farmerName,
    required this.farmName,
    this.farmId,
    required this.animalId,
    required this.animalTag,
    required this.species,
    this.breed,
    this.age,
    this.gender,
    required this.symptoms,
    this.duration,
    this.affectedCount,
    this.otherAnimalsAffected,
    this.nearbyFarmsAffected,
    this.recentMovement,
    required this.riskLevel,
    required this.village,
    required this.block,
    required this.district,
    required this.state,
    this.latitude,
    this.longitude,
    this.hasVoiceNote = false,
    this.voiceNoteUrl,
    this.hasPhoto = false,
    this.photoUrls,
    this.hasVideo = false,
    this.videoUrl,
    this.voiceTranscript,
    this.localVoicePath,
    this.localPhotoPath,
    this.localVideoPath,
    this.status = FullCaseStatus.submitted,
    this.assignedVetId,
    this.assignedVetName,
    this.visitScheduledDate,
    this.clinicalObservation,
    this.treatmentSummary,
    this.sampleId,
    this.isEscalatedToGovt = false,
    List<CaseTimelineEvent>? timeline,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : timeline = timeline ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  void addTimelineEvent(String status, String description, {String? actor}) {
    timeline.add(CaseTimelineEvent(
      status: status,
      description: description,
      actor: actor,
    ));
    updatedAt = DateTime.now();
  }

  bool get isCritical => riskLevel == 'CRITICAL';
  bool get isHigh => riskLevel == 'HIGH';

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
        'reportId': reportId,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'species': species,
        'breed': breed,
        'symptoms': symptoms,
        'riskLevel': riskLevel,
        'status': status.name,
        'village': village,
        'district': district,
        'createdAt': createdAt.toIso8601String(),
      };
}
