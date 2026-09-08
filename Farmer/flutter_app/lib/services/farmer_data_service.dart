// AppDataService — single in-memory data store for ALL three modules.
//
// Architecture:
//   - Farmer module reads/writes farmer-scoped data (animals, reports, vet requests)
//   - Veterinary module reads all cases/reports and writes clinical actions
//   - Government module reads aggregated surveillance data and writes advisories
//
// Future backend integration: Replace in-memory lists with Repository classes
// that call REST/GraphQL APIs. No screen code needs to change.

import 'package:flutter/foundation.dart';
import '../models/animal.dart';
import '../models/herd.dart';
import '../models/health_report.dart';
import '../models/mortality_report.dart';
import '../models/vet_request.dart';
import '../models/vaccination_record.dart';
import '../models/treatment_record.dart';
import '../models/alert.dart';
import '../models/farmer_profile.dart';
import '../models/dashboard_stats.dart';
import '../models/case.dart';
import '../models/sample.dart';
import '../models/advisory.dart';
import '../models/cluster.dart';
import '../models/vet_visit.dart';
import '../models/government_alert.dart';

// Note: import case.dart types directly in screens that need them.

class FarmerDataService extends ChangeNotifier {
  // ─── In-memory storage ────────────────────────────────────────────────────

  final List<Animal> _animals = [];
  final List<Herd> _herds = [];
  final List<HealthReport> _healthReports = [];
  final List<MortalityReport> _mortalityReports = [];
  final List<VetRequest> _vetRequests = [];
  final List<VaccinationRecord> _vaccinations = [];
  final List<TreatmentRecord> _treatments = [];
  final List<AppAlert> _alerts = [];

  // ─── Extended shared data ─────────────────────────────────────────────────
  final List<LivestockCase> _cases = [];
  final List<Sample> _samples = [];
  final List<Advisory> _advisories = [];
  final List<OutbreakCluster> _clusters = [];
  final List<GovernmentAlert> _govtAlerts = [];
  final List<ResponseAction> _responseActions = [];
  final List<VetVisit> _vetVisits = [];

  // Offline sync placeholder
  int pendingSyncCount = 0;
  bool isOfflineMode = false;

  FarmerProfile _profile = const FarmerProfile(
    fullName: 'Ramesh Pawar',
    mobileNumber: '9876543210',
    email: 'farmer@example.com',
    preferredLanguage: 'English',
    state: 'Maharashtra',
    district: 'Pune',
    block: 'Haveli',
    village: 'Uruli Kanchan',
    farmName: 'Green Meadows Farm',
    farmSize: '5',
    farmSizeUnit: 'Acres',
    farmLocationMode: 'Current Location',
    livestockType: 'Cow, Goat',
    communicationPref: 'Both',
  );

  int _idCounter = 100;

  // ─── ID generation ─────────────────────────────────────────────────────────

  String _nextId(String prefix) => '$prefix${_idCounter++}';

  // ─── Profile ───────────────────────────────────────────────────────────────

  FarmerProfile get profile => _profile;

