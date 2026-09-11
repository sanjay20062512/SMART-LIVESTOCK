import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/farmer_data_service.dart';
import 'package:flutter_app/models/health_report.dart';
import 'package:flutter_app/models/case.dart';
import 'package:flutter_app/models/sample.dart';
import 'package:flutter_app/models/vet_visit.dart';
import 'package:flutter_app/models/cluster.dart';
import 'package:flutter_app/models/advisory.dart';
import 'package:flutter_app/models/government_alert.dart';

void main() {
  group('Farmer -> Veterinary -> Government End-to-End Pipeline', () {
    late FarmerDataService service;

    setUp(() {
      service = FarmerDataService();
      // Initialize with seed data
      service.seedDemoData();
    });

    test('1. Farmer submits health report -> instantly creates case & triggers Vet alert', () async {
      final initialCaseCount = service.getAllCases().length;

      final report = HealthReport(
        id: 'RPT_TEST_999',
        animalId: 'A001',
        animalTag: 'MH-12-TEST-01',
        species: 'Cow',
        breed: 'Gir',
        symptoms: ['High fever', 'Excessive salivation', 'Blisters on tongue and hooves'],
        duration: '2 days',
        affectedCount: '3',
        riskLevel: RiskLevel.critical,
        description: 'Animal cannot walk or eat properly',
        title: 'Suspected Foot and Mouth Disease',
        advice: 'Isolate animal immediately and restrict livestock movement.',
        recommendedAction: 'Veterinary visit requested',
        createdAt: DateTime.now(),
      );

      await service.addHealthReport(report);

      // Verify case was created
      final allCases = service.getAllCases();
      expect(allCases.length, initialCaseCount + 1);

      final createdCase = allCases.firstWhere((c) => c.animalTag == 'MH-12-TEST-01');
      expect(createdCase.riskLevel, 'CRITICAL');
      expect(createdCase.status, FullCaseStatus.submitted);
      expect(createdCase.symptoms, contains('High fever'));

      // Verify Vet received high-risk alert
      final alerts = service.getAlerts();
      final vetAlert = alerts.firstWhere(
        (a) => a.targetRole == 'VETERINARIAN' && a.relatedId == createdCase.caseId,
      );
      expect(vetAlert, isNotNull);
      expect(vetAlert.title, contains('MH-12-TEST-01'));
    });

    test('2. Field Veterinarian claims case, schedules visit, and collects lab sample', () async {
      final report = HealthReport(
        id: 'RPT_TEST_998',
        animalId: 'A002',
        animalTag: 'MH-12-TEST-02',
        species: 'Cow',
        breed: 'Holstein',
        symptoms: ['Nodular skin eruptions', 'High fever'],
        duration: '3 days',
        affectedCount: '2',
        riskLevel: RiskLevel.high,
        description: 'Lumpy skin disease symptoms',
        title: 'Suspected Lumpy Skin Disease',
        advice: 'Quarantine animal from biting insects.',
        recommendedAction: 'Clinical examination and ring vaccination',
        createdAt: DateTime.now(),
      );
      await service.addHealthReport(report);

      final testCase = service.getAllCases().firstWhere((c) => c.animalTag == 'MH-12-TEST-02');

      // Vet assigns themselves
      await service.assignVetToCase(testCase.caseId, 'VET_007', 'Dr. Ananya Patil');
      expect(testCase.assignedVetId, 'VET_007');
      expect(testCase.assignedVetName, 'Dr. Ananya Patil');
      expect(testCase.status, FullCaseStatus.vetAssigned);

      // Vet schedules farm visit -> farmer alerted
      final visitDate = DateTime.now().add(const Duration(days: 1));
      service.addVetVisit(VetVisit(
        visitId: 'VIS_TEST_01',
        caseId: testCase.caseId,
        farmerId: testCase.farmerId,
        farmerName: testCase.farmerName,
        farmLocation: '${testCase.village}, ${testCase.block}',
        vetId: 'VET_007',
        vetName: 'Dr. Ananya Patil',
        scheduledDate: visitDate,
        observations: 'Confirmed nodular lesions on neck and trunk.',
      ));

      expect(testCase.status, FullCaseStatus.visitScheduled);

      // Verify farmer receives notification of scheduled visit
      final farmerAlerts = service.getAlerts().where((a) => a.targetRole == 'FARMER').toList();
      expect(farmerAlerts.any((a) => a.title.contains('Visit Scheduled')), isTrue);

      // Vet collects biological sample
      final sample = Sample(
        sampleId: 'SMP_TEST_01',
        caseId: testCase.caseId,
        animalId: testCase.animalId,
        animalTag: testCase.animalTag,
        sampleType: 'Skin Scrape & Blood',
        collectionDate: '2026-09-10',
        collectionLocation: 'Uruli Kanchan Farm',
        reason: 'PCR confirmation for Capripoxvirus',
        laboratory: 'State Animal Disease Diagnostic Laboratory, Pune',
        status: SampleStatus.collected,
        collectedBy: 'Dr. Ananya Patil',
      );
      service.addSample(sample);
      expect(testCase.status, FullCaseStatus.sampleCollected);

      // Sample dispatched to diagnostic lab
      service.updateSampleStatus('SMP_TEST_01', SampleStatus.sentToLab);
      expect(testCase.status, FullCaseStatus.labReferred);
    });

    test('3. Regional Outbreak escalated to Government -> Alert triggered', () async {
      final cluster = OutbreakCluster(
        clusterId: 'CLS_TEST_01',
        name: 'Uruli Kanchan Bovine Outbreak',
        location: 'Uruli Kanchan, Haveli',
        village: 'Uruli Kanchan',
        block: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        riskLevel: ClusterRisk.high,
        species: 'Cow',
        reportCount: 6,
        animalCount: 18,
        mortality: 2,
        symptoms: ['High fever', 'Salivation', 'Skin nodules'],
        suspectedDisease: 'Lumpy Skin Disease',
        status: ClusterStatus.investigation,
        latitude: 18.4900,
        longitude: 74.1300,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      service.addCluster(cluster);

      // Verify government receives High-Risk Alert
      final govtAlerts = service.getGovernmentAlerts();
      expect(govtAlerts.any((a) => a.clusterId == 'CLS_TEST_01'), isTrue);

      // Government Officer acknowledges alert
      final alert = service.getGovernmentAlertByClusterId('CLS_TEST_01');
      expect(alert, isNotNull);
      service.acknowledgeGovernmentAlert(alert!.id, user: 'Dr. D. K. Sharma (District Officer)');
      expect(alert.status, GovernmentAlertStatus.acknowledged);
      expect(alert.acknowledgedBy, 'Dr. D. K. Sharma (District Officer)');
    });

    test('4. Government publishes advisory -> broadcasted back to Farmer and Vet feeds', () async {
      final advisory = Advisory(
        advisoryId: 'ADV_TEST_01',
        title: 'Emergency Livestock Quarantine & Ring Vaccination Notice',
        message: 'Ring vaccination campaign initiated within 10km radius of Haveli block. Isolate sick animals.',
        target: AdvisoryTarget.district,
        targetLocation: 'Pune',
        createdBy: 'Department of Animal Husbandry, Govt of Maharashtra',
        status: AdvisoryStatus.draft,
        createdAt: DateTime.now(),
      );

      service.addAdvisory(advisory);
      expect(service.getPublishedAdvisories().any((a) => a.advisoryId == 'ADV_TEST_01'), isFalse);

      // Government publishes advisory
      await service.publishAdvisory('ADV_TEST_01');

      // Now available in published advisories list
      final published = service.getPublishedAdvisories();
      expect(published.any((a) => a.advisoryId == 'ADV_TEST_01'), isTrue);
      final publishedItem = published.firstWhere((a) => a.advisoryId == 'ADV_TEST_01');
      expect(publishedItem.status, AdvisoryStatus.published);
    });

    test('5. Government surveillance metrics dynamically aggregate Farmer case reports', () async {
      final casesByDistrict = service.getCasesByDistrict();
      expect(casesByDistrict.containsKey('Pune'), isTrue);

      final initialActive = service.activeCaseCount;
      expect(initialActive, greaterThan(0));

      final casesByVillage = service.getCasesByVillage();
      expect(casesByVillage.isNotEmpty, isTrue);
    });

    test('6. Vet updates case status and clinical findings -> updates Farmer report in real-time', () async {
      final report = HealthReport(
        id: 'RPT_TEST_SYNC_01',
        animalId: 'A009',
        animalTag: 'MH-14-SYNC-01',
        species: 'Buffalo',
        breed: 'Murrah',
        symptoms: ['High fever', 'Swollen lymph nodes'],
        duration: '1 day',
        affectedCount: '1',
        riskLevel: RiskLevel.high,
        title: 'Suspected Theileriosis',
        advice: 'Keep isolated from ticks',
        recommendedAction: 'Vet visit required',
        createdAt: DateTime.now(),
      );

      await service.addHealthReport(report);

      final createdCase = service.getAllCases().firstWhere((c) => c.animalTag == 'MH-14-SYNC-01');
      expect(createdCase.status, FullCaseStatus.submitted);

      // Verify farmer report initial status is open
      final farmerReport = service.getHealthReports().firstWhere((r) => r.id == report.id);
      expect(farmerReport.caseStatus, CaseStatus.open);

      // Vet assigns herself and schedules visit
      await service.assignVetToCase(createdCase.caseId, 'VET_009', 'Dr. Rajesh Sharma');
      expect(farmerReport.caseStatus, CaseStatus.vetAssigned);

      await service.updateCaseStatus(
        createdCase.caseId,
        FullCaseStatus.visitScheduled,
        actor: 'Veterinarian',
        description: 'Visit confirmed for tomorrow morning.',
      );
      expect(farmerReport.caseStatus, CaseStatus.visitScheduled);

      // Vet adds clinical observation and starts treatment
      createdCase.clinicalObservation = 'Submandibular lymph node severely enlarged; blood smear collected.';
      await service.updateCaseStatus(
        createdCase.caseId,
        FullCaseStatus.treatmentStarted,
        actor: 'Veterinarian',
        description: 'Buparvaquone administered intramuscularly.',
      );
      expect(farmerReport.caseStatus, CaseStatus.treatmentStarted);
      expect(createdCase.clinicalObservation, contains('Submandibular lymph node'));

      // Vet closes the case after recovery
      await service.updateCaseStatus(
        createdCase.caseId,
        FullCaseStatus.caseClosed,
        actor: 'Veterinarian',
        description: 'Animal fully recovered and back to normal feed intake.',
      );
      expect(farmerReport.caseStatus, CaseStatus.closed);
    });

    test('7. Vet escalates case -> instant Farmer urgent alert & Government Surveillance alert triggered', () async {
      final report = HealthReport(
        id: 'RPT_TEST_ESCALATE_01',
        animalId: 'A010',
        animalTag: 'MH-14-ESC-99',
        species: 'Cow',
        breed: 'Jersey Cross',
        symptoms: ['Neurological tremor', 'Sudden collapse', 'Bloody nasal discharge'],
        duration: 'Hours',
        affectedCount: '4',
        riskLevel: RiskLevel.critical,
        title: 'Unknown Acute Hemorrhagic Syndrome',
        advice: 'Total quarantine, do not touch carcass without PPE',
        recommendedAction: 'Emergency containment',
        createdAt: DateTime.now(),
      );

      await service.addHealthReport(report);
      final createdCase = service.getAllCases().firstWhere((c) => c.animalTag == 'MH-14-ESC-99');

      // Vet reviews and escalates the case to government
      await service.escalateCase(
        createdCase.caseId,
        reason: 'Suspected Anthrax or exotic viral hemorrhagic outbreak requiring rapid state response.',
      );

      // 1. Case flags updated
      expect(createdCase.status, FullCaseStatus.escalated);
      expect(createdCase.isEscalatedToGovt, isTrue);

      // 2. Farmer report status updated to escalated
      final farmerReport = service.getHealthReports().firstWhere((r) => r.id == report.id);
      expect(farmerReport.caseStatus, CaseStatus.escalated);

      // 3. Farmer received urgent notification alert
      final farmerAlerts = service.getAlerts().where((a) => a.targetRole == 'FARMER' && a.relatedId == createdCase.caseId).toList();
      expect(farmerAlerts.isNotEmpty, isTrue);
      expect(farmerAlerts.first.title, contains('Escalated to Government'));

      // 4. Government surveillance alert generated
      final govtAlerts = service.getGovernmentAlerts();
      final escAlert = govtAlerts.firstWhere((a) => a.clusterId == createdCase.caseId);
      expect(escAlert, isNotNull);
      expect(escAlert.type, 'ESCALATED_CASE');
      expect(escAlert.riskLevel, ClusterRisk.high);
      expect(escAlert.title, contains('ESCALATED CASE'));
      expect(escAlert.title, contains('MH-14-ESC-99'));
    });
  });
}
