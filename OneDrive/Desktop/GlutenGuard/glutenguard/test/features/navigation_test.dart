import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:glutenguard/app.dart';
import 'package:glutenguard/data/database/app_database.dart';
import 'package:glutenguard/data/database/database_provider.dart';
import 'package:glutenguard/features/safe_list/safe_list_provider.dart';
import 'package:glutenguard/features/history/scan_history_page.dart';

ProviderScope _app() => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
        safeListStreamProvider.overrideWith((_) => Stream.value([])),
        flaggedProductNamesProvider.overrideWith((_) async => {}),
        scanHistoryStreamProvider.overrideWith((_) => Stream.value([])),
        isProProvider.overrideWithValue(false),
      ],
      child: const GlutenGuardApp(),
    );

void main() {
  group('Navigation', () {
    testWidgets('app starts on Scan tab', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();
      expect(find.text('Scan'), findsOneWidget);
    });

    testWidgets('tapping Safe list navigates to Safe List page', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Safe list'));
      await tester.pumpAndSettle();
      expect(find.text('Safe List'), findsOneWidget);
    });

    testWidgets('tapping Recipes navigates correctly', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();
      expect(find.text('Recipes tab'), findsOneWidget);
    });

    testWidgets('tapping History navigates to Scan History page', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Scan History'), findsOneWidget);
    });

    testWidgets('bottom nav shows all 5 tabs', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Safe list'), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
