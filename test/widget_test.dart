import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames/app.dart';

void main() {
  testWidgets('App opens on the home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MiniGamesApp());
    await tester.pumpAndSettle();

    expect(find.text('Mini Games'), findsOneWidget);
    expect(find.text('Schulte Grid'), findsOneWidget);
  });

  testWidgets('Tapping the card opens the start screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MiniGamesApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Schulte Grid'));
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsNWidgets(3));
  });
}
