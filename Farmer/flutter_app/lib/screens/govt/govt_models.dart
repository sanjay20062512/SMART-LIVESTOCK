// Government Module — Domain Models
// Backend-ready model structures for govt-specific entities.
// These are isolated from the shared Farmer/Vet models.
// Future integration: Replace mock constructors with JSON factories from REST API.

import 'govt_campaign_engine.dart';

// ─── Vaccination Campaign ──────────────────────────────────────────────────────

enum CampaignStatus { planned, active, paused, completed }

class VillageCampaignData {
  final String name;
  final int target;
  int vaccinated;
  String status; // 'Completed', 'In Progress', 'Pending', 'Low Coverage'
  String? assignedTeam;
  final String recommendedAction;

  VillageCampaignData({
    required this.name,
    required this.target,
    required this.vaccinated,
    this.status = 'In Progress',
    this.assignedTeam,
    this.recommendedAction = 'Deploy additional vaccination team.',
  });

  double get coveragePercent => target > 0 ? (vaccinated / target * 100) : 0;
  int get remaining => (target - vaccinated).clamp(0, target);
  bool get isCompleted => vaccinated >= target || status == 'Completed';
  bool get hasLowCoverage => coveragePercent < 50;
}

class CampaignProgressPoint {
  final String dayLabel;
  final double coverage;

  const CampaignProgressPoint({
    required this.dayLabel,
    required this.coverage,
  });
}

class VaccinationCampaign {
  final String campaignId;
  final String name;
  final String disease;
  final String targetDistrict;
  final String targetBlock;
  final String targetVillages;
  final String animalSpecies;
  final DateTime startDate;
  final DateTime endDate;
  final int targetAnimals;
  final int vaccinatedAnimals;
  final List<String> assignedTeams;
  CampaignStatus status;
  final CampaignPriority priority;
  final int targetVillagesCount;
  final int completedVillagesCount;
  final int pendingVillagesCount;
  final List<VillageCampaignData> villages;
  final List<CampaignProgressPoint> timelinePoints;
  final DateTime createdAt;

