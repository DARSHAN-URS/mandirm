import 'package:flutter_test/flutter_test.dart';
import 'package:consumer_app/main.dart';

void main() {
  testWidgets('ConsumerApp initializes properly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ConsumerApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that the ConsumerApp widget mounts
    expect(find.byType(ConsumerApp), findsOneWidget);

    // Fast-forward past splash timer to allow all timers to complete
    await tester.pumpAndSettle(const Duration(milliseconds: 2500));
  });
}
