// Veterinarian Request data model

import 'health_report.dart';

class VetTimelineEvent {
  final String status;
  final String description;
  final DateTime timestamp;

  VetTimelineEvent({
    required this.status,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class VetRequest {
  final String id;
  final String? animalId;
  final String animalTag; // denormalised for display
  final String reason;
  final String currentHealthStatus;
  final String? description;
  final DateTime? preferredDate;
  final String? preferredTime;
  CaseStatus caseStatus;
  final List<VetTimelineEvent> timeline;
  final DateTime createdAt;

  VetRequest({
    required this.id,
    this.animalId,
    required this.animalTag,
    required this.reason,
    required this.currentHealthStatus,
    this.description,
    this.preferredDate,
    this.preferredTime,
    this.caseStatus = CaseStatus.open,
    List<VetTimelineEvent>? timeline,
    DateTime? createdAt,
  })  : timeline = timeline ?? [],
        createdAt = createdAt ?? DateTime.now();

  void addTimelineEvent(String status, String description) {
    timeline.add(VetTimelineEvent(status: status, description: description));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'animalTag': animalTag,
        'reason': reason,
        'currentHealthStatus': currentHealthStatus,
        'description': description,
        'preferredDate': preferredDate?.toIso8601String(),
        'preferredTime': preferredTime,
        'caseStatus': caseStatus.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