  VaccinationCampaign({
    required this.campaignId,
    required this.name,
    required this.disease,
    required this.targetDistrict,
    required this.targetBlock,
    this.targetVillages = '',
    required this.animalSpecies,
    required this.startDate,
    required this.endDate,
    required this.targetAnimals,
    this.vaccinatedAnimals = 0,
    this.assignedTeams = const [],
    this.status = CampaignStatus.planned,
    this.priority = CampaignPriority.high,
    this.targetVillagesCount = 1,
    this.completedVillagesCount = 0,
    this.pendingVillagesCount = 1,
    this.villages = const [],
    this.timelinePoints = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get coveragePercent =>
      targetAnimals > 0 ? (vaccinatedAnimals / targetAnimals * 100) : 0;
  int get pendingAnimals => targetAnimals - vaccinatedAnimals;

  String get statusLabel {
    switch (status) {
      case CampaignStatus.planned:
        return 'Planned';
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.paused:
        return 'Paused';
      case CampaignStatus.completed:
        return 'Completed';
    }
  }
}

// ─── Lab Sample ────────────────────────────────────────────────────────────────

enum LabSampleStatus { collected, inTransit, received, underTesting, resultReady, completed }
enum LabSampleResult { pending, positive, negative, inconclusive }

class LabSample {
  final String sampleId;
  final String caseId;
  final String location;
  final String village;
  final String district;
  final String animalSpecies;
  final String suspectedDisease;
  final DateTime collectedAt;
  final String collectedBy;
  final String laboratory;
  LabSampleStatus status;
  LabSampleResult result;
  String? resultNotes;
  DateTime? resultDate;

  LabSample({
    required this.sampleId,
    required this.caseId,
    required this.location,
    required this.village,
    required this.district,
    required this.animalSpecies,
    required this.suspectedDisease,
    required this.collectedAt,
    required this.collectedBy,
    required this.laboratory,
    this.status = LabSampleStatus.collected,
    this.result = LabSampleResult.pending,
    this.resultNotes,
    this.resultDate,
  });

  String get statusLabel {
    switch (status) {
      case LabSampleStatus.collected:
        return 'Collected';
      case LabSampleStatus.inTransit:
        return 'In Transit';
      case LabSampleStatus.received:
        return 'Received';
      case LabSampleStatus.underTesting:
        return 'Under Testing';
      case LabSampleStatus.resultReady:
        return 'Result Ready';
      case LabSampleStatus.completed:
        return 'Completed';
    }
  }

  String get resultLabel {
    switch (result) {
      case LabSampleResult.pending:
        return 'Pending';
      case LabSampleResult.positive:
        return 'Positive';
      case LabSampleResult.negative:
        return 'Negative';
      case LabSampleResult.inconclusive:
        return 'Inconclusive';
    }
  }
}

// ─── Field Team ────────────────────────────────────────────────────────────────

enum FieldTeamStatus { available, enRoute, onSite, investigating, vaccinating, offline }

class FieldTeam {
  final String teamId;
  final String teamName;
  final List<String> members;
  final String currentDistrict;
  final String currentVillage;
  String currentAssignment;
  FieldTeamStatus status;
  DateTime lastSync;
  final String teamType; // 'Veterinary' | 'Vaccination' | 'Investigation'

  FieldTeam({
    required this.teamId,
    required this.teamName,
    required this.members,
    required this.currentDistrict,
    required this.currentVillage,
    this.currentAssignment = 'No active assignment',
    this.status = FieldTeamStatus.available,
    DateTime? lastSync,
    this.teamType = 'Veterinary',
  }) : lastSync = lastSync ?? DateTime.now();

  String get statusLabel {
    switch (status) {
      case FieldTeamStatus.available:
        return 'AVAILABLE';
      case FieldTeamStatus.enRoute:
        return 'EN ROUTE';
      case FieldTeamStatus.onSite:
        return 'ON SITE';
      case FieldTeamStatus.investigating:
        return 'INVESTIGATING';
      case FieldTeamStatus.vaccinating:
        return 'VACCINATING';
      case FieldTeamStatus.offline:
        return 'OFFLINE';
    }
  }
}

// ─── Government Report ─────────────────────────────────────────────────────────

enum ReportCategory {
  dailySurveillance,
  weeklyDiseaseSummary,
  outbreakReport,
  vaccinationReport,
  mortalityReport,
  laboratoryReport,
  districtHealthReport,
}

enum ReportStatus { generating, ready, failed }

class GovtReport {
  final String reportId;
  final ReportCategory category;
  final String title;
  final DateTime reportDate;
  final String coverage;
  final String generatedBy;
  final ReportStatus status;
  final DateTime createdAt;

  GovtReport({
    required this.reportId,
    required this.category,
    required this.title,
    required this.reportDate,
    required this.coverage,
    required this.generatedBy,
    this.status = ReportStatus.ready,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get categoryLabel {
    switch (category) {
      case ReportCategory.dailySurveillance:
        return 'Daily Surveillance';
      case ReportCategory.weeklyDiseaseSummary:
        return 'Weekly Disease Summary';
      case ReportCategory.outbreakReport:
        return 'Outbreak Report';
      case ReportCategory.vaccinationReport:
        return 'Vaccination Report';
      case ReportCategory.mortalityReport:
        return 'Mortality Report';
      case ReportCategory.laboratoryReport:
        return 'Laboratory Report';
      case ReportCategory.districtHealthReport:
        return 'District Health Report';
    }
  }
}

// ─── Government Stats (Executive KPI Summary) ─────────────────────────────────

class GovernmentStats {
  final int activeCases;
  final String activeCasesTrend;
  final int highRiskZones;
  final String highRiskZonesTrend;
  final int suspectedOutbreaks;
  final int suspectedOutbreaksCritical;
  final int animalsMonitored;
  final String animalsMonitoredTrend;
  final int vaccinationCoveragePercent;
  final int vaccinationTargetPercent;
  final int labSamplesPending;
  final int labSamplesTesting;
  final String districtHealthStatus; // NORMAL, ELEVATED, HIGH ALERT
  final String lastSyncMinutesAgo;

  const GovernmentStats({
    required this.activeCases,
    required this.activeCasesTrend,
    required this.highRiskZones,
    required this.highRiskZonesTrend,
    required this.suspectedOutbreaks,
    required this.suspectedOutbreaksCritical,
    required this.animalsMonitored,
    required this.animalsMonitoredTrend,
    required this.vaccinationCoveragePercent,
    required this.vaccinationTargetPercent,
    required this.labSamplesPending,
    required this.labSamplesTesting,
    required this.districtHealthStatus,
    required this.lastSyncMinutesAgo,
  });
}

// ─── Geospatial Risk Zone ──────────────────────────────────────────────────────

class RiskZone {
  final String id;
  final String village;
  final String block;
  final String district;
  final String riskLevel; // LOW, MODERATE, HIGH, CRITICAL
  final int activeCases;
  final int mortality;
  final int vaccinationCoverage;
  final String lastReportAgo;
  final String possibleDisease;
  final double normX; // 0.0 to 1.0 for geospatial canvas
  final double normY; // 0.0 to 1.0 for geospatial canvas
  final int trendPercent;
  final String trendDirection; // up, down, stable
  final List<String> contributingFactors;

  const RiskZone({
    required this.id,
    required this.village,
    required this.block,
    required this.district,
    required this.riskLevel,
    required this.activeCases,
    required this.mortality,
    required this.vaccinationCoverage,
    required this.lastReportAgo,
    required this.possibleDisease,
    required this.normX,
    required this.normY,
    required this.trendPercent,
    required this.trendDirection,
    this.contributingFactors = const [],
  });
}

// ─── Outbreak Command Record ──────────────────────────────────────────────────

class OutbreakRecord {
  final String id; // e.g. OB-024
  final String title;
  final String village;
  final String district;
  final int affectedAnimals;
  final int mortality;
  final int confidencePercent;
  final String status; // UNDER INVESTIGATION, FIELD RESPONSE ACTIVE, CONTAINED
  final String suspectedDisease;
  final String riskSeverity; // CRITICAL, HIGH, MODERATE
  final DateTime detectedAt;
  final List<String> assignedTeams;

  const OutbreakRecord({
    required this.id,
    required this.title,
    required this.village,
    required this.district,
    required this.affectedAnimals,
    required this.mortality,
    required this.confidencePercent,
    required this.status,
    required this.suspectedDisease,
    required this.riskSeverity,
    required this.detectedAt,
    this.assignedTeams = const [],
  });
}

// ─── Disease Trend Point ───────────────────────────────────────────────────────

class DiseaseTrendPoint {
  final String label;
  final int cases;
  final int mortality;
  final int recovery;
  final String disease;
  final String location;

  const DiseaseTrendPoint({
    required this.label,
    required this.cases,
    required this.mortality,
    required this.recovery,
    required this.disease,
    required this.location,
  });
}

// ─── Vaccination Intelligence Stats ───────────────────────────────────────────

class VaccinationStats {
  final int overallCoveragePercent;
  final int targetCoveragePercent;
  final int vaccinatedAnimals;
  final int pendingAnimals;
  final Map<String, int> districtCoverage;
  final List<String> priorityZones;

  const VaccinationStats({
    required this.overallCoveragePercent,
    required this.targetCoveragePercent,
    required this.vaccinatedAnimals,
    required this.pendingAnimals,
    required this.districtCoverage,
    required this.priorityZones,
  });
}

// ─── Government Alert Item ────────────────────────────────────────────────────

class GovernmentAlert {
  final String id;
  final String category; // CRITICAL, HIGH, ADVISORY, SYSTEM
  final String title;
  final String location;
  final String timeAgo;
  final String description;
  bool isRead;

  GovernmentAlert({
    required this.id,
    required this.category,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.description,
    this.isRead = false,
  });
}

// ─── State Risk Profile (India National Map) ──────────────────────────────────

class StateRiskProfile {
  final String code; // 'TN', 'KA', 'AP', 'KL', 'MH', 'UP', 'GJ', 'WB', 'MP', 'RJ'
  final String name;
  final int riskScore; // 0..100
  final String riskLevel; // 'CRITICAL', 'HIGH', 'MODERATE', 'LOW'
  final int activeCases;
  final int suspectedOutbreaks;
  final int confirmedOutbreaks;
  final int mortality;
  final int vaccinationCoverage;
  final String dominantDisease;
  final int trendPercent;
  final String trendDirection; // 'up', 'down', 'stable'
  final List<String> riskDrivers;
  final String recommendedAction;
  final double normX; // 0..1 on India map canvas
  final double normY; // 0..1 on India map canvas
  final List<DistrictRiskProfile> districts;

  const StateRiskProfile({
    required this.code,
    required this.name,
    required this.riskScore,
    required this.riskLevel,
    required this.activeCases,
    required this.suspectedOutbreaks,
    required this.confirmedOutbreaks,
    required this.mortality,
    required this.vaccinationCoverage,
    required this.dominantDisease,
    required this.trendPercent,
    required this.trendDirection,
    required this.riskDrivers,
    required this.recommendedAction,
    required this.normX,
    required this.normY,
    this.districts = const [],
  });
}

// ─── District Risk Profile ───────────────────────────────────────────────────

class DistrictRiskProfile {
  final String name;
  final String state;
  final int riskScore;
  final String riskLevel;
  final int cases;
  final int mortality;
  final int vaccinationCoverage;
  final String trend;
  final String primaryDisease;
  final List<String> whyHighRisk;
  final String recommendedAction;
  final double normX;
  final double normY;

  const DistrictRiskProfile({
    required this.name,
    required this.state,
    required this.riskScore,
    required this.riskLevel,
    required this.cases,
    required this.mortality,
    required this.vaccinationCoverage,
    required this.trend,
    this.primaryDisease = 'FMD',
    this.whyHighRisk = const [
      'Increasing reported cases',
      'Rising mortality rate',
      'Low vaccination coverage',
      'Recent historical pattern',
    ],
    this.recommendedAction = 'Prioritize field investigation and vaccination response.',
    this.normX = 0.5,
    this.normY = 0.5,
  });
}

// ─── Outbreak Workflow & Incident ────────────────────────────────────────────

enum OutbreakWorkflowStep {
  detected,
  investigating,
  sampleCollected,
  labTesting,
  confirmed,
  containmentActive,
  monitoring,
  resolved,
}

extension OutbreakWorkflowStepX on OutbreakWorkflowStep {
  String get label {
    switch (this) {
      case OutbreakWorkflowStep.detected:
        return 'Detected';
      case OutbreakWorkflowStep.investigating:
        return 'Investigating';
      case OutbreakWorkflowStep.sampleCollected:
        return 'Sample Collected';
      case OutbreakWorkflowStep.labTesting:
        return 'Lab Testing';
      case OutbreakWorkflowStep.confirmed:
        return 'Confirmed';
      case OutbreakWorkflowStep.containmentActive:
        return 'Containment Active';
      case OutbreakWorkflowStep.monitoring:
        return 'Monitoring';
      case OutbreakWorkflowStep.resolved:
        return 'Resolved';
    }
  }
}

class OutbreakResponseActionItem {
  final String title;
  final String status; // 'Pending', 'In Progress', 'Completed'
  const OutbreakResponseActionItem(this.title, this.status);
}

class OutbreakIncident {
  final String clusterId; // e.g. 'OB-024'
  final String disease;
  final String location;
  final int cases;
  final int mortality;
  final String trend; // '↑ 23%'
  final String status; // 'Investigating', 'Containment', 'Monitoring', 'Sample Collected'
  final String firstDetectedAgo;
  final int riskScore;
  final String riskLevel; // 'CRITICAL', 'HIGH', 'MODERATE'
  final OutbreakWorkflowStep currentStep;
  final String assignedTeam;
  final List<String> affectedVillages;
  final int vaccinationCoverage;
  final String labStatus;
  final Map<String, String> timeline;
  final List<OutbreakResponseActionItem> responseChecklist;

  const OutbreakIncident({
    required this.clusterId,
    required this.disease,
    required this.location,
    required this.cases,
    required this.mortality,
    this.trend = '↑ 23%',
    this.status = 'Investigating',
    required this.firstDetectedAgo,
    required this.riskScore,
    required this.riskLevel,
    required this.currentStep,
    required this.assignedTeam,
    this.affectedVillages = const ['Veeranam', 'Kavundampadi', 'Perundurai East', 'Bhavani South', 'Ingur', 'Chennimalai', 'Vijayamangalam'],
    this.vaccinationCoverage = 61,
    this.labStatus = 'Testing at TANUVAS Regional Lab',
    this.timeline = const {
      'First Report': '02 Sep',
      'Cluster Detected': '04 Sep',
      'Veterinarian Assigned': '05 Sep',
      'Sample Submitted': '06 Sep',
      'Current Status': 'Investigation',
    },
    required this.responseChecklist,
  });
}

// ─── Early Warning Notice ─────────────────────────────────────────────────────

class EarlyWarningNotice {
  final String id; // e.g. '#EW-018'
  final String headline;
  final String location;
  final String confidence; // 'High', 'Moderate'
  final List<String> supportingSignals;
  final String recommendedAction;
  final DateTime timestamp;

  const EarlyWarningNotice({
    required this.id,
    required this.headline,
    required this.location,
    required this.confidence,
    required this.supportingSignals,
    required this.recommendedAction,
    required this.timestamp,
  });
}

// ─── "Why is this area at risk?" Intelligence Analysis ────────────────────────

class RiskContributor {
  final String factor;
  final int percentage;
  final String description;
  const RiskContributor(this.factor, this.percentage, this.description);
}

class WhyRiskHighAnalysis {
  final String areaName;
  final int riskScore;
  final String riskLevel;
  final String dominantDisease;
  final String trend;
  final List<String> conciseReasons;
  final List<RiskContributor> contributors;
  final String recommendedAction;

  const WhyRiskHighAnalysis({
    required this.areaName,
    required this.riskScore,
    required this.riskLevel,
    this.dominantDisease = 'Foot-and-Mouth Disease (FMD)',
    this.trend = '↑ 23%',
    this.conciseReasons = const [
      '↑ 31% symptom reports',
      '↓ 14% vaccination coverage',
      '🌧 Heavy rainfall',
      '🐄 High livestock density',
    ],
    required this.contributors,
    this.recommendedAction = 'Immediate veterinary surveillance and targeted vaccination recommended.',
  });
}

// ─── Data Health & Field Connectivity ─────────────────────────────────────────

class DataHealthMetrics {
  final int reportsReceived;
  final int incompleteReports;
  final int duplicateReports;
  final int missingVaccinationRecords;
  final int pendingLabResults;
  final int offlineSubmissionsWaiting;

  const DataHealthMetrics({
    required this.reportsReceived,
    required this.incompleteReports,
    required this.duplicateReports,
    required this.missingVaccinationRecords,
    required this.pendingLabResults,
    required this.offlineSubmissionsWaiting,
  });
}

class FieldConnectivityMetrics {
  final int onlinePercent;
  final int offlinePercent;
  final int pendingSyncCount;
  final String lastSyncTime;

  const FieldConnectivityMetrics({
    required this.onlinePercent,
    required this.offlinePercent,
    required this.pendingSyncCount,
    required this.lastSyncTime,
  });
}

class ResponseTimeMetrics {
  final double reportingTimeHours;
  final double responseTimeHours;
  final double labTurnaroundHours;
  final double containmentDays;

  const ResponseTimeMetrics({
    required this.reportingTimeHours,
    required this.responseTimeHours,
    required this.labTurnaroundHours,
    required this.containmentDays,
  });
}

