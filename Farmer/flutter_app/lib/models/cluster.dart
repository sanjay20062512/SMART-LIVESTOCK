// Outbreak Cluster model — used by Government surveillance module.
// Architecture note: ClusterDetectionService computes clusters from HealthReports.

enum ClusterRisk { possible, high, critical }
enum ClusterStatus { monitoring, investigation, escalated, contained }

extension ClusterRiskExt on ClusterRisk {
  String get displayName {
    switch (this) {
      case ClusterRisk.possible:
        return 'POSSIBLE CLUSTER';
      case ClusterRisk.high:
        return 'HIGH-RISK CLUSTER';
      case ClusterRisk.critical:
        return 'CRITICAL CLUSTER';
    }
  }
}

extension ClusterStatusExt on ClusterStatus {
  String get displayName {
    switch (this) {
      case ClusterStatus.monitoring:
        return 'Monitoring';
      case ClusterStatus.investigation:
        return 'Investigation';
      case ClusterStatus.escalated:
        return 'Escalated';
      case ClusterStatus.contained:
        return 'Contained';
    }
  }
}

class OutbreakCluster {
  final String clusterId;
  final String village;
  final String block;
  final String district;
  final String state;
  final String species; // Cow, Buffalo, Goat, etc.
  final List<String> commonSymptoms;
  final int reportCount;
  final int affectedAnimals;
  final int mortalityCount;
  final ClusterRisk risk;
  ClusterStatus status;
  final DateTime firstReportDate;
  final DateTime detectedAt;
  String? responseActionId;
  final List<String> caseIds; // related case IDs

  OutbreakCluster({
    required this.clusterId,
    required this.village,
    required this.block,
    required this.district,
    required this.state,
    required this.species,
    required this.commonSymptoms,
    required this.reportCount,
    required this.affectedAnimals,
    this.mortalityCount = 0,
    required this.risk,
    this.status = ClusterStatus.monitoring,
    required this.firstReportDate,
    DateTime? detectedAt,
    this.responseActionId,
    List<String>? caseIds,
  })  : detectedAt = detectedAt ?? DateTime.now(),
        caseIds = caseIds ?? [];

  Map<String, dynamic> toJson() => {
        'clusterId': clusterId,
        'village': village,
        'block': block,
        'district': district,
        'species': species,
        'reportCount': reportCount,
        'affectedAnimals': affectedAnimals,
        'risk': risk.name,
        'status': status.name,
        'detectedAt': detectedAt.toIso8601String(),
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

  String get emoji {
    switch (this) {
      case ResponseActionType.fieldVisit:
        return '🏥';
      case ResponseActionType.vaccinationDrive:
        return '💉';
      case ResponseActionType.sampleCollection:
        return '🔬';
      case ResponseActionType.awarenessCampaign:
        return '📢';
      case ResponseActionType.movementRestriction:
        return '🚫';
      case ResponseActionType.farmInspection:
        return '🔍';
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
