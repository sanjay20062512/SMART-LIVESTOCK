import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/farmer_data_service.dart';
import 'package:flutter_app/services/triage_service.dart';
import 'package:flutter_app/models/health_report.dart';
import 'package:flutter_app/screens/assessment_result_screen.dart';

void main() {
  testWidgets('AssessmentResultScreen renders all content properly', (WidgetTester tester) async {
    final dataService = FarmerDataService();
    dataService.seedDemoData();

    const triageResult = TriageResult(
      riskLevel: RiskLevel.critical,
      title: 'CRITICAL HEALTH RISK',
      advice: 'Immediate veterinary attention is required. Isolate the animal now.',
      recommendedAction: 'Please keep the affected animal separate from the herd and contact a veterinarian urgently.',
    );

    await tester.pumpWidget(MaterialApp(
      home: AssessmentResultScreen(
        dataService: dataService,
        reportId: 'RPT_TEST_123',
        triageResult: triageResult,
        animalTag: 'MH-12-TEST',
      ),
    ));
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Assessment Result'), findsOneWidget);

    // Verify Content
    expect(find.text('Report Submitted & Logged to Network'), findsOneWidget);
    expect(find.text('CRITICAL HEALTH RISK'), findsWidgets);
    expect(find.text('Recommended Action'), findsOneWidget);
    expect(find.text('Immediate veterinary attention is required. Isolate the animal now.'), findsOneWidget);
    expect(find.text('Request Veterinarian'), findsOneWidget);
    expect(find.text('BACK TO HOME'), findsOneWidget);
  });
}
