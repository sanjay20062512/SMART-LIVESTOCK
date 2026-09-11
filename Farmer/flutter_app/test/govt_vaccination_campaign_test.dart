import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/farmer_data_service.dart';
import 'package:flutter_app/screens/govt/govt_models.dart';
import 'package:flutter_app/screens/govt/govt_mock_data.dart';
import 'package:flutter_app/screens/govt/govt_campaign_engine.dart';
import 'package:flutter_app/screens/govt/govt_vaccination_screen.dart';
import 'package:flutter_app/screens/govt/govt_campaign_detail_screen.dart';
import 'package:flutter_app/screens/govt/govt_disease_map_screen.dart';
import 'package:flutter_app/screens/govt/widgets/govt_create_campaign_dialog.dart';
import 'package:flutter_app/screens/govt/widgets/govt_maharashtra_map_widget.dart';

void main() {
  final dataService = FarmerDataService();

  group('GovtCampaignEngine Unit Tests', () {
    test('Evaluates priority and gaps accurately', () {
      // Pune critical gap: Risk 78%, Vaccination 61%
      final punePriority = GovtCampaignEngine.evaluatePriority(riskScore: 78, vaccinationCoverage: 61);
      expect(punePriority, CampaignPriority.critical);
      expect(GovtCampaignEngine.hasVaccinationGap(riskScore: 78, vaccinationCoverage: 61), isTrue);

      // Nashik high gap: Risk 68%, Vaccination 54%
      final nashikPriority = GovtCampaignEngine.evaluatePriority(riskScore: 68, vaccinationCoverage: 54);
      expect(nashikPriority, CampaignPriority.high);
      expect(GovtCampaignEngine.hasVaccinationGap(riskScore: 68, vaccinationCoverage: 54), isTrue);

      // Low risk / high coverage: Risk 42%, Vaccination 84%
      final safePriority = GovtCampaignEngine.evaluatePriority(riskScore: 42, vaccinationCoverage: 84);
      expect(safePriority, CampaignPriority.normal);
      expect(GovtCampaignEngine.hasVaccinationGap(riskScore: 42, vaccinationCoverage: 84), isFalse);

      // Coverage gap calculation against 85% target
      final gap = GovtCampaignEngine.calculateCoverageGap(61, target: 85);
      expect(gap, 24);

      // Operational recommendations
      expect(
        GovtCampaignEngine.getRecommendation(district: 'Pune', disease: 'FMD', riskScore: 78, vaccinationCoverage: 61),
        'Launch targeted FMD vaccination campaign.',
      );
      expect(
        GovtCampaignEngine.getRecommendation(district: 'Nashik', disease: 'Brucellosis', riskScore: 68, vaccinationCoverage: 54),
        'Increase vaccination coverage.',
      );
    });

    test('Simulates demo risk reduction correctly', () {
      final sim = GovtCampaignEngine.simulateRiskReduction(
        currentRisk: 78,
        currentCoverage: 61,
        targetCoverage: 82,
      );

      expect(sim.beforeRisk, 78);
      expect(sim.afterRisk, 64);
      expect(sim.beforeCoverage, 61);
      expect(sim.afterCoverage, 82);
      expect(sim.note, contains('DEMO / MOCK DATA'));
    });
  });

  group('GovtVaccinationScreen Widget Tests', () {
    testWidgets('Renders all required sections, metrics, intelligence, and map', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        home: GovtVaccinationScreen(dataService: dataService),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Top Overview
      expect(find.text('VACCINATION CAMPAIGNS'), findsWidgets);
      expect(find.text('06'), findsOneWidget); // Active Campaigns
      expect(find.text('24.9k'), findsOneWidget); // Animals Targeted
      expect(find.text('17.4k'), findsOneWidget); // Vaccinated
      expect(find.text('70.1%'), findsOneWidget); // Coverage

      // Risk-to-Campaign Intelligence
      expect(find.text('CAMPAIGN PRIORITY'), findsOneWidget);
      expect(find.text('PUNE'), findsWidgets);
      expect(find.text('78% CRITICAL'), findsOneWidget);
      expect(find.text('Launch targeted FMD vaccination campaign.'), findsOneWidget);
      expect(find.text('NASHIK'), findsWidgets);
      expect(find.text('68% HIGH'), findsOneWidget);
      expect(find.text('Increase vaccination coverage.'), findsOneWidget);

      // Reused Maharashtra Map in Vaccination Mode
      expect(find.text('CAMPAIGN COVERAGE MAP'), findsOneWidget);
      expect(find.byType(GovtMaharashtraMapWidget), findsOneWidget);
      expect(find.text('80–100% Good'), findsOneWidget);
      expect(find.text('50–79% Needs attention'), findsOneWidget);
      expect(find.text('0–49% Critical gap'), findsOneWidget);

      // Active Campaigns List
      expect(find.text('ACTIVE CAMPAIGNS'), findsOneWidget);
      expect(find.text('FMD PREVENTION DRIVE'), findsOneWidget);
      expect(find.text('BRUCELLOSIS CONTROL DRIVE'), findsOneWidget);

      // Campaign Alerts
      expect(find.text('CAMPAIGN ALERTS'), findsOneWidget);
      expect(find.text('LOW COVERAGE DETECTED'), findsOneWidget);
      expect(find.text('TARGET ACHIEVED'), findsOneWidget);

      // Campaign Performance Progress Timeline
      expect(find.text('CAMPAIGN PERFORMANCE'), findsOneWidget);
      expect(find.text('Vaccination Coverage — Campaign Progress'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
      expect(find.text('51%'), findsOneWidget);
      expect(find.text('63%'), findsOneWidget);
      expect(find.text('70%'), findsWidgets);
    });
  });

  group('Map to Campaign Connection Tests', () {
    testWidgets('Tapping high-risk district in Disease Map detects gap and offers pre-filled campaign launch', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        home: GovtDiseaseMapScreen(dataService: dataService),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Pune in district ranking list to select it
      final puneRanking = find.text('Pune');
      expect(puneRanking, findsWidgets);
      await tester.tap(puneRanking.first);
      await tester.pump(const Duration(milliseconds: 100));

      // Verify "Vaccination gap detected." alert is shown
      expect(find.text('Vaccination gap detected.'), findsOneWidget);
      final startBtn = find.text('START VACCINATION CAMPAIGN');
      expect(startBtn, findsOneWidget);

      // Scroll to button and tap START VACCINATION CAMPAIGN
      await tester.ensureVisible(startBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(startBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // Verify create campaign wizard opened with pre-filled values
      expect(find.text('CREATE VACCINATION CAMPAIGN'), findsOneWidget);
      expect(find.text('Pune'), findsWidgets);
      expect(find.text('Selected villages: 18'), findsOneWidget);
    });
  });

  group('Campaign Detail & Village-Level Interaction Tests', () {
    testWidgets('Campaign detail displays status, village list, village click modal, and team assignment', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final campaign = GovtMockData.getCampaigns().first; // Pune FMD Drive

      await tester.pumpWidget(MaterialApp(
        home: GovtCampaignDetailScreen(
          campaign: campaign,
          dataService: dataService,
        ),
      ));
      await tester.pumpAndSettle();

      // Verify header & progress
      expect(find.text('FMD PREVENTION DRIVE'), findsWidgets);
      expect(find.text('PUNE DISTRICT'), findsOneWidget);
      expect(find.text('CRITICAL PRIORITY'), findsOneWidget);
      expect(find.text('ACTIVE'), findsWidgets);

      // Targets & Status breakdown
      expect(find.text('TARGET'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);

      // Village breakdown list
      expect(find.text('Village A (Khadakwasla)'), findsOneWidget);
      expect(find.text('Village D (Manchar)'), findsOneWidget);
      expect(find.text('Village E (Jejuri)'), findsOneWidget);

      // Simulated risk reduction card
      expect(find.text('PROJECTED RISK IMPACT'), findsOneWidget);
      expect(find.text('DEMO / MOCK DATA'), findsOneWidget);
      expect(find.text('Risk = 78%'), findsOneWidget);
      expect(find.text('Risk = 64%'), findsOneWidget);

      // Tap Village D (51% coverage) to open village detail bottom sheet
      await tester.tap(find.text('Village D (Manchar)'));
      await tester.pumpAndSettle();

      // Verify Village interaction modal
      expect(find.text('VILLAGE D (MANCHAR)'), findsOneWidget);
      expect(find.text('Animals Targeted'), findsOneWidget);
      expect(find.text('420'), findsOneWidget);
      expect(find.text('214'), findsOneWidget);
      expect(find.text('206'), findsOneWidget);
      expect(find.text('Deploy additional vaccination team.'), findsOneWidget);

      // Tap ASSIGN TEAM in village modal (use .last because background screen also has an assign team button)
      final assignTeamBtn = find.widgetWithText(ElevatedButton, 'ASSIGN TEAM').last;
      expect(assignTeamBtn, findsOneWidget);
      await tester.tap(assignTeamBtn);
      await tester.pumpAndSettle();

      // Verify field team deployment dialog
      expect(find.text('ASSIGN FIELD VACCINATION TEAM'), findsOneWidget);
      final confirmDeployBtn = find.text('CONFIRM DEPLOYMENT');
      expect(confirmDeployBtn, findsOneWidget);
      await tester.tap(confirmDeployBtn);
      await tester.pumpAndSettle();

      // Verify assignment snackbar
      expect(find.textContaining('successfully assigned to Village D'), findsOneWidget);
    });
  });

  group('Create Campaign Wizard Tests', () {
    testWidgets('Completes 4 steps and launches campaign', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      VaccinationCampaign? created;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => GovtCreateCampaignDialog.show(
                ctx,
                initialDistrict: 'Pune',
                onCampaignCreated: (c) => created = c,
              ),
              child: const Text('OPEN'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // Step 1: Area
      expect(find.text('Step 01 of 04 — Select Target Area'), findsOneWidget);
      await tester.tap(find.text('CONTINUE →'));
      await tester.pumpAndSettle();

      // Step 2: Disease & Vaccine
      expect(find.text('Step 02 of 04 — Select Disease & Vaccine'), findsOneWidget);
      await tester.tap(find.text('CONTINUE →'));
      await tester.pumpAndSettle();

      // Step 3: Targets & Timeline
      expect(find.text('Step 03 of 04 — Campaign Targets & Timeline'), findsOneWidget);
      await tester.tap(find.text('CONTINUE →'));
      await tester.pumpAndSettle();

      // Step 4: Review
      expect(find.text('Step 04 of 04 — Review & Confirm Launch'), findsOneWidget);
      expect(find.text('LAUNCH CAMPAIGN'), findsOneWidget);

      await tester.tap(find.text('LAUNCH CAMPAIGN'));
      await tester.pumpAndSettle();

      expect(created, isNotNull);
      expect(created!.targetDistrict, 'Pune');
    });
  });
}
