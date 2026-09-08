// Outbreak Cluster model — used by Veterinary & Government surveillance modules.

import 'package:flutter/material.dart';

enum ClusterRisk { low, medium, high }
enum ClusterStatus { newStatus, investigation, monitoring, resolved, escalated, contained }

extension ClusterRiskExt on ClusterRisk {
  String get displayName {
    switch (this) {
      case ClusterRisk.low:
        return 'LOW RISK';
      case ClusterRisk.medium:
        return 'MEDIUM RISK';
      case ClusterRisk.high:
        return 'HIGH RISK';
    }
  }

  String get shortName {
    switch (this) {
      case ClusterRisk.low:
        return 'Low';
      case ClusterRisk.medium:
        return 'Medium';
      case ClusterRisk.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case ClusterRisk.low:
        return const Color(0xFF2E7D32); // Green
      case ClusterRisk.medium:
        return const Color(0xFFE65100); // Orange/Amber
      case ClusterRisk.high:
        return const Color(0xFFB71C1C); // Dark Red
    }
  }

  Color get bgColor {
    switch (this) {
      case ClusterRisk.low:
        return const Color(0xFFE8F5E9);
      case ClusterRisk.medium:
        return const Color(0xFFFFF3E0);
      case ClusterRisk.high:
        return const Color(0xFFFFEBEE);
    }
  }
}

extension ClusterStatusExt on ClusterStatus {
  String get displayName {
    switch (this) {
      case ClusterStatus.newStatus:
        return 'New';
      case ClusterStatus.investigation:
        return 'Investigation';
      case ClusterStatus.monitoring:
        return 'Monitoring';
      case ClusterStatus.resolved:
        return 'Resolved';
      case ClusterStatus.escalated:
        return 'Escalated';
      case ClusterStatus.contained:
        return 'Contained';
    }
  }
}

class OutbreakCluster {
  final String clusterId;
  final String name;
  final String location;
  final String village;
  final String block;
  final String district;
  final String state;
  final double? latitude;
  final double? longitude;
  ClusterRisk riskLevel;
  final String species; // Cattle, Buffalo, Goat, Sheep, Poultry, Other
  final int reportCount;
  final int animalCount;
  final int mortality;
  final List<String> symptoms;
  final String suspectedDisease;
  final String description;
  ClusterStatus status;
  final DateTime detectedAt;
  final String createdBy;
  final DateTime createdAt;
  DateTime updatedAt;
  String? responseActionId;
  final List<String> caseIds;

  OutbreakCluster({
    required this.clusterId,
    String? name,
    String? location,
    required this.village,
    required this.block,
    required this.district,
    required this.state,
    this.latitude,
    this.longitude,
    ClusterRisk? riskLevel,
    ClusterRisk? risk,
    required this.species,
    required this.reportCount,
    int? animalCount,
    int? affectedAnimals,
    int? mortality,
    int? mortalityCount,
    List<String>? symptoms,
    List<String>? commonSymptoms,
    String? suspectedDisease,
    String? description,
    this.status = ClusterStatus.monitoring,
    DateTime? detectedAt,
    DateTime? firstReportDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.responseActionId,
    List<String>? caseIds,
  })  : name = name ?? '$village ${species.split(" ").first} Cluster',
        location = location ?? '$village, $district',
        riskLevel = riskLevel ?? risk ?? ClusterRisk.medium,
        animalCount = animalCount ?? affectedAnimals ?? 0,
        mortality = mortality ?? mortalityCount ?? 0,
        symptoms = symptoms ?? commonSymptoms ?? [],
        suspectedDisease = suspectedDisease ?? 'Suspected Outbreak',
        description = description ?? 'Cluster detected in $village village.',
        detectedAt = detectedAt ?? firstReportDate ?? DateTime.now(),
        createdBy = createdBy ?? 'System / Veterinarian',
        createdAt = createdAt ?? firstReportDate ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        caseIds = caseIds ?? [];

  // Backward compatibility getters
  ClusterRisk get risk => riskLevel;
  int get affectedAnimals => animalCount;
  int get mortalityCount => mortality;
  List<String> get commonSymptoms => symptoms;
  DateTime get firstReportDate => detectedAt;

  Map<String, dynamic> toJson() => {
        'clusterId': clusterId,
        'name': name,
        'location': location,
        'village': village,
        'block': block,
        'district': district,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'riskLevel': riskLevel.name,
        'species': species,
        'reportCount': reportCount,
        'animalCount': animalCount,
        'mortality': mortality,
        'symptoms': symptoms,
        'suspectedDisease': suspectedDisease,
        'description': description,
        'status': status.name,
        'detectedAt': detectedAt.toIso8601String(),
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// Response Action — government creates these in response to clusters
enum ResponseActionType {
  fieldVisit,
  vaccinationDrive,
  sampleCollection,
  awarenessCampaign,
  movementRestriction,
  farmInspection,
}

enum ResponseActionStatus { planned, assigned, inProgress, completed }

extension ResponseActionTypeExt on ResponseActionType {
  String get displayName {
    switch (this) {
      case ResponseActionType.fieldVisit:
        return 'Veterinary Field Visit';
      case ResponseActionType.vaccinationDrive:
        return 'Vaccination Drive';
      case ResponseActionType.sampleCollection:
        return 'Sample Collection';
      case ResponseActionType.awarenessCampaign:
        return 'Awareness Campaign';
      case ResponseActionType.movementRestriction:
        return 'Movement Restriction Advisory';
      case ResponseActionType.farmInspection:
        return 'Farm Inspection';
    }
  }

  String get emoji => '';

  IconData get icon {
    switch (this) {
      case ResponseActionType.fieldVisit:
        return Icons.local_hospital;
      case ResponseActionType.vaccinationDrive:
        return Icons.vaccines;
      case ResponseActionType.sampleCollection:
        return Icons.science;
      case ResponseActionType.awarenessCampaign:
        return Icons.campaign;
      case ResponseActionType.movementRestriction:
        return Icons.block;
      case ResponseActionType.farmInspection:
        return Icons.search;
    }
  }
}

class ResponseAction {
  final String actionId;
  final String clusterId;
  final ResponseActionType type;
  final String title;
  final String description;
  final String location;
  final String? assignedTo;
  ResponseActionStatus status;
  final DateTime createdAt;
  DateTime? completedAt;

  ResponseAction({
    required this.actionId,
    required this.clusterId,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    this.assignedTo,
    this.status = ResponseActionStatus.planned,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
