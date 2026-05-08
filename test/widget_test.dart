// Basic smoke test for PlayON app.

import 'package:flutter_test/flutter_test.dart';
import 'package:playon/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlayOnApp());
    // Login page should appear with the Sign In button
    expect(find.text('Sign In'), findsOneWidget);
  });
}
