// Government Alert model — synchronized from Veterinary clusters

import 'cluster.dart';

enum GovernmentAlertStatus { newAlert, acknowledged, underResponse, resolved }

extension GovernmentAlertStatusExt on GovernmentAlertStatus {
  String get displayName {
    switch (this) {
      case GovernmentAlertStatus.newAlert:
        return 'NEW ALERT';
      case GovernmentAlertStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case GovernmentAlertStatus.underResponse:
        return 'UNDER RESPONSE';
      case GovernmentAlertStatus.resolved:
        return 'RESOLVED';
    }
  }
}

class GovernmentAlert {
  final String id;
  final String clusterId;
  final String type; // e.g. "HIGH_RISK_OUTBREAK"
  ClusterRisk riskLevel;
  String title;
  String location;
  String district;
  String state;
  String species;
  int animalCount;
  int reportCount;
  int mortality;
  List<String> symptoms;
  String suspectedDisease;
  GovernmentAlertStatus status;
  final DateTime createdAt;
  DateTime? acknowledgedAt;
  String? acknowledgedBy;
  DateTime updatedAt;

  GovernmentAlert({
    required this.id,
    required this.clusterId,
    this.type = 'HIGH_RISK_OUTBREAK',
    required this.riskLevel,
    required this.title,
    required this.location,
    required this.district,
    required this.state,
    required this.species,
    required this.animalCount,
    required this.reportCount,
    required this.mortality,
    required this.symptoms,
    required this.suspectedDisease,
    this.status = GovernmentAlertStatus.newAlert,
    DateTime? createdAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'clusterId': clusterId,
        'type': type,
        'riskLevel': riskLevel.name,
        'title': title,
        'location': location,
        'district': district,
        'state': state,
        'species': species,
        'animalCount': animalCount,
        'reportCount': reportCount,
        'mortality': mortality,
        'symptoms': symptoms,
        'suspectedDisease': suspectedDisease,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'acknowledgedAt': acknowledgedAt?.toIso8601String(),
        'acknowledgedBy': acknowledgedBy,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
