import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/data/database/app_database.dart';
import 'package:glutenguard/data/database/database_provider.dart';
import 'package:glutenguard/features/safe_list/safe_list_page.dart';
import 'package:glutenguard/features/safe_list/safe_list_provider.dart';
import 'package:glutenguard/features/safe_list/safe_list_share_service.dart';

AppDatabase _makeTestDb() => AppDatabase(NativeDatabase.memory());

// Widget test helper — overrides stream with pre-seeded items to avoid drift
// timer teardown issues in the test framework.
ProviderScope _buildPage({
  List<SafeListItem> items = const [],
  Set<String> flaggedNames = const {},
  AppDatabase? db,
}) {
  final testDb = db ?? _makeTestDb();
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(testDb),
      safeListStreamProvider.overrideWith((_) => Stream.value(items)),
      flaggedProductNamesProvider.overrideWith((_) async => flaggedNames),
    ],
    child: const MaterialApp(home: SafeListPage()),
  );
}

SafeListItem _item(int id, String name) => SafeListItem(
      id: id,
      barcode: id.toString(),
      productName: name,
      addedAt: DateTime(2024, 3, id),
    );

void main() {
  // ── SafeListPage widget tests ──────────────────────────────────────────────

  group('SafeListPage', () {
    testWidgets('shows empty state when safe list is empty', (t) async {
      await t.pumpWidget(_buildPage());
      await t.pumpAndSettle();
      expect(find.text('Your safe list is empty'), findsOneWidget);
    });

    testWidgets('shows "Safe List" appbar title', (t) async {
      await t.pumpWidget(_buildPage());
      await t.pumpAndSettle();
      expect(find.text('Safe List'), findsOneWidget);
    });

    testWidgets('shows Start Scanning CTA on empty state', (t) async {
      await t.pumpWidget(_buildPage());
      await t.pumpAndSettle();
      expect(find.text('Start Scanning'), findsOneWidget);
    });

    testWidgets('shows product name in list', (t) async {
      await t.pumpWidget(_buildPage(items: [_item(1, 'GF Bread')]));
      await t.pumpAndSettle();
      expect(find.text('GF Bread'), findsOneWidget);
    });

    testWidgets('shows multiple products', (t) async {
      await t.pumpWidget(_buildPage(items: [
        _item(1, 'GF Bread'),
        _item(2, 'Rice Crackers'),
      ]));
      await t.pumpAndSettle();
      expect(find.text('GF Bread'), findsOneWidget);
      expect(find.text('Rice Crackers'), findsOneWidget);
    });

    testWidgets('share button absent on empty list', (t) async {
      await t.pumpWidget(_buildPage());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.share_outlined), findsNothing);
    });

    testWidgets('share button present when list has items', (t) async {
      await t.pumpWidget(_buildPage(items: [_item(1, 'GF Bread')]));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('amber alert banner shown for flagged product', (t) async {
      await t.pumpWidget(_buildPage(
        items: [_item(1, 'Gluten-Free Rolled Oats')],
        flaggedNames: {'gluten-free rolled oats'},
      ));
      await t.pumpAndSettle();
      expect(find.text('Flagged product alert'), findsOneWidget);
    });

    testWidgets('amber alert banner absent when no flagged products', (t) async {
      await t.pumpWidget(_buildPage(items: [_item(1, 'Rice Crackers')]));
      await t.pumpAndSettle();
      expect(find.text('Flagged product alert'), findsNothing);
    });

    testWidgets('remove button is present on item card', (t) async {
      await t.pumpWidget(_buildPage(items: [_item(1, 'GF Bread')]));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows saved date on item card', (t) async {
      await t.pumpWidget(_buildPage(items: [
        SafeListItem(
          id: 1,
          barcode: '111',
          productName: 'GF Bread',
          addedAt: DateTime(2024, 3, 15),
        ),
      ]));
      await t.pumpAndSettle();
      expect(find.textContaining('Mar 15, 2024'), findsOneWidget);
    });

    testWidgets('empty state hides share button', (t) async {
      await t.pumpWidget(_buildPage());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.share_outlined), findsNothing);
    });

    testWidgets('single flagged item shows warning icon on card', (t) async {
      await t.pumpWidget(_buildPage(
        items: [_item(1, 'Gluten-Free Rolled Oats')],
        flaggedNames: {'gluten-free rolled oats'},
      ));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('non-flagged item has no warning icon', (t) async {
      await t.pumpWidget(_buildPage(items: [_item(1, 'Safe Crackers')]));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });
  });

  // ── safeListStreamProvider ─────────────────────────────────────────────────

  group('safeListStreamProvider', () {
    late AppDatabase db;
    setUp(() => db = _makeTestDb());
    tearDown(() => db.close());

    test('emits empty list initially', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final result = await container.read(safeListStreamProvider.future);
      expect(result, isEmpty);
    });

    test('emits item after insertion', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await db.scanHistoryDao.addToSafeList(SafeListItemsCompanion.insert(
        barcode: '123',
        productName: 'Test Product',
        addedAt: DateTime(2024, 1, 1),
      ));

      final result = await container.read(safeListStreamProvider.future);
      expect(result.length, 1);
      expect(result.first.productName, 'Test Product');
    });

    test('remove item reflects in stream', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await db.scanHistoryDao.addToSafeList(SafeListItemsCompanion.insert(
        barcode: '123',
        productName: 'Test Product',
        addedAt: DateTime(2024, 1, 1),
      ));
      await db.scanHistoryDao.removeFromSafeList('123');

      final result = await container.read(safeListStreamProvider.future);
      expect(result, isEmpty);
    });
  });

  // ── SafeListShareService ───────────────────────────────────────────────────

  group('SafeListShareService', () {
    test('share does nothing when list is empty', () async {
      await SafeListShareService.share([]);
    });
  });
}
