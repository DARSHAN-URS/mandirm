import 'package:flutter_test/flutter_test.dart';
import 'package:astrologer_app/main.dart';

void main() {
  testWidgets('AstrologerApp initializes properly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AstrologerApp());
    expect(find.text('Mandiram Astrologer Portal'), findsOneWidget);
  });
}
