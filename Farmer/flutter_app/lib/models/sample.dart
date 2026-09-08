// Sample collection and laboratory referral model

enum SampleStatus {
  recommended,
  collected,
  sentToLab,
  resultAvailable,
}

extension SampleStatusExt on SampleStatus {
  String get displayName {
    switch (this) {
      case SampleStatus.recommended:
        return 'Recommended';
      case SampleStatus.collected:
        return 'Collected';
      case SampleStatus.sentToLab:
        return 'Sent to Lab';
      case SampleStatus.resultAvailable:
        return 'Result Available';
    }
  }
}

class Sample {
  final String sampleId;
  final String caseId;
  final String animalId;
  final String animalTag;
  final String sampleType; // Blood, Faecal, Nasal swab, Tissue, etc.
  final String collectionDate;
  final String collectionLocation;
  final String reason;
  final String? laboratory;
  SampleStatus status;
  String? resultSummary;
  String? resultDate;
  final String collectedBy; // Vet name
  final DateTime createdAt;

  Sample({
    required this.sampleId,
    required this.caseId,
    required this.animalId,
    required this.animalTag,
    required this.sampleType,
    required this.collectionDate,
    required this.collectionLocation,
    required this.reason,
    this.laboratory,
    this.status = SampleStatus.recommended,
    this.resultSummary,
    this.resultDate,
    required this.collectedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'sampleId': sampleId,
        'caseId': caseId,
        'animalId': animalId,
        'sampleType': sampleType,
        'status': status.name,
        'laboratory': laboratory,
        'collectedBy': collectedBy,
        'createdAt': createdAt.toIso8601String(),
      };
}
