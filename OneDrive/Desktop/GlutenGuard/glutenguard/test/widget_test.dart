import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glutenguard/app.dart';

void main() {
  testWidgets('app smoke test — renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GlutenGuardApp()));
    await tester.pumpAndSettle();
    expect(find.text('Scan'), findsOneWidget);
  });
}
