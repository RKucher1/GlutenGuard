import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/data/database/app_database.dart';
import 'package:glutenguard/data/database/database_provider.dart';
import 'package:glutenguard/features/history/scan_history_page.dart';
import 'package:glutenguard/features/history/reaction_logger_page.dart';

AppDatabase _makeTestDb() => AppDatabase(NativeDatabase.memory());

// Widget test helper — overrides stream to avoid drift timer teardown issues.
ProviderScope _buildHistory({
  List<ScanHistoryItem> items = const [],
  bool isPro = false,
  AppDatabase? db,
}) {
  final testDb = db ?? _makeTestDb();
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(testDb),
      scanHistoryStreamProvider.overrideWith((_) => Stream.value(items)),
      isProProvider.overrideWithValue(isPro),
    ],
    child: const MaterialApp(home: ScanHistoryPage()),
  );
}

ScanHistoryItem _scan({
  int id = 1,
  String name = 'Test Product',
  String tier = 'GREEN',
  DateTime? scannedAt,
}) =>
    ScanHistoryItem(
      id: id,
      barcode: id.toString(),
      productName: name,
      resultTier: tier,
      flaggedIngredients: '[]',
      scannedAt: scannedAt ?? DateTime.now(),
    );

void main() {
  // ── ScanHistoryPage widget tests ───────────────────────────────────────────

  group('ScanHistoryPage', () {
    testWidgets('shows empty state when no scans', (t) async {
      await t.pumpWidget(_buildHistory());
      await t.pumpAndSettle();
      expect(find.text('No scans yet'), findsOneWidget);
    });

    testWidgets('shows "Scan History" appbar title', (t) async {
      await t.pumpWidget(_buildHistory());
      await t.pumpAndSettle();
      expect(find.text('Scan History'), findsOneWidget);
    });

    testWidgets('shows scan product name', (t) async {
      await t.pumpWidget(_buildHistory(
          items: [_scan(name: 'Test Bread', tier: 'RED')]));
      await t.pumpAndSettle();
      expect(find.text('Test Bread'), findsOneWidget);
    });

    testWidgets('shows Today date separator for recent scan', (t) async {
      await t.pumpWidget(_buildHistory(items: [_scan()]));
      await t.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('RED scan shows red tier dot via Semantics', (t) async {
      await t.pumpWidget(
          _buildHistory(items: [_scan(name: 'Wheat Bread', tier: 'RED')]));
      await t.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'RED result',
        ),
        findsOneWidget,
      );
    });

    testWidgets('GREEN scan shows green tier dot via Semantics', (t) async {
      await t.pumpWidget(
          _buildHistory(items: [_scan(name: 'Rice Crackers', tier: 'GREEN')]));
      await t.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'GREEN result',
        ),
        findsOneWidget,
      );
    });

    testWidgets('AMBER scan shows amber tier dot via Semantics', (t) async {
      await t.pumpWidget(
          _buildHistory(items: [_scan(name: 'Oat Crackers', tier: 'AMBER')]));
      await t.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'AMBER result',
        ),
        findsOneWidget,
      );
    });

    testWidgets('free user sees pro gate card for old scans', (t) async {
      final old = DateTime.now().subtract(const Duration(days: 10));
      await t.pumpWidget(_buildHistory(items: [
        _scan(name: 'Old Product', scannedAt: old),
      ]));
      await t.pumpAndSettle();
      expect(find.textContaining('older'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsOneWidget);
    });

    testWidgets('free user hides scans older than 7 days', (t) async {
      final old = DateTime.now().subtract(const Duration(days: 10));
      await t.pumpWidget(_buildHistory(items: [
        _scan(name: 'Old Product', scannedAt: old),
      ]));
      await t.pumpAndSettle();
      expect(find.text('Old Product'), findsNothing);
    });

    testWidgets('pro user sees scans older than 7 days', (t) async {
      final old = DateTime.now().subtract(const Duration(days: 10));
      await t.pumpWidget(_buildHistory(
        items: [_scan(name: 'Old Product', scannedAt: old)],
        isPro: true,
      ));
      await t.pumpAndSettle();
      expect(find.text('Old Product'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsNothing);
    });

    testWidgets('pro user sees no pro gate card', (t) async {
      await t.pumpWidget(_buildHistory(isPro: true));
      await t.pumpAndSettle();
      expect(find.text('Upgrade to Pro'), findsNothing);
    });

    testWidgets('shows Log reaction FAB', (t) async {
      await t.pumpWidget(_buildHistory());
      await t.pumpAndSettle();
      expect(find.text('Log reaction'), findsOneWidget);
    });

    testWidgets('clear icon visible when history non-empty', (t) async {
      await t.pumpWidget(_buildHistory(items: [_scan()]));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('clear icon absent when history empty', (t) async {
      await t.pumpWidget(_buildHistory());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('shows multiple scans', (t) async {
      await t.pumpWidget(_buildHistory(items: [
        _scan(id: 1, name: 'Bread', tier: 'RED'),
        _scan(id: 2, name: 'Crackers', tier: 'GREEN'),
      ]));
      await t.pumpAndSettle();
      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('Crackers'), findsOneWidget);
    });

    testWidgets('pro gate shows correct hidden count', (t) async {
      final old = DateTime.now().subtract(const Duration(days: 10));
      await t.pumpWidget(_buildHistory(items: [
        _scan(id: 1, name: 'Old1', scannedAt: old),
        _scan(id: 2, name: 'Old2', scannedAt: old),
      ]));
      await t.pumpAndSettle();
      expect(find.textContaining('2 older'), findsOneWidget);
    });
  });

  // ── ReactionLoggerPage widget tests ───────────────────────────────────────

  group('ReactionLoggerPage', () {
    late AppDatabase db;
    setUp(() => db = _makeTestDb());
    tearDown(() => db.close());

    ProviderScope buildReactionPage() => ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            suspiciousProductProvider.overrideWith((_) async => null),
          ],
          child: const MaterialApp(home: ReactionLoggerPage()),
        );

    testWidgets('shows "Log a Reaction" title', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      expect(find.text('Log a Reaction'), findsOneWidget);
    });

    testWidgets('shows privacy notice below save button', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      expect(find.textContaining('will never be shared', skipOffstage: false),
          findsOneWidget);
    });

    testWidgets('shows symptom chips', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      expect(find.text('Bloating'), findsOneWidget);
      expect(find.text('Abdominal pain'), findsOneWidget);
      expect(find.text('Diarrhea'), findsOneWidget);
    });

    testWidgets('shows severity slider', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('shows suspected product label', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      expect(find.text('Suspected product'), findsOneWidget);
    });

    testWidgets('shows save button', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView), const Offset(0, -600));
      await t.pumpAndSettle();
      expect(find.text('Save reaction log'), findsOneWidget);
    });

    testWidgets('save without product name shows validation error', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView), const Offset(0, -600));
      await t.pumpAndSettle();
      await t.tap(find.text('Save reaction log'));
      await t.pump();
      expect(find.text('Required', skipOffstage: false), findsOneWidget);
    });

    testWidgets('close button present in app bar', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('date picker field present', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });

    testWidgets('shows severity label', (t) async {
      await t.pumpWidget(buildReactionPage());
      await t.pumpAndSettle();
      // Default severity = 2 → Moderate
      expect(find.text('Moderate'), findsWidgets);
    });
  });

  // ── scanHistoryStreamProvider ──────────────────────────────────────────────

  group('scanHistoryStreamProvider', () {
    late AppDatabase db;
    setUp(() => db = _makeTestDb());
    tearDown(() => db.close());

    test('emits empty list initially', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final result = await container.read(scanHistoryStreamProvider.future);
      expect(result, isEmpty);
    });

    test('emits scan after insertion', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await db.scanHistoryDao.insertScan(ScanHistoryItemsCompanion.insert(
        barcode: '123',
        productName: 'Test Bread',
        resultTier: 'RED',
        flaggedIngredients: '["wheat"]',
        scannedAt: DateTime.now(),
      ));

      final result = await container.read(scanHistoryStreamProvider.future);
      expect(result.length, 1);
      expect(result.first.productName, 'Test Bread');
    });
  });
}