  void updateProfile(FarmerProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  // ─── Animals ───────────────────────────────────────────────────────────────

  List<Animal> getAnimals() => List.unmodifiable(_animals);

  Animal? getAnimalById(String id) {
    try {
      return _animals.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Animal? getAnimalByTag(String earTag) {
    try {
      return _animals.firstWhere((a) => a.earTag.toLowerCase() == earTag.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  bool animalIdExists(String earTag) {
    return _animals.any(
      (a) => a.earTag.toLowerCase() == earTag.toLowerCase(),
    );
  }

  void addAnimal(Animal animal) {
    _animals.add(animal);
    notifyListeners();
  }

  void updateAnimal(Animal updated) {
    final idx = _animals.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _animals[idx] = updated;
      notifyListeners();
    }
  }

  void removeAnimal(String id) {
    _animals.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ─── Herds ─────────────────────────────────────────────────────────────────

  List<Herd> getHerds() => List.unmodifiable(_herds);

  void addHerd(Herd herd) {
    _herds.add(herd);
    notifyListeners();
  }

  void removeHerd(String id) {
    _herds.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  // ─── Health Reports ────────────────────────────────────────────────────────

  List<HealthReport> getHealthReports() => List.unmodifiable(_healthReports);

  List<HealthReport> getHealthReportsForAnimal(String animalId) =>
      _healthReports.where((r) => r.animalId == animalId).toList();

  void addHealthReport(HealthReport report) {
    _healthReports.add(report);

    // Update animal's last health report timestamp & status or register automatically
    var animal = getAnimalById(report.animalId);
    if (animal == null && report.species != null) {
      final speciesEnum = AnimalSpecies.values.firstWhere(
        (s) => s.displayName.toLowerCase() == report.species!.toLowerCase(),
        orElse: () => AnimalSpecies.cow,
      );
      animal = Animal(
        id: report.animalId,
        earTag: report.animalTag,
        species: speciesEnum,
        breed: report.breed ?? 'Standard',
        gender: AnimalGender.female,
        age: report.age ?? '2–5 years',
        healthStatus: report.riskLevel == RiskLevel.critical
            ? HealthStatus.critical
            : (report.riskLevel == RiskLevel.high
                ? HealthStatus.activeCase
                : HealthStatus.underMonitoring),
      );
      _animals.add(animal);
    } else if (animal != null) {
      animal.lastHealthReport = report.createdAt;
      if (report.riskLevel == RiskLevel.high ||
          report.riskLevel == RiskLevel.critical) {
        animal.healthStatus = report.riskLevel == RiskLevel.critical
            ? HealthStatus.critical
            : HealthStatus.activeCase;
      } else if (report.riskLevel == RiskLevel.medium) {
        if (animal.healthStatus == HealthStatus.healthy) {
          animal.healthStatus = HealthStatus.underMonitoring;
        }
      }
    }

    // Auto-create a LivestockCase from every health report
    final lcase = _createCaseFromReport(report);
    _cases.add(lcase);

    // Create alert for HIGH / CRITICAL
    if (report.riskLevel == RiskLevel.high) {
      addAlert(AppAlert(
        id: _nextId('ALT'),
        category: AlertCategory.highRiskHealthAlert,
        title: 'High Risk: ${report.animalTag}',
        message:
            'Animal ${report.animalTag} has a HIGH risk health report. '
            'Please isolate and contact a veterinarian.',
        severity: AlertSeverity.high,
        relatedId: report.id,
      ));
    } else if (report.riskLevel == RiskLevel.critical) {
      addAlert(AppAlert(
        id: _nextId('ALT'),
        category: AlertCategory.highRiskHealthAlert,
        title: 'CRITICAL: ${report.animalTag}',
        message:
            'Animal ${report.animalTag} requires immediate veterinary attention.',
        severity: AlertSeverity.critical,
        relatedId: report.id,
      ));
    }

    notifyListeners();
  }

  LivestockCase _createCaseFromReport(HealthReport report) {
    return LivestockCase(
      caseId: _nextId('CASE'),
      reportId: report.id,
      farmerId: 'F001',
      farmerName: _profile.fullName,
      farmName: _profile.farmName ?? 'Farm',
      farmId: 'FARM001',
      animalId: report.animalId,
      animalTag: report.animalTag,
      species: report.species ?? 'Unknown',
      breed: report.breed,
      age: report.age,
      symptoms: report.symptoms,
      duration: report.duration,
      affectedCount: report.affectedCount,
      riskLevel: report.riskLevel.displayName,
      village: _profile.village,
      block: _profile.block,
      district: _profile.district,
      state: _profile.state,
      hasVoiceNote: report.hasVoiceNote,
      hasPhoto: report.hasPhoto,
      hasVideo: report.hasVideo,
      timeline: [
        CaseTimelineEvent(
          status: 'Report Submitted',
          description: 'Farmer submitted health report.',
          actor: 'Farmer',
          timestamp: report.createdAt,
        ),
        CaseTimelineEvent(
          status: 'Risk Assessed',
          description: 'Preliminary risk: ${report.riskLevel.displayName}',
          actor: 'System',
          timestamp: report.createdAt,
        ),
      ],
      createdAt: report.createdAt,
    );
  }

  // ─── Mortality Reports ─────────────────────────────────────────────────────

  List<MortalityReport> getMortalityReports() =>
      List.unmodifiable(_mortalityReports);

  void addMortalityReport(MortalityReport report) {
    _mortalityReports.add(report);

    if (report.animalId != null) {
      final animal = getAnimalById(report.animalId!);
      if (animal != null) {
        animal.healthStatus = HealthStatus.critical;
      }
    }

    addAlert(AppAlert(
      id: _nextId('ALT'),
      category: AlertCategory.mortalityAlert,
      title: 'Mortality Report — ${report.animalTag}',
      message:
          'A mortality report has been submitted for ${report.animalTag}. '
          'Please avoid moving animals from the affected area.',
      severity: AlertSeverity.critical,
      relatedId: report.id,
    ));

    notifyListeners();
  }

  // ─── Vet Requests ──────────────────────────────────────────────────────────

  List<VetRequest> getVetRequests() => List.unmodifiable(_vetRequests);

  List<VetRequest> getVetRequestsForAnimal(String animalId) =>
      _vetRequests.where((r) => r.animalId == animalId).toList();

  void addVetRequest(VetRequest request) {
    _vetRequests.add(request);
    notifyListeners();
  }

  void updateVetRequestStatus(String id, CaseStatus status) {
    final req = _vetRequests.firstWhere(
      (r) => r.id == id,
      orElse: () => throw StateError('VetRequest $id not found'),
    );
    req.caseStatus = status;
    req.addTimelineEvent(status.displayName, 'Status updated to ${status.displayName}');
    notifyListeners();
  }

  // ─── Vaccinations ──────────────────────────────────────────────────────────

  List<VaccinationRecord> getVaccinations() =>
      List.unmodifiable(_vaccinations);

  List<VaccinationRecord> getVaccinationsForAnimal(String animalId) =>
      _vaccinations.where((v) => v.animalId == animalId).toList();

  void addVaccination(VaccinationRecord record) {
    _vaccinations.add(record);
    notifyListeners();
  }

  // ─── Treatments ────────────────────────────────────────────────────────────

  List<TreatmentRecord> getTreatments() => List.unmodifiable(_treatments);

  List<TreatmentRecord> getTreatmentsForAnimal(String animalId) =>
      _treatments.where((t) => t.animalId == animalId).toList();

  void addTreatment(TreatmentRecord record) {
    _treatments.add(record);
    notifyListeners();
  }

  // ─── Alerts ────────────────────────────────────────────────────────────────

  List<AppAlert> getAlerts() =>
      List.unmodifiable(_alerts.reversed.toList());

  int get unreadAlertCount => _alerts.where((a) => !a.isRead).length;

  void addAlert(AppAlert alert) {
    _alerts.add(alert);
  }

  void markAlertRead(String id) {
    final alert = _alerts.firstWhere(
      (a) => a.id == id,
      orElse: () => throw StateError('Alert $id not found'),
    );
    alert.isRead = true;
    notifyListeners();
  }

  void markAllAlertsRead() {
    for (final a in _alerts) {
      a.isRead = true;
    }
    notifyListeners();
  }

  // ─── Cases (shared with Vet & Govt) ───────────────────────────────────────

  List<LivestockCase> getAllCases() => List.unmodifiable(_cases);

  List<LivestockCase> getCasesForVet({String? vetId}) {
    if (vetId != null) {
      return _cases.where((c) => c.assignedVetId == vetId || c.assignedVetId == null).toList();
    }
    return List.unmodifiable(_cases);
  }

  LivestockCase? getCaseById(String caseId) {
    try {
      return _cases.firstWhere((c) => c.caseId == caseId);
    } catch (_) {
      return null;
    }
  }

  void updateCase(LivestockCase updated) {
    final idx = _cases.indexWhere((c) => c.caseId == updated.caseId);
    if (idx != -1) {
      _cases[idx] = updated;
      notifyListeners();
    }
  }

  void updateCaseStatus(String caseId, FullCaseStatus status, {String? actor, String? description}) {
    final c = getCaseById(caseId);
    if (c != null) {
      c.status = status;
      c.addTimelineEvent(
        status.displayName,
        description ?? 'Status updated to ${status.displayName}',
        actor: actor,
      );
      notifyListeners();
    }
  }

  void assignVetToCase(String caseId, String vetId, String vetName) {
    final c = getCaseById(caseId);
    if (c != null) {
      c.assignedVetId = vetId;
      c.assignedVetName = vetName;
      c.status = FullCaseStatus.vetAssigned;
      c.addTimelineEvent('Vet Assigned', '$vetName has been assigned to this case.', actor: 'Veterinarian');
      notifyListeners();
    }
  }

  // ─── Samples ───────────────────────────────────────────────────────────────

  List<Sample> getAllSamples() => List.unmodifiable(_samples);
  List<Sample> getSamplesForCase(String caseId) =>
      _samples.where((s) => s.caseId == caseId).toList();

  void addSample(Sample sample) {
    _samples.add(sample);
    // Update case status
    updateCaseStatus(sample.caseId, FullCaseStatus.sampleCollected,
        actor: 'Veterinarian', description: 'Sample collected: ${sample.sampleType}');
    notifyListeners();
  }

  void updateSampleStatus(String sampleId, SampleStatus status) {
    final s = _samples.firstWhere((s) => s.sampleId == sampleId, orElse: () => throw StateError('Sample not found'));
    s.status = status;
    if (status == SampleStatus.sentToLab) {
      // Also update the related case
      updateCaseStatus(s.caseId, FullCaseStatus.labReferred, actor: 'Veterinarian', description: 'Sample sent to laboratory.');
    }
    notifyListeners();
  }

  // ─── Vet Visits ────────────────────────────────────────────────────────────

  List<VetVisit> getAllVisits() => List.unmodifiable(_vetVisits);
  List<VetVisit> getVisitsForCase(String caseId) =>
      _vetVisits.where((v) => v.caseId == caseId).toList();

  void addVetVisit(VetVisit visit) {
    _vetVisits.add(visit);
    updateCaseStatus(visit.caseId, FullCaseStatus.visitScheduled,
        actor: 'Veterinarian', description: 'Visit scheduled by ${visit.vetName}');
    notifyListeners();
  }

  // ─── Advisories ────────────────────────────────────────────────────────────

  List<Advisory> getAllAdvisories() => List.unmodifiable(_advisories);
  List<Advisory> getPublishedAdvisories() =>
      _advisories.where((a) => a.status == AdvisoryStatus.published).toList();

  void addAdvisory(Advisory advisory) {
    _advisories.add(advisory);
    notifyListeners();
  }

  void publishAdvisory(String advisoryId) {
    final adv = _advisories.firstWhere((a) => a.advisoryId == advisoryId);
    adv.publish();
    // Push to farmer alerts
    addAlert(AppAlert(
      id: _nextId('ALT'),
      category: AlertCategory.governmentAdvisory,
      title: '🔔 ${adv.title}',
      message: adv.message,
      severity: AlertSeverity.warning,
      relatedId: advisoryId,
    ));
    notifyListeners();
  }

  // ─── Government Alerts (Synchronized from High-Risk Clusters) ───────────────

  // ─── Government Alerts (Synchronized from High-Risk Clusters) ───────────────

  List<GovernmentAlert> getGovernmentAlerts() {
    return List.unmodifiable(
      _govtAlerts.where((a) => a.riskLevel == ClusterRisk.high).toList(),
    );
  }

  GovernmentAlert? getGovernmentAlertByClusterId(String clusterId) {
    try {
      return _govtAlerts.firstWhere((a) => a.clusterId == clusterId);
    } catch (_) {
      return null;
    }
  }

  void createGovernmentAlertIfNotExists(OutbreakCluster cluster) {
    // Enforcement Rule: Only HIGH risk or Escalated clusters generate/maintain Government Alerts.
    if (cluster.riskLevel != ClusterRisk.high && cluster.status != ClusterStatus.escalated) {
      final initialLength = _govtAlerts.length;
      _govtAlerts.removeWhere((a) => a.clusterId == cluster.clusterId);
      if (_govtAlerts.length != initialLength) {
        notifyListeners();
      }
      return;
    }

    final existingIndex = _govtAlerts.indexWhere((a) => a.clusterId == cluster.clusterId);
    final alertTitle = cluster.name.toLowerCase().contains('high')
        ? cluster.name
        : 'HIGH RISK: ${cluster.name}';

    if (existingIndex != -1) {
      final existing = _govtAlerts[existingIndex];
      existing.riskLevel = ClusterRisk.high;
      existing.title = alertTitle;
      existing.location = cluster.location;
      existing.district = cluster.district;
      existing.state = cluster.state;
      existing.species = cluster.species;
      existing.animalCount = cluster.animalCount;
      existing.reportCount = cluster.reportCount;
      existing.mortality = cluster.mortality;
      existing.symptoms = List.from(cluster.symptoms);
      existing.suspectedDisease = cluster.suspectedDisease;
      existing.updatedAt = DateTime.now();
    } else {
      final alert = GovernmentAlert(
        id: generateAlertId(),
        clusterId: cluster.clusterId,
        type: 'HIGH_RISK_OUTBREAK',
        riskLevel: ClusterRisk.high,
        title: alertTitle,
        location: cluster.location,
        district: cluster.district,
        state: cluster.state,
        species: cluster.species,
        animalCount: cluster.animalCount,
        reportCount: cluster.reportCount,
        mortality: cluster.mortality,
        symptoms: List.from(cluster.symptoms),
        suspectedDisease: cluster.suspectedDisease,
        status: GovernmentAlertStatus.newAlert,
        createdAt: DateTime.now(),
      );
      _govtAlerts.insert(0, alert);
    }
    notifyListeners();
  }

  void acknowledgeGovernmentAlert(String alertId, {String? user}) {
    try {
      final alert = _govtAlerts.firstWhere((a) => a.id == alertId || a.clusterId == alertId);
      alert.status = GovernmentAlertStatus.acknowledged;
      alert.acknowledgedAt = DateTime.now();
      alert.acknowledgedBy = user ?? 'District Health Officer';
      alert.updatedAt = DateTime.now();
      notifyListeners();
    } catch (_) {}
  }

  void updateGovernmentAlertStatus(String alertId, GovernmentAlertStatus status) {
    try {
      final alert = _govtAlerts.firstWhere((a) => a.id == alertId || a.clusterId == alertId);
      alert.status = status;
      alert.updatedAt = DateTime.now();
      notifyListeners();
    } catch (_) {}
  }

  // ─── Clusters ──────────────────────────────────────────────────────────────

  List<OutbreakCluster> getAllClusters({
    ClusterRisk? risk,
    String? searchQuery,
    String? species,
    ClusterStatus? status,
  }) {
    return _clusters.where((c) {
      if (risk != null && c.riskLevel != risk) return false;
      if (status != null && c.status != status) return false;
      if (species != null && species != 'All' && !c.species.toLowerCase().contains(species.toLowerCase())) {
        return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchName = c.name.toLowerCase().contains(q);
        final matchLocation = c.location.toLowerCase().contains(q);
        final matchVillage = c.village.toLowerCase().contains(q);
        final matchDistrict = c.district.toLowerCase().contains(q);
        if (!matchName && !matchLocation && !matchVillage && !matchDistrict) return false;
      }
      return true;
    }).toList();
  }

  /// Government Portal Cluster Fetch — Returns STRICTLY HIGH-RISK or Escalated clusters
  List<OutbreakCluster> getGovernmentClusters({
    String? searchQuery,
    String? species,
    String? district,
    ClusterStatus? status,
  }) {
    return _clusters.where((c) {
      // Government Portal filter: ONLY HIGH RISK or Escalated clusters
      if (c.riskLevel != ClusterRisk.high && c.status != ClusterStatus.escalated) {
        return false;
      }
      if (status != null && c.status != status) return false;
      if (district != null && district != 'All' && c.district.toLowerCase() != district.toLowerCase()) {
        return false;
      }
      if (species != null && species != 'All' && !c.species.toLowerCase().contains(species.toLowerCase())) {
        return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchName = c.name.toLowerCase().contains(q);
        final matchLocation = c.location.toLowerCase().contains(q);
        final matchVillage = c.village.toLowerCase().contains(q);
        final matchDistrict = c.district.toLowerCase().contains(q);
        if (!matchName && !matchLocation && !matchVillage && !matchDistrict) return false;
      }
      return true;
    }).toList();
  }

  OutbreakCluster? getClusterById(String id) {
    try {
      return _clusters.firstWhere((c) => c.clusterId == id);
    } catch (_) {
      return null;
    }
  }

  void addCluster(OutbreakCluster cluster) {
    _clusters.add(cluster);
    createGovernmentAlertIfNotExists(cluster);
    notifyListeners();
  }

  void updateCluster(OutbreakCluster updated) {
    final idx = _clusters.indexWhere((c) => c.clusterId == updated.clusterId);
    if (idx != -1) {
      _clusters[idx] = updated;
      createGovernmentAlertIfNotExists(updated);
      notifyListeners();
    }
  }

  void updateClusterStatus(String clusterId, ClusterStatus status) {
    final c = getClusterById(clusterId);
    if (c != null) {
      c.status = status;
      c.updatedAt = DateTime.now();
      createGovernmentAlertIfNotExists(c);
      notifyListeners();
    }
  }

  void updateClusterRisk(String clusterId, ClusterRisk newRisk) {
    final c = getClusterById(clusterId);
    if (c != null) {
      c.riskLevel = newRisk;
      c.updatedAt = DateTime.now();
      createGovernmentAlertIfNotExists(c);
      notifyListeners();
    }
  }

  void escalateCluster(String clusterId) {
    final c = getClusterById(clusterId);
    if (c != null) {
      c.status = ClusterStatus.escalated;
      c.riskLevel = ClusterRisk.high;
      c.updatedAt = DateTime.now();
      createGovernmentAlertIfNotExists(c);
      notifyListeners();
    }
  }

  // ─── Response Actions ──────────────────────────────────────────────────────

  // ─── Response Actions ──────────────────────────────────────────────────────

  List<ResponseAction> getAllResponseActions() => List.unmodifiable(_responseActions);

  void addResponseAction(ResponseAction action) {
    _responseActions.add(action);
    notifyListeners();
  }

  // ─── Government Surveillance getters ──────────────────────────────────────

  /// Returns cases grouped by district for government view
  Map<String, List<LivestockCase>> getCasesByDistrict() {
    final map = <String, List<LivestockCase>>{};
    for (final c in _cases) {
      map.putIfAbsent(c.district, () => []).add(c);
    }
    return map;
  }

  /// Returns cases grouped by village
  Map<String, List<LivestockCase>> getCasesByVillage() {
    final map = <String, List<LivestockCase>>{};
    for (final c in _cases) {
      map.putIfAbsent(c.village, () => []).add(c);
    }
    return map;
  }

  int get totalMortalityCount => _mortalityReports.length;
  int get activeCaseCount => _cases.where((c) => c.status.isActive).length;
  int get criticalCaseCount => _cases.where((c) => c.riskLevel == 'CRITICAL').length;
  int get highRiskCaseCount => _cases.where((c) => c.riskLevel == 'HIGH').length;

  // ─── Dashboard Statistics ──────────────────────────────────────────────────

  DashboardStats getDashboardStatistics() {
    final now = DateTime.now();
    final vacDue = _vaccinations.where((v) {
      if (v.status == VaccinationStatus.due ||
          v.status == VaccinationStatus.overdue) {
        return true;
      }
      if (v.nextDueDate != null &&
          v.nextDueDate!.isBefore(now.add(const Duration(days: 30)))) {
        return true;
      }
      return false;
    }).length;

    return DashboardStats(
      totalAnimals: _animals.length,
      healthyAnimals:
          _animals.where((a) => a.healthStatus == HealthStatus.healthy).length,
      monitoringAnimals: _animals
          .where((a) => a.healthStatus == HealthStatus.underMonitoring)
          .length,
      activeCases: _cases.where((c) => c.status.isActive).length,
      vaccinationsDue: vacDue,
      importantAlerts: unreadAlertCount,
    );
  }

  // ─── Recent Activity ───────────────────────────────────────────────────────

  List<Map<String, dynamic>> getRecentActivity({int limit = 10}) {
    final activities = <Map<String, dynamic>>[];

    for (final a in _animals) {
      activities.add({
        'type': 'animal_added',
        'title': 'Animal Registered',
        'subtitle': '${a.species.emoji} ${a.species.displayName} (${a.earTag}) · ${a.breed}',
        'date': a.createdAt,
        'icon': 'pets',
      });
    }

    for (final r in _healthReports) {
      activities.add({
        'type': 'health_report',
        'title': 'Health Report: ${r.animalTag}',
        'subtitle': '${r.riskLevel.displayName} Risk — ${r.symptoms.take(2).join(", ")}',
        'date': r.createdAt,
        'icon': 'medical_services',
      });
    }

    for (final m in _mortalityReports) {
      activities.add({
        'type': 'mortality_report',
        'title': 'Mortality Report: ${m.animalTag}',
        'subtitle': '${m.numberAffected} animal(s) affected',
        'date': m.createdAt,
        'icon': 'warning',
      });
    }

    for (final v in _vetRequests) {
      activities.add({
        'type': 'vet_request',
        'title': 'Vet Requested: ${v.animalTag}',
        'subtitle': v.reason,
        'date': v.createdAt,
        'icon': 'local_hospital',
      });
    }

    activities.sort((a, b) =>
        (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return activities.take(limit).toList();
  }

  // ─── ID generation helpers (public) ───────────────────────────────────────

  String generateAnimalId() => _nextId('ANM');
  String generateHerdId() => _nextId('HRD');
  String generateReportId() => _nextId('RPT');
  String generateMortalityId() => _nextId('MRT');
  String generateVetRequestId() => _nextId('VET');
  String generateVaccinationId() => _nextId('VAC');
  String generateTreatmentId() => _nextId('TRT');
  String generateAlertId() => _nextId('ALT');
  String generateCaseId() => _nextId('CASE');
  String generateSampleId() => _nextId('SMP');
  String generateVisitId() => _nextId('VIS');
  String generateAdvisoryId() => _nextId('ADV');
  String generateClusterId() => _nextId('CLU');
  String generateActionId() => _nextId('ACT');

  // ─── Demo data ─────────────────────────────────────────────────────────────

  void seedDemoData() {
    if (_animals.isNotEmpty) return;

    // ── Farmer animals ────────────────────────────────────────────────────
    final cow1 = Animal(
      id: 'ANM001',
      earTag: 'C001',
      species: AnimalSpecies.cow,
      breed: 'Jersey',
      gender: AnimalGender.female,
      age: '2–5 years',
      healthStatus: HealthStatus.activeCase,
    );
    final cow2 = Animal(
      id: 'ANM002',
      earTag: 'C002',
      species: AnimalSpecies.cow,
      breed: 'Holstein Friesian (HF)',
      gender: AnimalGender.female,
      age: '5–10 years',
      healthStatus: HealthStatus.underMonitoring,
    );
    final goat1 = Animal(
      id: 'ANM003',
      earTag: 'G001',
      species: AnimalSpecies.goat,
      breed: 'Boer',
      gender: AnimalGender.male,
      age: '1–2 years',
      healthStatus: HealthStatus.healthy,
    );

    _animals.addAll([cow1, cow2, goat1]);

    // ── Vaccination ────────────────────────────────────────────────────────
    _vaccinations.add(VaccinationRecord(
      id: 'VAC001',
      animalId: cow1.id,
      animalTag: cow1.earTag,
      vaccineName: 'FMD Vaccine',
      date: DateTime.now().subtract(const Duration(days: 180)),
      nextDueDate: DateTime.now().add(const Duration(days: 15)),
      status: VaccinationStatus.due,
      veterinarian: 'Dr. Rajesh Kumar',
    ));

    _vaccinations.add(VaccinationRecord(
      id: 'VAC002',
      animalId: cow2.id,
      animalTag: cow2.earTag,
      vaccineName: 'HS Vaccine',
      date: DateTime.now().subtract(const Duration(days: 90)),
      nextDueDate: DateTime.now().add(const Duration(days: 90)),
      status: VaccinationStatus.upcoming,
      veterinarian: 'Dr. Priya Nair',
    ));

    // ── Demo Cases: 3 reports in Uruli Kanchan, Cow, Fever+Diarrhea ──────
    // Case 1 — Main farmer (Ramesh Pawar) — HIGH
    final report1 = HealthReport(
      id: 'RPT001',
      animalId: cow1.id,
      animalTag: cow1.earTag,
      species: 'Cow',
      breed: 'Jersey',
      age: '2–5 years',
      symptoms: ['Fever', 'Not eating', 'Diarrhea'],
      duration: '2–3 days',
      eatingStatus: 'Less than usual',
      drinkingStatus: 'Less than usual',
      affectedCount: '3',
      riskLevel: RiskLevel.high,
      title: 'HIGH HEALTH RISK',
      advice: 'Isolate the affected animals and contact a veterinarian.',
      recommendedAction: 'Separate affected animals. Request veterinarian assistance.',
      caseStatus: CaseStatus.vetAssigned,
      hasVoiceNote: true,
      hasPhoto: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
    );
    _healthReports.add(report1);

    final case1 = LivestockCase(
      caseId: 'CASE001',
      reportId: 'RPT001',
      farmerId: 'F001',
      farmerName: 'Ramesh Pawar',
      farmName: 'Green Meadows Farm',
      farmId: 'FARM001',
      animalId: cow1.id,
      animalTag: 'C001',
      species: 'Cow',
      breed: 'Jersey',
      age: '2–5 years',
      gender: 'Female',
      symptoms: ['Fever', 'Not eating', 'Diarrhea'],
      duration: '2–3 days',
      affectedCount: '3',
      otherAnimalsAffected: 'Yes',
      nearbyFarmsAffected: 'Not sure',
      riskLevel: 'HIGH',
      village: 'Uruli Kanchan',
      block: 'Haveli',
      district: 'Pune',
      state: 'Maharashtra',
      hasVoiceNote: true,
      hasPhoto: true,
      status: FullCaseStatus.treatmentStarted,
      assignedVetId: 'VET001',
      assignedVetName: 'Dr. Rajesh Kumar',
      visitScheduledDate: DateTime.now().add(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      timeline: [
        CaseTimelineEvent(
          status: 'Report Submitted',
          description: 'Farmer submitted health report.',
          actor: 'Farmer',
          timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        CaseTimelineEvent(
          status: 'Risk Assessed',
          description: 'Preliminary risk: HIGH',
          actor: 'System',
          timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        CaseTimelineEvent(
          status: 'Vet Assigned',
          description: 'Dr. Rajesh Kumar assigned to case.',
          actor: 'Veterinarian',
          timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        CaseTimelineEvent(
          status: 'Visit Scheduled',
          description: 'Field visit scheduled.',
          actor: 'Veterinarian',
          timestamp: DateTime.now().subtract(const Duration(hours: 17)),
        ),
        CaseTimelineEvent(
          status: 'Treatment Started',
          description: 'ORS + Oxytetracycline prescribed.',
          actor: 'Veterinarian',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
    );
    _cases.add(case1);

    // Case 2 — Farmer Suresh in same village — HIGH
    final case2 = LivestockCase(
      caseId: 'CASE002',
      reportId: 'RPT002',
      farmerId: 'F002',
      farmerName: 'Suresh Mane',
      farmName: 'Mane Dairy Farm',
      farmId: 'FARM002',
      animalId: 'ANM010',
      animalTag: 'C010',
      species: 'Cow',
      breed: 'Sahiwal',
      age: '2–5 years',
      gender: 'Female',
      symptoms: ['Fever', 'Diarrhea', 'Weakness'],
      duration: '2–3 days',
      affectedCount: '2',
      otherAnimalsAffected: 'Yes',
      nearbyFarmsAffected: 'Yes',
      riskLevel: 'HIGH',
      village: 'Uruli Kanchan',
      block: 'Haveli',
      district: 'Pune',
      state: 'Maharashtra',
      status: FullCaseStatus.underReview,
      createdAt: DateTime.now().subtract(const Duration(hours: 16)),
      timeline: [
        CaseTimelineEvent(
          status: 'Report Submitted',
          description: 'Farmer submitted health report.',
          actor: 'Farmer',
          timestamp: DateTime.now().subtract(const Duration(hours: 16)),
        ),
        CaseTimelineEvent(
          status: 'Risk Assessed',
          description: 'Preliminary risk: HIGH',
          actor: 'System',
          timestamp: DateTime.now().subtract(const Duration(hours: 16)),
        ),
      ],
    );
    _cases.add(case2);

    // Case 3 — Farmer Lakshmi in same village — MEDIUM
    final case3 = LivestockCase(
      caseId: 'CASE003',
      reportId: 'RPT003',
      farmerId: 'F003',
      farmerName: 'Lakshmi Devi',
      farmName: 'Devi Livestock',
      farmId: 'FARM003',
      animalId: 'ANM011',
      animalTag: 'B001',
      species: 'Buffalo',
      breed: 'Murrah',
      age: '5–10 years',
      gender: 'Female',
      symptoms: ['Fever', 'Not eating'],
      duration: 'Today',
      affectedCount: '4',
      otherAnimalsAffected: 'Not sure',
      nearbyFarmsAffected: 'Yes',
      riskLevel: 'HIGH',
      village: 'Uruli Kanchan',
      block: 'Haveli',
      district: 'Pune',
      state: 'Maharashtra',
      status: FullCaseStatus.submitted,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      timeline: [
        CaseTimelineEvent(
          status: 'Report Submitted',
          description: 'Farmer submitted health report.',
          actor: 'Farmer',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        CaseTimelineEvent(
          status: 'Risk Assessed',
          description: 'Preliminary risk: HIGH',
          actor: 'System',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ],
    );
    _cases.add(case3);

    // ── Demo Sample ────────────────────────────────────────────────────────
    final sample1 = Sample(
      sampleId: 'SMP001',
      caseId: 'CASE001',
      animalId: cow1.id,
      animalTag: 'C001',
      sampleType: 'Blood',
      collectionDate: 'Today',
      collectionLocation: 'Green Meadows Farm, Uruli Kanchan',
      reason: 'Rule out haemorrhagic septicaemia',
      laboratory: 'Maharashtra Animal Disease Investigation Laboratory, Pune',
      status: SampleStatus.sentToLab,
      collectedBy: 'Dr. Rajesh Kumar',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    );
    _samples.add(sample1);

    // ── Demo Vet Visit ─────────────────────────────────────────────────────
    final visit1 = VetVisit(
      visitId: 'VIS001',
      caseId: 'CASE001',
      farmerId: 'F001',
      farmerName: 'Ramesh Pawar',
      farmLocation: 'Uruli Kanchan, Haveli, Pune',
      vetId: 'VET001',
      vetName: 'Dr. Rajesh Kumar',
      scheduledDate: DateTime.now().subtract(const Duration(hours: 6)),
      actualDate: DateTime.now().subtract(const Duration(hours: 6)),
      observations: 'Animals showing signs of haemorrhagic septicaemia. Pyrexia ~104°F, anorexia, profuse diarrhoea.',
      animalsExamined: '3 cows',
      symptomsObserved: 'Fever, diarrhoea, weakness',
      preliminaryAssessment: 'Possible HS or FMD. Blood sample collected for lab confirmation.',
      actionTaken: 'ORS administered. Oxytetracycline 10mg/kg BW IM. Isolation advised.',
      followUpDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: true,
    );
    _vetVisits.add(visit1);

    // ── Demo Clusters (High, Medium, Low) ──────────────────────────────────
    final cluster1 = OutbreakCluster(
      clusterId: 'CLU001',
      name: 'Uruli Kanchan Livestock Cluster',
      location: 'Uruli Kanchan, Pune',
      village: 'Uruli Kanchan',
      block: 'Haveli',
      district: 'Pune',
      state: 'Maharashtra',
      species: 'Cattle',
      symptoms: ['Fever', 'Diarrhea', 'Not eating'],
      suspectedDisease: 'Haemorrhagic Septicaemia',
      description: 'High fever and diarrhoea outbreak reported in Uruli Kanchan village.',
      reportCount: 3,
      animalCount: 9,
      mortality: 0,
      riskLevel: ClusterRisk.high,
      status: ClusterStatus.investigation,
      detectedAt: DateTime.now().subtract(const Duration(hours: 20)),
      caseIds: ['CASE001', 'CASE002', 'CASE003'],
    );
    addCluster(cluster1);

    final cluster2 = OutbreakCluster(
      clusterId: 'CLU002',
      name: 'Khed Cattle Cluster',
      location: 'Khed, Pune',
      village: 'Khed',
      block: 'Khed',
      district: 'Pune',
      state: 'Maharashtra',
      species: 'Cattle',
      symptoms: ['Fever', 'Reduced appetite', 'Nasal discharge'],
      suspectedDisease: 'Foot and Mouth Disease (FMD)',
      description: 'Moderate fever and nasal discharge cases reported in Khed.',
      reportCount: 5,
      animalCount: 14,
      mortality: 1,
      riskLevel: ClusterRisk.medium,
      status: ClusterStatus.monitoring,
      detectedAt: DateTime.now().subtract(const Duration(days: 2)),
    );
    addCluster(cluster2);

    final cluster3 = OutbreakCluster(
      clusterId: 'CLU003',
      name: 'Baramati Goat Cluster',
      location: 'Baramati, Pune',
      village: 'Baramati',
      block: 'Baramati',
      district: 'Pune',
      state: 'Maharashtra',
      species: 'Goat',
      symptoms: ['Mild fever', 'Reduced activity'],
      suspectedDisease: 'PPR (Peste des Petits Ruminants)',
      description: 'Goat cluster with mild symptoms under observation in Baramati.',
      reportCount: 2,
      animalCount: 5,
      mortality: 0,
      riskLevel: ClusterRisk.low,
      status: ClusterStatus.monitoring,
      detectedAt: DateTime.now().subtract(const Duration(days: 4)),
    );
    addCluster(cluster3);

    // ── Demo Advisory ──────────────────────────────────────────────────────
    final advisory1 = Advisory(
      advisoryId: 'ADV001',
      title: 'Livestock Health Advisory — Haveli Block',
      message:
          'Multiple cattle cases with fever and diarrhoea have been reported in '
          'Uruli Kanchan village. Please monitor your animals closely. Isolate '
          'any sick animals immediately and contact the nearest veterinary officer.',
      target: AdvisoryTarget.block,
      targetLocation: 'Haveli',
      language: 'en',
      createdBy: 'District Animal Husbandry Officer',
      status: AdvisoryStatus.published,
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    );
    _advisories.add(advisory1);

    // ── Demo Response Action ───────────────────────────────────────────────
    final action1 = ResponseAction(
      actionId: 'ACT001',
      clusterId: 'CLU001',
      type: ResponseActionType.fieldVisit,
      title: 'Veterinary Field Investigation — Uruli Kanchan',
      description: 'Deploy veterinary team to investigate cluster in Uruli Kanchan. '
          'Examine affected animals and collect samples.',
      location: 'Uruli Kanchan, Haveli, Pune',
      assignedTo: 'Dr. Rajesh Kumar',
      status: ResponseActionStatus.inProgress,
    );
    _responseActions.add(action1);

    // ── Farmer Alerts ──────────────────────────────────────────────────────
    addAlert(AppAlert(
      id: 'ALT001',
      category: AlertCategory.diseaseAlert,
      title: 'FMD Advisory — Maharashtra',
      message:
          'Foot and Mouth Disease cases reported in nearby districts. '
          'Ensure all cattle are vaccinated. Contact your veterinarian.',
      severity: AlertSeverity.warning,
    ));

    addAlert(AppAlert(
      id: 'ALT002',
      category: AlertCategory.governmentAdvisory,
      title: 'Government Advisory — Haveli Block',
      message: advisory1.message,
      severity: AlertSeverity.warning,
      relatedId: 'ADV001',
    ));

    addAlert(AppAlert(
      id: 'ALT003',
      category: AlertCategory.vaccinationReminder,
      title: 'Vaccination Due: C001 (FMD)',
      message: 'FMD Vaccine for cow C001 is due within 15 days. Please contact your veterinarian.',
      severity: AlertSeverity.info,
      relatedId: 'VAC001',
    ));

    addAlert(AppAlert(
      id: 'ALT004',
      category: AlertCategory.veterinarianMessage,
      title: 'Dr. Rajesh Kumar — Treatment Update',
      message: 'Visit completed. Treatment started. Follow-up in 3 days. Keep animals isolated.',
      severity: AlertSeverity.info,
      relatedId: 'CASE001',
    ));

    notifyListeners();
  }
}
