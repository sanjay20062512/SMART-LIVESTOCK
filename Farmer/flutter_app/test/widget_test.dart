// Basic smoke test for Smart Livestock Farmer app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(FarmerApp());
    // The login screen should be visible.
    expect(find.text('Smart Livestock'), findsWidgets);
  });
}
