import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glutenguard/app.dart';

void main() {
  group('Navigation', () {
    testWidgets('app starts on Scan tab', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: GlutenGuardApp()));
      await tester.pumpAndSettle();
      expect(find.text('Scan tab — coming in Session 3'), findsOneWidget);
    });

    testWidgets('tapping Safe list navigates correctly', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: GlutenGuardApp()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Safe list'));
      await tester.pumpAndSettle();
      expect(find.text('Safe list tab'), findsOneWidget);
    });

    testWidgets('tapping Recipes navigates correctly', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: GlutenGuardApp()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();
      expect(find.text('Recipes tab'), findsOneWidget);
    });

    testWidgets('bottom nav shows all 5 tabs', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: GlutenGuardApp()));
      await tester.pumpAndSettle();
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Safe list'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
