import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/farmer_data_service.dart';
import 'package:flutter_app/screens/govt/govt_shell.dart';
import 'package:flutter_app/screens/govt/govt_dashboard_screen.dart';
import 'package:flutter_app/screens/govt/govt_disease_map_screen.dart';
import 'package:flutter_app/screens/govt/govt_alerts_screen.dart';
import 'package:flutter_app/screens/govt/govt_reports_screen.dart';
import 'package:flutter_app/screens/govt/govt_area_detail_screen.dart';
import 'package:flutter_app/screens/govt/govt_mock_data.dart';

void main() {
  final dataService = FarmerDataService();

  testWidgets('Govt module builds cleanly on desktop', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: GovtShell(dataService: dataService)));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Government Animal Health'), findsWidgets);
    expect(find.text('Maharashtra Surveillance'), findsWidgets);
    expect(find.text('ACTIVE CASES'), findsWidgets);
    expect(find.text('HIGH-RISK AREAS'), findsWidgets);
    expect(find.text('WHY IS RISK INCREASING?'), findsWidgets);
    expect(find.text('PRIORITY ACTIONS'), findsWidgets);
  });

  void setMobileView(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844); // Standard mobile phone dimensions
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('GovtShell builds on mobile', (WidgetTester tester) async {
    setMobileView(tester);
    await tester.pumpWidget(MaterialApp(home: GovtShell(dataService: dataService)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Maharashtra Surveillance'), findsWidgets);
  });

  testWidgets('GovtDashboardScreen builds on mobile', (WidgetTester tester) async {
    setMobileView(tester);
    await tester.pumpWidget(MaterialApp(home: GovtDashboardScreen(dataService: dataService)));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('GovtDiseaseMapScreen builds on mobile', (WidgetTester tester) async {
    setMobileView(tester);
    await tester.pumpWidget(MaterialApp(home: GovtDiseaseMapScreen(dataService: dataService)));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('GovtAlertsScreen builds on mobile', (WidgetTester tester) async {
    setMobileView(tester);
    await tester.pumpWidget(MaterialApp(home: GovtAlertsScreen(dataService: dataService)));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('GovtReportsScreen builds on mobile', (WidgetTester tester) async {
    setMobileView(tester);
    await tester.pumpWidget(MaterialApp(home: GovtReportsScreen(dataService: dataService)));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('GovtAreaDetailScreen builds on mobile', (WidgetTester tester) async {
    setMobileView(tester);
    await tester.pumpWidget(MaterialApp(
      home: GovtAreaDetailScreen(
        district: GovtMockData.getMaharashtraDistricts().first,
        dataService: dataService,
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
  });
}
