import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/farmer_data_service.dart';
import 'package:flutter_app/screens/symptom_report_screen.dart';

void main() {
  testWidgets('Symptom report submission displays Assessment Result properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dataService = FarmerDataService();
    dataService.seedDemoData();

    await tester.pumpWidget(MaterialApp(
      home: SymptomReportScreen(dataService: dataService),
    ));
    await tester.pumpAndSettle();

    Future<void> tapNext() async {
      final finder = find.text('Next');
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    // Step 0: Select Cow and tap Next
    expect(find.text('What animal has a problem?'), findsWidgets);
    await tapNext();

    // Step 1: Details -> tap Next
    await tapNext();

    // Step 2: Symptoms -> select Fever and tap Next
    final feverFinder = find.text('Fever');
    await tester.ensureVisible(feverFinder);
    await tester.pumpAndSettle();
    await tester.tap(feverFinder);
    await tester.pumpAndSettle();
    await tapNext();

    // Step 3: Duration -> tap Next
    await tapNext();

    // Step 4: Eating & Drinking -> tap Next
    await tapNext();

    // Step 5: Affected Count -> tap Next
    await tapNext();

    // Step 6: Pregnancy -> tap Next
    await tapNext();

    // Step 7: Evidence -> tap Next
    await tapNext();

    // Step 8: Location -> tap Next
    await tapNext();

    // Step 9: Summary -> tap SUBMIT REPORT
    final submitFinder = find.text('SUBMIT REPORT');
    expect(submitFinder, findsWidgets);
    await tester.ensureVisible(submitFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    // Verify AppBar shows Assessment Result
    expect(find.text('Assessment Result'), findsOneWidget);

    // Verify that the body is NOT empty!
    expect(find.text('Recommended Action'), findsOneWidget);
    expect(find.textContaining('Case ID: #'), findsOneWidget);
    expect(find.text('BACK TO HOME'), findsOneWidget);
  });
}
