import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/farmer_data_service.dart';
import 'package:flutter_app/screens/govt/govt_shell.dart';
import 'package:flutter_app/screens/govt/govt_dashboard_screen.dart';
import 'package:flutter_app/screens/govt/govt_live_map_screen.dart';
import 'package:flutter_app/screens/govt/govt_cluster_screen.dart';
import 'package:flutter_app/screens/govt/govt_surveillance_screen.dart';
import 'package:flutter_app/screens/govt/govt_vaccination_screen.dart';
import 'package:flutter_app/screens/govt/govt_lab_screen.dart';
import 'package:flutter_app/screens/govt/govt_field_ops_screen.dart';
import 'package:flutter_app/screens/govt/govt_analytics_screen.dart';
import 'package:flutter_app/screens/govt/govt_reports_screen.dart';
import 'package:flutter_app/screens/govt/govt_settings_screen.dart';
import 'package:flutter_app/screens/govt/govt_resources_screen.dart';

void main() {
  testWidgets('Govt module builds and all tabs render without errors on desktop and mobile', (WidgetTester tester) async {
    final dataService = FarmerDataService();

    // Desktop
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: GovtShell(dataService: dataService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('ANIMAL HEALTH'), findsWidgets);

    // Mobile
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpWidget(
      MaterialApp(
        home: GovtShell(dataService: dataService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Animal Health Intelligence'), findsWidgets);

    // Verify individual screens render on mobile
    final screens = [
      GovtDashboardScreen(dataService: dataService),
      GovtLiveMapScreen(dataService: dataService),
      GovtClusterScreen(dataService: dataService),
      GovtSurveillanceScreen(dataService: dataService),
      GovtVaccinationScreen(dataService: dataService),
      GovtLabScreen(dataService: dataService),
      GovtFieldOpsScreen(dataService: dataService),
      GovtAnalyticsScreen(dataService: dataService),
      GovtReportsScreen(dataService: dataService),
      GovtSettingsScreen(dataService: dataService),
      GovtResourcesScreen(dataService: dataService),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: screen),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  });
}
