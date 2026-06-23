
import 'package:flutter_test/flutter_test.dart';
import 'package:hikkasurf/main.dart';

void main() {
  testWidgets('Smoke test for HikkaSurf App', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HikkaSurfApp());

    // Verify that our app loads by looking for the Home tab.
    expect(find.text('Catch your next wave'), findsOneWidget);
  });
}
