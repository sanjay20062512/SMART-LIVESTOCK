// AppDataService â€” single in-memory data store for ALL three modules.
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
import 'api_service.dart';

class FarmerDataService extends ChangeNotifier {
  final ApiService apiService = ApiService();
  // â”€â”€â”€ In-memory storage â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  final List<Animal> _animals = [];
  final List<Herd> _herds = [];
  final List<HealthReport> _healthReports = [];
  final List<MortalityReport> _mortalityReports = [];
  final List<VetRequest> _vetRequests = [];
  final List<VaccinationRecord> _vaccinations = [];
  final List<TreatmentRecord> _treatments = [];
  final List<AppAlert> _alerts = [];

  // â”€â”€â”€ Extended shared data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€â”€ ID generation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  String _nextId(String prefix) => '$prefix${_idCounter++}';

  // â”€â”€â”€ API Integration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> loadInitialData() async {
    try {
      // Fetch live data from backend
      await apiService.init();
      await fetchAnimals();
      await fetchCases();
      // We will add more fetches here (alerts, etc.)
    } catch (e) {
      if (kDebugMode) {
        print('Error loading initial data: $e');
      }
    }
    if (_animals.isEmpty) {
      seedDemoData();
    }
  }

  Future<void> fetchAnimals() async {
    try {
      final response = await apiService.get('/animals');
      if (response != null && response is List) {
        _animals.clear();
        for (var item in response) {
          try {
            // Map FastAPI JSON to our Flutter model
            final animal = Animal(
              id: item['id'],
              farmId: item['farm_id'],
              earTag: item['ear_tag'],
              species: AnimalSpecies.values.firstWhere(
                (e) => e.displayName.toLowerCase() == item['species'].toString().toLowerCase(),
                orElse: () => AnimalSpecies.cow,
              ),
              breed: item['breed'],
              gender: item['gender'] == 'Female' ? AnimalGender.female : AnimalGender.male,
              age: item['age_years']?.toString() ?? '',
              healthStatus: HealthStatus.values.firstWhere(
                (e) => e.displayName.toLowerCase() == item['health_status'].toString().toLowerCase(),
                orElse: () => HealthStatus.healthy,
              ),
            );
            _animals.add(animal);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing animal: $e');
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching animals: $e');
      }
    }
  }

  Future<void> fetchCases({String? role}) async {
    try {
      final endpoint = role != null ? '/cases?role=$role' : '/cases';
      final response = await apiService.get(endpoint);
      if (response != null && response is List) {
        for (var item in response) {
          try {
            // Safe parsing helper
            List<String> parseStringList(dynamic source) {
              if (source == null) return [];
              if (source is List) return source.map((e) => e.toString()).toList();
              return [];
            }

            final lcase = LivestockCase(
              caseId: item['id'],
              reportId: item['id'], 
              farmerId: item['farmer_id'] ?? '',
              farmerName: item['farmer_name'] ?? 'Unknown Farmer',
              farmName: item['farm_name'] ?? 'Unknown Farm',
              farmId: item['farm_id'] ?? '',
              animalId: item['animal_id'] ?? '',
              animalTag: item['animal_tag'] ?? 'Unknown Tag',
              species: item['species'] ?? 'Cow',
              breed: item['breed'],
              age: item['age'],
              symptoms: parseStringList(item['symptoms']),
              duration: item['duration'] ?? '',
              affectedCount: item['affected_count']?.toString() ?? '1',
              riskLevel: item['risk_level'] ?? 'MEDIUM',
              village: item['village'] ?? _profile.village,
              block: item['block'] ?? _profile.block,
              district: item['district'] ?? _profile.district,
              state: item['state'] ?? _profile.state,
              hasVoiceNote: item['has_voice_note'] ?? false,
              hasPhoto: item['has_photo'] ?? false,
              hasVideo: item['has_video'] ?? false,
              createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
            );
            
            // Map status
            final rawStatus = item['status']?.toString().toUpperCase() ?? 'SUBMITTED';
            switch (rawStatus) {
              case 'SUBMITTED':
                lcase.status = FullCaseStatus.submitted;
                break;
              case 'VET_ASSIGNED':
                lcase.status = FullCaseStatus.vetAssigned;
                break;
              case 'VISIT_SCHEDULED':
                lcase.status = FullCaseStatus.visitScheduled;
                break;
              case 'SAMPLE_COLLECTED':
                lcase.status = FullCaseStatus.sampleCollected;
                break;
              case 'LAB_REFERRED':
                lcase.status = FullCaseStatus.labReferred;
                break;
              case 'TREATMENT_STARTED':
                lcase.status = FullCaseStatus.treatmentStarted;
                break;
              case 'ESCALATED':
                lcase.status = FullCaseStatus.escalated;
                break;
              case 'CONTAINED':
              case 'CASE_CLOSED':
                lcase.status = FullCaseStatus.caseClosed;
                break;
              default:
                lcase.status = FullCaseStatus.investigation;
            }
            
            lcase.assignedVetId = item['assigned_vet_id'];
            lcase.assignedVetName = item['assigned_vet_name'];
            lcase.clinicalObservation = item['clinical_observation'];
            lcase.treatmentSummary = item['treatment_summary'];
            
            final existingIdx = _cases.indexWhere((c) => c.caseId == lcase.caseId || c.reportId == lcase.reportId);
            if (existingIdx != -1) {
              _cases[existingIdx] = lcase;
            } else {
              _cases.insert(0, lcase);
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing case: $e');
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching cases: $e');
      }
    }
  }

  // â”€â”€â”€ Profile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  FarmerProfile get profile => _profile;

  void updateProfile(FarmerProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  // â”€â”€â”€ Animals â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  Future<void> addAnimal(Animal animal) async {
    _animals.add(animal);
    notifyListeners();
    try {
      await apiService.post('/animals', {
        'farm_id': animal.farmId ?? '33333333-3333-3333-3333-333333333301',
        'ear_tag': animal.earTag,
        'species': animal.species.name.toUpperCase(),
        'breed': animal.breed,
        'gender': animal.gender.name.toUpperCase(),
        'age_years': 2.0,
        'health_status': 'HEALTHY',
        'location': animal.location ?? 'Uruli Kanchan',
      });
      await fetchAnimals();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding animal to backend: $e');
      }
    }
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

  // â”€â”€â”€ Herds â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<Herd> getHerds() => List.unmodifiable(_herds);

  void addHerd(Herd herd) {
    _herds.add(herd);
    notifyListeners();
  }

  void removeHerd(String id) {
    _herds.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  // â”€â”€â”€ Health Reports â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<HealthReport> getHealthReports() => List.unmodifiable(_healthReports);

  List<HealthReport> getHealthReportsForAnimal(String animalId) =>
      _healthReports.where((r) => r.animalId == animalId).toList();

  Future<void> addHealthReport(HealthReport report) async {
    _healthReports.add(report);

    // 1. Immediately create a LivestockCase in _cases so it appears instantly for Vet and Govt
    final caseId = report.id.startsWith('RPT') ? report.id.replaceFirst('RPT', 'CASE') : generateCaseId();
    final newCase = LivestockCase(
      caseId: caseId,
      reportId: report.id,
      farmerId: 'F001',
      farmerName: _profile.fullName,
      farmName: _profile.farmName ?? 'Green Meadows Farm',
      farmId: 'FARM001',
      animalId: report.animalId,
      animalTag: report.animalTag,
      species: report.species ?? 'Cow',
      breed: report.breed,
      symptoms: report.symptoms,
      duration: report.duration,
      affectedCount: report.affectedCount,
      riskLevel: report.riskLevel.displayName.toUpperCase(),
      village: _profile.village,
      block: _profile.block,
      district: _profile.district,
      state: _profile.state,
      hasVoiceNote: report.hasVoiceNote,
      hasPhoto: report.hasPhoto,
      hasVideo: report.hasVideo,
      status: FullCaseStatus.submitted,
      createdAt: report.createdAt,
      timeline: [
        CaseTimelineEvent(
          status: 'Report Submitted',
          description: 'Farmer ${_profile.fullName} submitted health report: ${report.title}',
          actor: 'Farmer',
          timestamp: DateTime.now(),
        ),
        CaseTimelineEvent(
          status: 'Risk Assessed',
          description: 'Automated Triage: ${report.riskLevel.displayName.toUpperCase()} - ${report.advice}',
          actor: 'System',
          timestamp: DateTime.now(),
        ),
      ],
    );
    _cases.removeWhere((c) => c.caseId == caseId || c.reportId == report.id);
    _cases.insert(0, newCase);

    // 2. Alert the field veterinarian
    final alertSeverity = switch (report.riskLevel) {
      RiskLevel.critical => AlertSeverity.critical,
      RiskLevel.high => AlertSeverity.high,
      RiskLevel.medium => AlertSeverity.warning,
      RiskLevel.low => AlertSeverity.info,
    };
    addAlert(AppAlert(
      id: generateAlertId(),
      category: AlertCategory.highRiskHealthAlert,
      title: 'New Case: ${report.animalTag} (${report.riskLevel.displayName})',
      message: 'Farmer ${_profile.fullName} in ${_profile.village} reported: ${report.symptoms.join(", ")}.',
      severity: alertSeverity,
      relatedId: caseId,
      targetRole: 'VETERINARIAN',
    ));

    notifyListeners();

    try {
      await apiService.post('/cases', {
        'animal_id': report.animalId,
        'animal_tag': report.animalTag,
        'species': report.species ?? 'Cow',
        'risk_level': report.riskLevel.displayName.toUpperCase(),
        'farm_id': '33333333-3333-3333-3333-333333333301', // Demo farm ID
        'symptoms': report.symptoms,
        'duration': report.duration,
        'affected_count': report.affectedCount,
        'village': _profile.village,
        'block': _profile.block,
        'district': _profile.district,
        'state': _profile.state,
        'has_voice_note': report.hasVoiceNote,
        'has_photo': report.hasPhoto,
        'has_video': report.hasVideo,
      });
      await fetchCases();
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting health report to backend: $e');
      }
    }
  }

  // â”€â”€â”€ Mortality Reports â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<MortalityReport> getMortalityReports() =>
      List.unmodifiable(_mortalityReports);

  Future<void> addMortalityReport(MortalityReport report) async {
    _mortalityReports.add(report);

    // 1. Immediately create a CRITICAL LivestockCase in _cases
    final caseId = report.id.startsWith('MOR') ? report.id.replaceFirst('MOR', 'CASE') : generateCaseId();
    final newCase = LivestockCase(
      caseId: caseId,
      reportId: report.id,
      farmerId: 'F001',
      farmerName: _profile.fullName,
      farmName: _profile.farmName ?? 'Green Meadows Farm',
      farmId: 'FARM001',
      animalId: report.animalId ?? '',
      animalTag: report.animalTag,
      species: 'Cow',
      symptoms: report.symptomsBeforeDeath.isNotEmpty
          ? report.symptomsBeforeDeath
          : ['Animal Mortality Reported'],
      duration: 'Immediate',
      affectedCount: report.numberAffected.toString(),
      riskLevel: 'CRITICAL',
      village: _profile.village,
      block: _profile.block,
      district: _profile.district,
      state: _profile.state,
      status: FullCaseStatus.submitted,
      createdAt: report.createdAt,
      timeline: [
        CaseTimelineEvent(
          status: 'Report Submitted',
          description: 'Mortality reported: ${report.description ?? "Animal death"} (${report.numberAffected} affected).',
          actor: 'Farmer',
          timestamp: DateTime.now(),
        ),
        CaseTimelineEvent(
          status: 'Emergency Alert',
          description: 'Critical triage: Urgent veterinary investigation required.',
          actor: 'System',
          timestamp: DateTime.now(),
        ),
      ],
    );
    _cases.removeWhere((c) => c.caseId == caseId || c.reportId == report.id);
    _cases.insert(0, newCase);

    // 2. High priority alert to Vet
    addAlert(AppAlert(
      id: generateAlertId(),
      category: AlertCategory.mortalityAlert,
      title: '🚨 CRITICAL: Animal Mortality in ${_profile.village}',
      message: 'Farmer ${_profile.fullName} reported death of ${report.animalTag}. Suspected cause: ${report.description ?? report.symptomsBeforeDeath.join(", ")}.',
      severity: AlertSeverity.critical,
      relatedId: caseId,
      targetRole: 'VETERINARIAN',
    ));

    notifyListeners();

    try {
      await apiService.post('/cases/mortality', {
        'animal_id': report.animalId,
        'animal_tag': report.animalTag,
        'reason': report.description ?? report.symptomsBeforeDeath.join(', '),
        'species': 'Cow',
        'number_affected': report.numberAffected,
        'village': _profile.village,
        'block': _profile.block,
        'district': _profile.district,
        'state': _profile.state,
      });
      await fetchCases();
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting mortality report: $e');
      }
    }
  }

  // â”€â”€â”€ Vet Requests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<VetRequest> getVetRequests() => List.unmodifiable(_vetRequests);

  List<VetRequest> getVetRequestsForAnimal(String animalId) =>
      _vetRequests.where((r) => r.animalId == animalId).toList();

  void addVetRequest(VetRequest request) {
    _vetRequests.add(request);

    // 1. Immediately create a LivestockCase in _cases
    final caseId = request.id.startsWith('VR') ? request.id.replaceFirst('VR', 'CASE') : generateCaseId();
    final newCase = LivestockCase(
      caseId: caseId,
      reportId: request.id,
      farmerId: 'F001',
      farmerName: _profile.fullName,
      farmName: _profile.farmName ?? 'Green Meadows Farm',
      farmId: 'FARM001',
      animalId: request.animalId ?? '',
      animalTag: request.animalTag,
      species: 'Cow',
      symptoms: [request.reason],
      duration: '1 day',
      affectedCount: '1',
      riskLevel: 'HIGH',
      village: _profile.village,
      block: _profile.block,
      district: _profile.district,
      state: _profile.state,
      status: FullCaseStatus.submitted,
      createdAt: request.createdAt,
      timeline: [
        CaseTimelineEvent(
          status: 'Visit Requested',
          description: 'Farmer ${_profile.fullName} requested vet visit for ${request.animalTag}. Reason: ${request.reason}. Preferred: ${request.preferredTime ?? "Standard"}',
          actor: 'Farmer',
          timestamp: DateTime.now(),
        ),
      ],
    );
    _cases.removeWhere((c) => c.caseId == caseId || c.reportId == request.id);
    _cases.insert(0, newCase);

    // 2. Vet Notification
    addAlert(AppAlert(
      id: generateAlertId(),
      category: AlertCategory.veterinarianMessage,
      title: '🩺 Visit Request: ${request.animalTag}',
      message: 'Farmer ${_profile.fullName} requested visit for "${request.reason}". Slot: ${request.preferredTime ?? "Anytime"}.',
      severity: AlertSeverity.high,
      relatedId: caseId,
      targetRole: 'VETERINARIAN',
    ));

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

  // â”€â”€â”€ Vaccinations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<VaccinationRecord> getVaccinations() =>
      List.unmodifiable(_vaccinations);

  List<VaccinationRecord> getVaccinationsForAnimal(String animalId) =>
      _vaccinations.where((v) => v.animalId == animalId).toList();

  void addVaccination(VaccinationRecord record) {
    _vaccinations.add(record);
    notifyListeners();
  }

  // â”€â”€â”€ Treatments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<TreatmentRecord> getTreatments() => List.unmodifiable(_treatments);

  List<TreatmentRecord> getTreatmentsForAnimal(String animalId) =>
      _treatments.where((t) => t.animalId == animalId).toList();

  void addTreatment(TreatmentRecord record) {
    _treatments.add(record);
    notifyListeners();
  }

  // â”€â”€â”€ Alerts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> fetchAlerts({String? role}) async {
    try {
      final endpoint = role != null ? '/alerts?role=$role' : '/alerts';
      final response = await apiService.get(endpoint);
      if (response != null && response is List) {
        for (var item in response) {
          try {
            final id = item['id']?.toString() ?? '';
            // Skip duplicates
            if (_alerts.any((a) => a.id == id)) continue;

            // Map category string â†’ enum
            final rawCat = (item['category'] ?? '').toString().toLowerCase();
            AlertCategory category;
            if (rawCat.contains('mortality')) {
              category = AlertCategory.mortalityAlert;
            } else if (rawCat.contains('high_risk') || rawCat.contains('health')) {
              category = AlertCategory.highRiskHealthAlert;
            } else if (rawCat.contains('vaccination')) {
              category = AlertCategory.vaccinationReminder;
            } else if (rawCat.contains('advisory')) {
              category = AlertCategory.governmentAdvisory;
            } else if (rawCat.contains('weather')) {
              category = AlertCategory.weatherRisk;
            } else if (rawCat.contains('vet')) {
              category = AlertCategory.veterinarianMessage;
            } else {
              category = AlertCategory.diseaseAlert;
            }

            // Map severity string â†’ enum
            final rawSev = (item['severity'] ?? 'INFO').toString().toUpperCase();
            AlertSeverity severity;
            switch (rawSev) {
              case 'CRITICAL':
                severity = AlertSeverity.critical;
                break;
              case 'HIGH':
                severity = AlertSeverity.high;
                break;
              case 'WARNING':
              case 'MEDIUM':
                severity = AlertSeverity.warning;
                break;
              default:
                severity = AlertSeverity.info;
            }

            final alert = AppAlert(
              id: id,
              category: category,
              title: item['title']?.toString() ?? 'Alert',
              message: item['message']?.toString() ?? '',
              date: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
              isRead: item['is_read'] == true,
              severity: severity,
              relatedId: item['related_id']?.toString(),
              targetRole: item['target_role']?.toString() ?? 'ALL',
            );
            _alerts.insert(0, alert);
          } catch (e) {
            if (kDebugMode) print('Error parsing alert: $e');
          }
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching alerts: $e');
    }
  }

  List<AppAlert> getAlerts() =>
      List.unmodifiable(_alerts.reversed.toList());

  int get unreadAlertCount => _alerts.where((a) => !a.isRead).length;

  List<AppAlert> getFarmerAlerts() =>
      List.unmodifiable(_alerts.where((a) => a.targetRole == 'FARMER' || a.targetRole == 'ALL').toList().reversed);

  int get unreadFarmerAlertCount =>
      _alerts.where((a) => !a.isRead && (a.targetRole == 'FARMER' || a.targetRole == 'ALL')).length;

  List<AppAlert> getVetAlerts() =>
      List.unmodifiable(_alerts.where((a) => a.targetRole == 'VETERINARIAN' || a.targetRole == 'ALL').toList().reversed);

  int get unreadVetAlertCount =>
      _alerts.where((a) => !a.isRead && (a.targetRole == 'VETERINARIAN' || a.targetRole == 'ALL')).length;

  void addAlert(AppAlert alert) {
    _alerts.add(alert);
    notifyListeners();
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

  void markAllVetAlertsRead() {
    for (final a in _alerts) {
      if (a.targetRole == 'VETERINARIAN' || a.targetRole == 'ALL') {
        a.isRead = true;
      }
    }
    notifyListeners();
  }

  // â”€â”€â”€ Cases (shared with Vet & Govt) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  static String toBackendStatus(FullCaseStatus s) {
    switch (s) {
      case FullCaseStatus.submitted: return 'SUBMITTED';
      case FullCaseStatus.underReview: return 'UNDER_REVIEW';
      case FullCaseStatus.vetAssigned: return 'VET_ASSIGNED';
      case FullCaseStatus.visitScheduled: return 'VISIT_SCHEDULED';
      case FullCaseStatus.investigation: return 'INVESTIGATION';
      case FullCaseStatus.sampleCollected: return 'SAMPLE_COLLECTED';
      case FullCaseStatus.labReferred: return 'LAB_REFERRED';
      case FullCaseStatus.treatmentStarted: return 'TREATMENT_STARTED';
      case FullCaseStatus.followUpDue: return 'FOLLOW_UP_DUE';
      case FullCaseStatus.escalated: return 'ESCALATED';
      case FullCaseStatus.monitoring: return 'MONITORING';
      case FullCaseStatus.contained: return 'CONTAINED';
      case FullCaseStatus.caseClosed: return 'CASE_CLOSED';
    }
  }

  Future<void> updateCaseStatus(
    String caseId,
    FullCaseStatus status, {
    String? actor,
    String? description,
    DateTime? visitScheduledDate,
    String? assignedVetName,
    String? assignedVetId,
  }) async {
    final c = getCaseById(caseId);
    if (c != null) {
      c.status = status;
      if (visitScheduledDate != null) {
        c.visitScheduledDate = visitScheduledDate;
      }
      if (assignedVetName != null) {
        c.assignedVetName = assignedVetName;
      }
      if (assignedVetId != null) {
        c.assignedVetId = assignedVetId;
      }
      c.addTimelineEvent(
        status.displayName,
        description ?? 'Status updated to ${status.displayName}',
        actor: actor,
      );

      if (status == FullCaseStatus.escalated) {
        c.isEscalatedToGovt = true;
      }

      // Also update corresponding HealthReport if exists
      final rIdx = _healthReports.indexWhere((r) => r.id == c.reportId || r.id == c.caseId);
      if (rIdx != -1) {
        switch (status) {
          case FullCaseStatus.submitted:
            _healthReports[rIdx].caseStatus = CaseStatus.open;
            break;
          case FullCaseStatus.underReview:
            _healthReports[rIdx].caseStatus = CaseStatus.underReview;
            break;
          case FullCaseStatus.vetAssigned:
            _healthReports[rIdx].caseStatus = CaseStatus.vetAssigned;
            break;
          case FullCaseStatus.visitScheduled:
            _healthReports[rIdx].caseStatus = CaseStatus.visitScheduled;
            break;
          case FullCaseStatus.sampleCollected:
            _healthReports[rIdx].caseStatus = CaseStatus.sampleCollected;
            break;
          case FullCaseStatus.labReferred:
            _healthReports[rIdx].caseStatus = CaseStatus.labReferred;
            break;
          case FullCaseStatus.investigation:
            _healthReports[rIdx].caseStatus = CaseStatus.investigation;
            break;
          case FullCaseStatus.treatmentStarted:
          case FullCaseStatus.followUpDue:
          case FullCaseStatus.monitoring:
            _healthReports[rIdx].caseStatus = CaseStatus.treatmentStarted;
            break;
          case FullCaseStatus.escalated:
            _healthReports[rIdx].caseStatus = CaseStatus.escalated;
            break;
          case FullCaseStatus.contained:
          case FullCaseStatus.caseClosed:
            _healthReports[rIdx].caseStatus = CaseStatus.closed;
            break;
        }
      }

      // If escalated, ensure government alert is created
      if (status == FullCaseStatus.escalated) {
        _ensureGovtAlertForEscalatedCase(c, reason: description);
      }

      notifyListeners();

      try {
        final backendStatus = toBackendStatus(status);
        final payload = <String, dynamic>{
          'status': backendStatus,
          'description': description ?? '',
        };
        if (visitScheduledDate != null) {
          payload['visit_scheduled_date'] = visitScheduledDate.toIso8601String();
        }
        if (c.assignedVetName != null) {
          payload['assigned_vet_name'] = c.assignedVetName;
        }
        if (c.assignedVetId != null) {
          payload['assigned_vet_id'] = c.assignedVetId;
        }
        await apiService.put('/cases/$caseId/status', payload);
        await fetchCases();
      } catch (e) {
        if (kDebugMode) {
          print('Error updating case status: $e');
        }
      }
    }
  }

  Future<void> assignVetToCase(String caseId, String vetId, String vetName) async {
    final c = getCaseById(caseId);
    if (c != null) {
      c.assignedVetId = vetId;
      c.assignedVetName = vetName;
      await updateCaseStatus(
        caseId,
        FullCaseStatus.vetAssigned,
        actor: 'Veterinarian',
        description: '$vetName has been assigned to this case.',
      );

      try {
        await apiService.put('/cases/$caseId/assign', {
           'vet_id': vetId,
           'vet_name': vetName,
        });
        await fetchCases();
      } catch (e) {
        if (kDebugMode) {
          print('Error assigning vet: $e');
        }
      }
    }
  }

  void _ensureGovtAlertForEscalatedCase(LivestockCase c, {String? reason}) {
    c.isEscalatedToGovt = true;
    final alertTitle = 'ESCALATED CASE: ${c.species} (${c.animalTag}) - ${c.village}, ${c.district}';
    final existingIdx = _govtAlerts.indexWhere((a) => a.clusterId == c.caseId);

    if (existingIdx != -1) {
      final existing = _govtAlerts[existingIdx];
      existing.title = alertTitle;
      existing.riskLevel = ClusterRisk.high;
      existing.updatedAt = DateTime.now();
    } else {
      final alert = GovernmentAlert(
        id: generateAlertId(),
        clusterId: c.caseId,
        type: 'ESCALATED_CASE',
        riskLevel: ClusterRisk.high,
        title: alertTitle,
        location: '${c.village}, ${c.block}',
        district: c.district,
        state: c.state,
        species: c.species,
        animalCount: int.tryParse(c.affectedCount ?? '1') ?? 1,
        reportCount: 1,
        mortality: 0,
        symptoms: List.from(c.symptoms),
        suspectedDisease: c.symptoms.isNotEmpty ? c.symptoms.first : 'Critical Disease Outbreak',
        status: GovernmentAlertStatus.newAlert,
        createdAt: DateTime.now(),
      );
      _govtAlerts.insert(0, alert);
    }

    // Also send an urgent alert to the Farmer
    addAlert(AppAlert(
      id: generateAlertId(),
      category: AlertCategory.veterinarianMessage,
      title: 'Case #${c.caseId} Escalated to Government',
      message: 'Dr. ${c.assignedVetName ?? "Field Veterinarian"} escalated this case to regional animal health authorities for emergency assistance.',
      severity: AlertSeverity.high,
      relatedId: c.caseId,
      targetRole: 'FARMER',
    ));
  }

  Future<void> escalateCase(String caseId, {String? reason}) async {
    final c = getCaseById(caseId);
    if (c != null) {
      await updateCaseStatus(
        caseId,
        FullCaseStatus.escalated,
        actor: 'Veterinarian',
        description: reason ?? 'Case escalated by Veterinarian to State Government Surveillance for priority intervention.',
      );
    }
  }

  // â”€â”€â”€ Samples â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€â”€ Vet Visits â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<VetVisit> getAllVisits() => List.unmodifiable(_vetVisits);
  List<VetVisit> getVisitsForCase(String caseId) =>
      _vetVisits.where((v) => v.caseId == caseId).toList();

  /// Returns all visits relevant to the current farmer (deduplicated & merged with cases)
  List<VetVisit> getFarmerVisits() {
    final visits = <VetVisit>[..._vetVisits];

    // Also include any cases that have visitScheduledDate if not already in visits list
    for (final c in _cases) {
      if (c.visitScheduledDate != null && !visits.any((v) => v.caseId == c.caseId)) {
        visits.add(VetVisit(
          visitId: 'VIS_${c.caseId}',
          caseId: c.caseId,
          farmerId: c.farmerId,
          farmerName: c.farmerName,
          farmLocation: '${c.village}, ${c.block}, ${c.district}',
          vetId: c.assignedVetId ?? 'VET001',
          vetName: c.assignedVetName ?? 'Dr. Rajesh Kumar',
          scheduledDate: c.visitScheduledDate!,
          observations: c.clinicalObservation,
          treatmentGiven: c.treatmentSummary,
          isCompleted: c.status == FullCaseStatus.treatmentStarted || c.status == FullCaseStatus.caseClosed,
        ));
      }
    }
    visits.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return visits;
  }

  void addVetVisit(VetVisit visit) {
    final existingIdx = _vetVisits.indexWhere((v) => v.visitId == visit.visitId);
    if (existingIdx != -1) {
      _vetVisits[existingIdx] = visit;
    } else {
      _vetVisits.insert(0, visit);
    }

    final c = getCaseById(visit.caseId);
    if (c != null) {
      c.visitScheduledDate = visit.scheduledDate;
      c.assignedVetName = visit.vetName;
      c.assignedVetId = visit.vetId;
      if (visit.observations != null && visit.observations!.isNotEmpty) {
        c.clinicalObservation = visit.observations;
      }
      if (visit.treatmentGiven != null && visit.treatmentGiven!.isNotEmpty) {
        c.treatmentSummary = visit.treatmentGiven;
      }
    }

    // Add alert notification for farmer
    addAlert(AppAlert(
      id: generateAlertId(),
      category: AlertCategory.veterinarianMessage,
      title: '🩺 Visit Scheduled: ${visit.vetName}',
      message: '${visit.vetName} has scheduled a farm visit on ${visit.scheduledDate.day}/${visit.scheduledDate.month}/${visit.scheduledDate.year} for animal ${c?.animalTag ?? "livestock"}.',
      severity: AlertSeverity.info,
      relatedId: visit.caseId,
      targetRole: 'FARMER',
    ));

    final description = visit.isCompleted && visit.treatmentGiven != null && visit.treatmentGiven!.isNotEmpty
        ? 'Visit completed. Treatment given: ${visit.treatmentGiven}'
        : 'Field visit scheduled for ${visit.scheduledDate.day}/${visit.scheduledDate.month}/${visit.scheduledDate.year} by ${visit.vetName}.';

    updateCaseStatus(
      visit.caseId,
      visit.isCompleted ? FullCaseStatus.treatmentStarted : FullCaseStatus.visitScheduled,
      actor: 'Veterinarian',
      description: description,
      visitScheduledDate: visit.scheduledDate,
      assignedVetName: visit.vetName,
      assignedVetId: visit.vetId,
    );
    notifyListeners();
  }

  // â”€â”€â”€ Advisories â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<Advisory> getAllAdvisories() => List.unmodifiable(_advisories);
  List<Advisory> getPublishedAdvisories() =>
      _advisories.where((a) => a.status == AdvisoryStatus.published).toList();

  void addAdvisory(Advisory advisory) {
    _advisories.add(advisory);
    notifyListeners();
  }

  Future<void> publishAdvisory(String advisoryId) async {
    final adv = _advisories.firstWhere((a) => a.advisoryId == advisoryId);
    adv.publish();
    notifyListeners();

    try {
      await apiService.put('/advisories/$advisoryId', {
        'status': 'PUBLISHED',
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error publishing advisory: $e');
      }
    }
  }

  // â”€â”€â”€ Government Alerts (Synchronized from High-Risk Clusters) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  // â”€â”€â”€ Government Alerts (Synchronized from High-Risk Clusters) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€â”€ Clusters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  /// Government Portal Cluster Fetch â€” Returns STRICTLY HIGH-RISK or Escalated clusters
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

  Future<void> escalateCluster(String clusterId) async {
    final c = getClusterById(clusterId);
    if (c != null) {
      c.status = ClusterStatus.escalated;
      c.riskLevel = ClusterRisk.high;
      c.updatedAt = DateTime.now();
      createGovernmentAlertIfNotExists(c);
      notifyListeners();

      try {
        await apiService.post('/clusters', {
          'name': c.name,
          'location': c.location,
          'village': c.village,
          'block': c.block,
          'district': c.district,
          'state': c.state,
          'risk_level': 'HIGH',
          'species': c.species,
          'report_count': c.reportCount,
          'animal_count': c.animalCount,
          'mortality': c.mortality,
          'symptoms': c.symptoms,
          'suspected_disease': c.suspectedDisease,
          'description': 'Escalated to Government',
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error escalating cluster: $e');
        }
      }
    }
  }

  // â”€â”€â”€ Response Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  // â”€â”€â”€ Response Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<ResponseAction> getAllResponseActions() => List.unmodifiable(_responseActions);

  void addResponseAction(ResponseAction action) {
    _responseActions.add(action);
    notifyListeners();
  }

  // â”€â”€â”€ Government Surveillance getters â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€â”€ Dashboard Statistics â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€â”€ Recent Activity â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<Map<String, dynamic>> getRecentActivity({int limit = 10}) {
    final activities = <Map<String, dynamic>>[];

    for (final a in _animals) {
      activities.add({
        'type': 'animal_added',
        'title': 'Animal Registered',
        'subtitle': '${a.species.emoji} ${a.species.displayName} (${a.earTag}) Â· ${a.breed}',
        'date': a.createdAt,
        'icon': 'pets',
      });
    }

    for (final r in _healthReports) {
      activities.add({
        'type': 'health_report',
        'title': 'Health Report: ${r.animalTag}',
        'subtitle': '${r.riskLevel.displayName} Risk â€” ${r.symptoms.take(2).join(", ")}',
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

  // â”€â”€â”€ ID generation helpers (public) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€â”€ Demo data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Seeds rich demo data for showcasing all three modules.
  /// Pass [force] = true to re-seed even if data is already loaded.
  void seedDemoData({bool force = false}) {
    if (_animals.isNotEmpty && !force) return;

    // Clear existing in-memory data to avoid duplicates on force re-seed
    if (force) {
      _animals.clear();
      _vaccinations.clear();
      _healthReports.clear();
      _mortalityReports.clear();
      _cases.clear();
      _samples.clear();
      _vetVisits.clear();
      _treatments.clear();
      _alerts.clear();
      _clusters.clear();
      _advisories.clear();
      _responseActions.clear();
      _govtAlerts.clear();
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ANIMALS (3)
    // ═══════════════════════════════════════════════════════════════════════
    final cow1 = Animal(
      id: 'ANM001',
      earTag: 'C001',
      species: AnimalSpecies.cow,
      breed: 'Jersey',
      gender: AnimalGender.female,
      age: '3 years',
      healthStatus: HealthStatus.activeCase,
    );
    final cow2 = Animal(
      id: 'ANM002',
      earTag: 'C002',
      species: AnimalSpecies.cow,
      breed: 'Holstein Friesian (HF)',
      gender: AnimalGender.female,
      age: '6 years',
      healthStatus: HealthStatus.underMonitoring,
    );
    final goat1 = Animal(
      id: 'ANM003',
      earTag: 'G001',
      species: AnimalSpecies.goat,
      breed: 'Boer',
      gender: AnimalGender.male,
      age: '1.5 years',
      healthStatus: HealthStatus.healthy,
    );
    _animals.addAll([cow1, cow2, goat1]);

    // ═══════════════════════════════════════════════════════════════════════
    // VACCINATIONS (3)
    // ═══════════════════════════════════════════════════════════════════════
    _vaccinations.addAll([
      VaccinationRecord(
        id: 'VAC001',
        animalId: 'ANM001',
        animalTag: 'C001',
        vaccineName: 'Foot & Mouth Disease (FMD)',
        nextDueDate: DateTime.now().add(const Duration(days: 7)),
        status: VaccinationStatus.due,
        veterinarian: 'Dr. Rajesh Kumar',
      ),
      VaccinationRecord(
        id: 'VAC002',
        animalId: 'ANM002',
        animalTag: 'C002',
        vaccineName: 'Haemorrhagic Septicaemia (HS)',
        nextDueDate: DateTime.now().add(const Duration(days: 30)),
        status: VaccinationStatus.upcoming,
        veterinarian: 'Dr. Rajesh Kumar',
      ),
      VaccinationRecord(
        id: 'VAC003',
        animalId: 'ANM003',
        animalTag: 'G001',
        vaccineName: 'PPR (Peste des Petits Ruminants)',
        date: DateTime.now().subtract(const Duration(days: 60)),
        nextDueDate: DateTime.now().add(const Duration(days: 305)),
        status: VaccinationStatus.completed,
        veterinarian: 'Dr. Priya Nair',
        isVerified: true,
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // TREATMENTS (1)
    // ═══════════════════════════════════════════════════════════════════════
    _treatments.add(
      TreatmentRecord(
        id: 'TRT001',
        animalId: 'ANM001',
        animalTag: 'C001',
        condition: 'Foot & Mouth Disease (Suspected)',
        treatment: 'Antibiotic course + Wound spray',
        medicine: 'Oxytetracycline 10% injection + Potassium permanganate wash',
        instructions: 'Wash mouth and feet lesions 2x daily; 15ml IM injection for 3 days',
        veterinarian: 'Dr. Rajesh Kumar',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        followUpDate: DateTime.now().add(const Duration(days: 3)),
        status: TreatmentStatus.ongoing,
      ),
    );

    // ═══════════════════════════════════════════════════════════════════════
    // HEALTH REPORTS (2)
    // ═══════════════════════════════════════════════════════════════════════
    _healthReports.addAll([
      HealthReport(
        id: 'RPT001',
        animalId: 'ANM001',
        animalTag: 'C001',
        species: 'Cow',
        breed: 'Jersey',
        age: '3 years',
        symptoms: ['High Fever', 'Blisters in Mouth', 'Excessive Salivation', 'Limping'],
        duration: '2–3 days',
        eatingStatus: 'No',
        drinkingStatus: 'Less than usual',
        affectedCount: '1',
        isLactating: true,
        riskLevel: RiskLevel.high,
        title: 'High fever and mouth blisters',
        advice: 'Isolate the animal immediately. Wear gloves while handling.',
        recommendedAction: 'Immediate veterinary visit required.',
        description: 'Cow has had high fever since yesterday. Salivating heavily and cannot graze.',
        caseStatus: CaseStatus.treatmentStarted,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HealthReport(
        id: 'RPT002',
        animalId: 'ANM002',
        animalTag: 'C002',
        species: 'Cow',
        breed: 'Holstein Friesian (HF)',
        age: '6 years',
        symptoms: ['Reduced Milk Yield', 'Swollen Udder', 'Loss of Appetite'],
        duration: '1 day',
        eatingStatus: 'Less than usual',
        drinkingStatus: 'Yes',
        affectedCount: '1',
        isLactating: true,
        riskLevel: RiskLevel.medium,
        title: 'Swollen udder and milk drop',
        advice: 'Keep udder clean and dry. Avoid milking into common bucket.',
        recommendedAction: 'Veterinary consultation recommended within 24h.',
        description: 'Right rear quarter feels hot and hard. Milk appears yellowish with clots.',
        caseStatus: CaseStatus.open,
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // MORTALITY REPORTS (1)
    // ═══════════════════════════════════════════════════════════════════════
    _mortalityReports.add(
      MortalityReport(
        id: 'MOR001',
        animalTag: 'C009',
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: '07:30 AM',
        location: 'Uruli Kanchan, Pune',
        symptomsBeforeDeath: ['Sudden Collapse', 'Bloody Discharge from Nostrils', 'High Fever'],
        numberAffected: 1,
        description: 'Cow collapsed suddenly in the morning. Noticeable bloody discharge from nose. Suspected Anthrax or acute septicaemia.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    // ═══════════════════════════════════════════════════════════════════════
    // CASES (6)
    // ═══════════════════════════════════════════════════════════════════════
    _cases.addAll([
      LivestockCase(
        caseId: 'CASE001',
        reportId: 'RPT001',
        farmerId: 'FAR001',
        farmerName: 'Ramesh Pawar',
        farmName: 'Green Meadows Farm',
        animalId: 'ANM001',
        animalTag: 'C001',
        species: 'Cow',
        breed: 'Jersey',
        age: '3 years',
        gender: 'Female',
        symptoms: ['High Fever', 'Blisters in Mouth', 'Excessive Salivation', 'Limping'],
        duration: '2–3 days',
        affectedCount: '1',
        otherAnimalsAffected: 'None yet',
        nearbyFarmsAffected: 'Yes (1 neighbour)',
        recentMovement: 'None',
        riskLevel: 'HIGH',
        village: 'Uruli Kanchan',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        hasPhoto: true,
        status: FullCaseStatus.treatmentStarted,
        assignedVetId: 'VET001',
        assignedVetName: 'Dr. Rajesh Kumar',
        visitScheduledDate: DateTime.now().add(const Duration(days: 3, hours: 9)),
        clinicalObservation: 'Vesicular lesions on dental pad and tongue. Interdigital ulcers on left forelimb. Temp: 104.2°F.',
        treatmentSummary: 'Oxytetracycline 10% 15ml IM OD x 3d; Meloxicam 10ml IM; Antiseptic foot bath.',
        sampleId: 'SMP001',
        isEscalatedToGovt: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        timeline: [
          CaseTimelineEvent(
            status: 'submitted',
            description: 'Health report submitted by farmer Ramesh Pawar',
            actor: 'Farmer',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          CaseTimelineEvent(
            status: 'vetAssigned',
            description: 'Assigned to Dr. Rajesh Kumar for urgent field investigation',
            actor: 'System',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 23)),
          ),
          CaseTimelineEvent(
            status: 'visitScheduled',
            description: 'First clinical visit conducted by Dr. Rajesh Kumar',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 14)),
          ),
          CaseTimelineEvent(
            status: 'sampleCollected',
            description: 'Blood & vesicular swab sample (SMP001) collected for FMD PCR typing',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
          ),
          CaseTimelineEvent(
            status: 'treatmentStarted',
            description: 'Treatment initiated with Oxytetracycline and antiseptic dressing. Follow-up scheduled.',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
          ),
        ],
      ),
      LivestockCase(
        caseId: 'CASE002',
        reportId: 'RPT003',
        farmerId: 'FAR002',
        farmerName: 'Suresh Mane',
        farmName: 'Mane Dairy Farm',
        animalId: 'ANM010',
        animalTag: 'C010',
        species: 'Cow',
        breed: 'Sahiwal',
        age: '4 years',
        gender: 'Female',
        symptoms: ['High Fever', 'Laboured Breathing', 'Swelling in Neck/Throat'],
        duration: '1 day',
        affectedCount: '2',
        otherAnimalsAffected: '1 other calf showing cough',
        nearbyFarmsAffected: 'Not sure',
        riskLevel: 'HIGH',
        village: 'Loni Kalbhor',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        status: FullCaseStatus.vetAssigned,
        assignedVetId: 'VET001',
        assignedVetName: 'Dr. Rajesh Kumar',
        visitScheduledDate: DateTime.now().add(const Duration(hours: 4)),
        clinicalObservation: 'Submandibular oedema and dyspnoea noted over phone. Suspected Haemorrhagic Septicaemia.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        timeline: [
          CaseTimelineEvent(
            status: 'submitted',
            description: 'Urgent report submitted: throat swelling and high fever',
            actor: 'Farmer',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          CaseTimelineEvent(
            status: 'vetAssigned',
            description: 'Case assigned to Dr. Rajesh Kumar. Field visit en route.',
            actor: 'System',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      LivestockCase(
        caseId: 'CASE003',
        reportId: 'RPT004',
        farmerId: 'FAR003',
        farmerName: 'Lakshmi Devi',
        farmName: 'Devi Livestock',
        animalId: 'ANM020',
        animalTag: 'B001',
        species: 'Buffalo',
        breed: 'Murrah',
        age: '5 years',
        gender: 'Female',
        symptoms: ['Sudden High Fever', 'Severe Diarrhea', 'Oral Mucosal Ulcers', 'Eye Discharge'],
        duration: '3 days',
        affectedCount: '4',
        otherAnimalsAffected: '3 other buffaloes in herd infected',
        nearbyFarmsAffected: 'Yes (2 neighbouring herds)',
        riskLevel: 'CRITICAL',
        village: 'Manjari Khurd',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        status: FullCaseStatus.submitted,
        isEscalatedToGovt: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        timeline: [
          CaseTimelineEvent(
            status: 'submitted',
            description: 'Critical outbreak reported: 4 buffaloes affected with severe mucosal ulcers and diarrhea',
            actor: 'Farmer',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      LivestockCase(
        caseId: 'CASE004',
        reportId: 'MOR001',
        farmerId: 'FAR001',
        farmerName: 'Ramesh Pawar',
        farmName: 'Green Meadows Farm',
        animalId: 'ANM009',
        animalTag: 'C009',
        species: 'Cow',
        breed: 'Jersey Cross',
        age: '2.5 years',
        gender: 'Female',
        symptoms: ['Sudden Collapse', 'Bloody Discharge from Nostrils', 'High Fever'],
        duration: 'Sudden death (<4 hours)',
        affectedCount: '1',
        otherAnimalsAffected: 'None observed',
        riskLevel: 'CRITICAL',
        village: 'Uruli Kanchan',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        status: FullCaseStatus.submitted,
        isEscalatedToGovt: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        timeline: [
          CaseTimelineEvent(
            status: 'submitted',
            description: 'Mortality report filed: Sudden death with epistaxis. Anthrax protocol alerted.',
            actor: 'Farmer',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      LivestockCase(
        caseId: 'CASE005',
        reportId: 'RPT005',
        farmerId: 'FAR004',
        farmerName: 'Manoj Yadav',
        farmName: 'Yadav Goat Farm',
        animalId: 'ANM040',
        animalTag: 'G015',
        species: 'Goat',
        breed: 'Sirohi',
        age: '2 years',
        gender: 'Male',
        symptoms: ['Nasal Discharge', 'Erosive Stomatitis', 'Profuse Watery Diarrhea', 'High Fever'],
        duration: '4 days',
        affectedCount: '6',
        otherAnimalsAffected: '6 goats out of 25 in herd affected',
        nearbyFarmsAffected: 'Yes',
        riskLevel: 'MEDIUM',
        village: 'Wagholi',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        status: FullCaseStatus.labReferred,
        assignedVetId: 'VET002',
        assignedVetName: 'Dr. Priya Nair',
        sampleId: 'SMP002',
        clinicalObservation: 'Purulent nasal discharge, necrotic mouth ulcers, severe watery diarrhea. PPR suspected.',
        treatmentSummary: 'Fluid therapy, Enrofloxacin, Supportive antipyretics.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        timeline: [
          CaseTimelineEvent(
            status: 'submitted',
            description: 'Cluster of sick goats reported by Manoj Yadav',
            actor: 'Farmer',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
          ),
          CaseTimelineEvent(
            status: 'vetAssigned',
            description: 'Dr. Priya Nair assigned for clinical assessment',
            actor: 'System',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
          ),
          CaseTimelineEvent(
            status: 'investigation',
            description: 'On-farm necropsy & clinical exam completed',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 14)),
          ),
          CaseTimelineEvent(
            status: 'sampleCollected',
            description: 'Nasal swab and mesenteric lymph node aspirate collected (SMP002)',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
          ),
          CaseTimelineEvent(
            status: 'labReferred',
            description: 'Samples dispatched to Disease Investigation Section, Pune',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          ),
        ],
      ),
      LivestockCase(
        caseId: 'CASE006',
        reportId: 'RPT006',
        farmerId: 'FAR005',
        farmerName: 'Rekha Patil',
        farmName: 'Patil Dairy',
        animalId: 'ANM030',
        animalTag: 'C030',
        species: 'Cow',
        breed: 'Red Sindhi',
        age: '5 years',
        gender: 'Female',
        symptoms: ['Mild Fever', 'Superficial Foot Sores'],
        duration: 'Resolved',
        affectedCount: '1',
        otherAnimalsAffected: 'None',
        riskLevel: 'MEDIUM',
        village: 'Uruli Kanchan',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        status: FullCaseStatus.caseClosed,
        assignedVetId: 'VET001',
        assignedVetName: 'Dr. Rajesh Kumar',
        clinicalObservation: 'Foot lesions fully epithelialized. Animal alert, ruminating normally, milk yield restored.',
        treatmentSummary: 'Completed 5-day course of Cefuroxime & flunixin. Animal fully recovered.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        timeline: [
          CaseTimelineEvent(
            status: 'submitted',
            description: 'Mild foot sores reported',
            actor: 'Farmer',
            timestamp: DateTime.now().subtract(const Duration(days: 12)),
          ),
          CaseTimelineEvent(
            status: 'treatmentStarted',
            description: 'Antibiotic therapy initiated',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 10)),
          ),
          CaseTimelineEvent(
            status: 'caseClosed',
            description: 'Final recovery confirmed by Dr. Rajesh Kumar. Case closed.',
            actor: 'Veterinarian',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // SAMPLES (2)
    // ═══════════════════════════════════════════════════════════════════════
    _samples.addAll([
      Sample(
        sampleId: 'SMP001',
        caseId: 'CASE001',
        animalId: 'ANM001',
        animalTag: 'C001',
        sampleType: 'Blood & Vesicular Fluid',
        collectionDate: '2026-09-07',
        collectionLocation: 'Green Meadows Farm, Uruli Kanchan',
        reason: 'Suspected Foot & Mouth Disease typing (O/A/Asia-1)',
        laboratory: 'Disease Investigation Section, Pune',
        status: SampleStatus.sentToLab,
        collectedBy: 'Dr. Rajesh Kumar',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      ),
      Sample(
        sampleId: 'SMP002',
        caseId: 'CASE005',
        animalId: 'ANM040',
        animalTag: 'G015',
        sampleType: 'Nasal Swab & Lymph Node Aspirate',
        collectionDate: '2026-09-07',
        collectionLocation: 'Yadav Goat Farm, Wagholi',
        reason: 'PPR Antigen Detection (ELISA/RT-PCR)',
        laboratory: 'State Veterinary Biologicals Institute, Pune',
        status: SampleStatus.sentToLab,
        collectedBy: 'Dr. Priya Nair',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // VET VISITS (2)
    // ═══════════════════════════════════════════════════════════════════════
    _vetVisits.addAll([
      VetVisit(
        visitId: 'VIS001',
        caseId: 'CASE001',
        farmerId: 'FAR001',
        farmerName: 'Ramesh Pawar',
        farmLocation: 'Uruli Kanchan, Haveli, Pune',
        vetId: 'VET001',
        vetName: 'Dr. Rajesh Kumar',
        scheduledDate: DateTime.now().subtract(const Duration(hours: 8)),
        actualDate: DateTime.now().subtract(const Duration(hours: 6)),
        observations: 'Oral ulcers observed on dental pad and tongue. Interdigital sores with mild purulent discharge. Temperature: 104.2°F. Animal isolated.',
        animalsExamined: '1 cow (C001)',
        symptomsObserved: 'Fever, salivation, mouth ulcers, lameness',
        preliminaryAssessment: 'Acute Foot & Mouth Disease (FMD) — high suspicion',
        actionTaken: 'Ring vaccination advised for herd. Lesions cleaned with KMNO4.',
        treatmentGiven: 'Inj. Oxytetracycline 15ml IM, Inj. Meloxicam 10ml IM, Antiseptic foot spray applied',
        followUpDate: DateTime.now().add(const Duration(days: 3)),
        isCompleted: true,
      ),
      VetVisit(
        visitId: 'VIS002',
        caseId: 'CASE001',
        farmerId: 'FAR001',
        farmerName: 'Ramesh Pawar',
        farmLocation: 'Uruli Kanchan, Haveli, Pune',
        vetId: 'VET001',
        vetName: 'Dr. Rajesh Kumar',
        scheduledDate: DateTime.now().add(const Duration(days: 3, hours: 9)),
        observations: 'Scheduled follow-up: Evaluate healing of oral & foot lesions, assess milk recovery, complete antibiotic booster.',
        isCompleted: false,
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // OUTBREAK CLUSTERS (3)
    // ═══════════════════════════════════════════════════════════════════════
    _clusters.addAll([
      OutbreakCluster(
        clusterId: 'CLU001',
        name: 'Haveli FMD Outbreak Cluster',
        location: 'Uruli Kanchan, Haveli, Pune',
        village: 'Uruli Kanchan',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        latitude: 18.4852,
        longitude: 74.1357,
        riskLevel: ClusterRisk.high,
        species: 'Cattle & Buffalo',
        reportCount: 5,
        animalCount: 8,
        mortality: 1,
        symptoms: ['High Fever', 'Blisters in Mouth', 'Lameness', 'Salivation'],
        suspectedDisease: 'Foot & Mouth Disease (FMD)',
        description: 'Active multi-farm cluster in Uruli Kanchan and adjoining villages. 1 sudden mortality reported. Containment zone established.',
        status: ClusterStatus.investigation,
        detectedAt: DateTime.now().subtract(const Duration(days: 4)),
        createdBy: 'Dr. Rajesh Kumar (VAS Haveli)',
        caseIds: ['CASE001', 'CASE002', 'CASE004'],
        responseActionId: 'ACT001',
      ),
      OutbreakCluster(
        clusterId: 'CLU002',
        name: 'Wagholi Caprine Respiratory Cluster',
        location: 'Wagholi, Haveli, Pune',
        village: 'Wagholi',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        latitude: 18.5793,
        longitude: 73.9822,
        riskLevel: ClusterRisk.medium,
        species: 'Goat',
        reportCount: 3,
        animalCount: 14,
        mortality: 0,
        symptoms: ['Nasal Discharge', 'Mouth Ulcers', 'Profuse Diarrhea', 'High Fever'],
        suspectedDisease: 'Peste des Petits Ruminants (PPR)',
        description: 'Cluster of small ruminant respiratory and enteric illness across 2 smallholdings in Wagholi.',
        status: ClusterStatus.monitoring,
        detectedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdBy: 'Dr. Priya Nair (VAS Wagholi)',
        caseIds: ['CASE005'],
        responseActionId: 'ACT002',
      ),
      OutbreakCluster(
        clusterId: 'CLU003',
        name: 'Loni Kalbhor HS Watch',
        location: 'Loni Kalbhor, Haveli, Pune',
        village: 'Loni Kalbhor',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        latitude: 18.4900,
        longitude: 74.0200,
        riskLevel: ClusterRisk.low,
        species: 'Cattle',
        reportCount: 1,
        animalCount: 2,
        mortality: 0,
        symptoms: ['Throat Swelling', 'High Fever', 'Dyspnoea'],
        suspectedDisease: 'Haemorrhagic Septicaemia (HS)',
        description: 'Single-farm presentation in Loni Kalbhor. Immediate vaccination barrier initiated.',
        status: ClusterStatus.contained,
        detectedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'Dr. Rajesh Kumar (VAS Haveli)',
        caseIds: ['CASE002'],
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // GOVERNMENT ADVISORIES (2)
    // ═══════════════════════════════════════════════════════════════════════
    _advisories.addAll([
      Advisory(
        advisoryId: 'ADV001',
        title: '🚨 Urgent: Foot & Mouth Disease Alert — Haveli Block',
        message: 'Suspected FMD cases confirmed in Uruli Kanchan and surrounding areas. Farmers are advised: 1) Avoid taking cattle to common grazing grounds. 2) Restrict purchase/movement of livestock. 3) Report any animal with mouth or foot blisters immediately.',
        target: AdvisoryTarget.block,
        targetLocation: 'Haveli',
        language: 'en',
        createdBy: 'District Animal Husbandry Officer, Pune',
        status: AdvisoryStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Advisory(
        advisoryId: 'ADV002',
        title: '📢 Free FMD & HS Ring Vaccination Camp',
        message: 'Free emergency vaccination camp will be conducted from Sep 10-12 at Uruli Kanchan Veterinary Dispensary. Bring all cattle and buffaloes older than 4 months.',
        target: AdvisoryTarget.village,
        targetLocation: 'Uruli Kanchan',
        language: 'en',
        createdBy: 'Livestock Development Officer, Pune',
        status: AdvisoryStatus.published,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // RESPONSE ACTIONS (2)
    // ═══════════════════════════════════════════════════════════════════════
    _responseActions.addAll([
      ResponseAction(
        actionId: 'ACT001',
        clusterId: 'CLU001',
        type: ResponseActionType.fieldVisit,
        title: 'Rapid Response Team Field Investigation — Uruli Kanchan',
        description: 'Deploy RRT veterinarians to conduct clinical surveillance, epidemiological tracing, and biological sampling across 5km radius of Uruli Kanchan.',
        location: 'Uruli Kanchan, Haveli, Pune',
        assignedTo: 'Dr. Rajesh Kumar (RRT Lead)',
        status: ResponseActionStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ResponseAction(
        actionId: 'ACT002',
        clusterId: 'CLU001',
        type: ResponseActionType.vaccinationDrive,
        title: 'Ring Vaccination (FMD + HS) — 3km Buffer Zone',
        description: 'Emergency vaccination of all susceptible bovines within 3km radius of outbreak epicenter (approx 1,200 animals).',
        location: 'Haveli Block, Pune',
        assignedTo: 'Veterinary Mobile Clinic Unit 2',
        status: ResponseActionStatus.planned,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    // ═══════════════════════════════════════════════════════════════════════
    // ROLE-ROUTED ALERTS (7 FARMER + 3 VETERINARIAN)
    // ═══════════════════════════════════════════════════════════════════════
    _alerts.addAll([
      // Farmer Alerts
      AppAlert(
        id: 'ALT001',
        category: AlertCategory.highRiskHealthAlert,
        title: 'Health Report Under Treatment: C001',
        message: 'Dr. Rajesh Kumar initiated treatment for Cow C001 (Jersey). Follow prescribed medication twice daily.',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
        isRead: true,
        severity: AlertSeverity.high,
        relatedId: 'CASE001',
        targetRole: 'FARMER',
      ),
      AppAlert(
        id: 'ALT002',
        category: AlertCategory.veterinarianMessage,
        title: 'Lab Sample Collected (SMP001)',
        message: 'Blood and swab samples collected from Cow C001 have been dispatched to Disease Investigation Section, Pune.',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        isRead: true,
        severity: AlertSeverity.info,
        relatedId: 'SMP001',
        targetRole: 'FARMER',
      ),
      AppAlert(
        id: 'ALT003',
        category: AlertCategory.followUpReminder,
        title: 'Upcoming Vet Follow-Up Visit Confirmed',
        message: 'Dr. Rajesh Kumar scheduled a follow-up clinical visit for Cow C001 in 3 days. Please ensure the animal is secured.',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
        severity: AlertSeverity.warning,
        relatedId: 'VIS002',
        targetRole: 'FARMER',
      ),
      AppAlert(
        id: 'ALT004',
        category: AlertCategory.vaccinationReminder,
        title: 'Vaccination Due: Cow C001 (FMD Booster)',
        message: 'Annual Foot & Mouth Disease booster vaccination is due within 7 days for Cow C001.',
        date: DateTime.now().subtract(const Duration(hours: 12)),
        isRead: false,
        severity: AlertSeverity.warning,
        relatedId: 'VAC001',
        targetRole: 'FARMER',
      ),
      AppAlert(
        id: 'ALT005',
        category: AlertCategory.mortalityAlert,
        title: 'Mortality Report Recorded (C009)',
        message: 'Mortality report for Cow C009 logged. Veterinary authorities notified. Maintain biosecurity on farm.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        severity: AlertSeverity.critical,
        relatedId: 'MOR001',
        targetRole: 'FARMER',
      ),
      AppAlert(
        id: 'ALT006',
        category: AlertCategory.governmentAdvisory,
        title: '🚨 Urgent: FMD Alert — Haveli Block',
        message: 'District AH Dept issued an outbreak advisory for Haveli Block. Avoid cattle movement and common grazing.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isRead: false,
        severity: AlertSeverity.high,
        relatedId: 'ADV001',
        targetRole: 'FARMER',
      ),
      AppAlert(
        id: 'ALT007',
        category: AlertCategory.governmentAdvisory,
        title: '📢 Free Vaccination Camp: Uruli Kanchan',
        message: 'Free ring vaccination camp Sep 10-12 at Uruli Kanchan Veterinary Dispensary.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        severity: AlertSeverity.info,
        relatedId: 'ADV002',
        targetRole: 'FARMER',
      ),
      // Veterinarian Alerts
      AppAlert(
        id: 'ALT010',
        category: AlertCategory.mortalityAlert,
        title: '🚨 Urgent Mortality: Cow C009 (Uruli Kanchan)',
        message: 'Sudden death reported with nasal bleeding at Green Meadows Farm (Ramesh Pawar). Immediate carcass inspection & biosecurity required.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        severity: AlertSeverity.critical,
        relatedId: 'CASE004',
        targetRole: 'VETERINARIAN',
      ),
      AppAlert(
        id: 'ALT011',
        category: AlertCategory.highRiskHealthAlert,
        title: '🚨 CRITICAL: 4 Buffaloes Affected (Manjari Khurd)',
        message: 'Farmer Lakshmi Devi reported 4 Murrah buffaloes with severe diarrhea, mucosal ulcers, and high fever. Potential outbreak.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        severity: AlertSeverity.critical,
        relatedId: 'CASE003',
        targetRole: 'VETERINARIAN',
      ),
      AppAlert(
        id: 'ALT012',
        category: AlertCategory.diseaseAlert,
        title: 'New High-Risk Case: Cow C010 (Loni Kalbhor)',
        message: 'Suresh Mane reported high fever and throat swelling in Sahiwal cow. Assigned to Dr. Rajesh Kumar.',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        severity: AlertSeverity.high,
        relatedId: 'CASE002',
        targetRole: 'VETERINARIAN',
      ),
    ]);

    notifyListeners();
  }
}
