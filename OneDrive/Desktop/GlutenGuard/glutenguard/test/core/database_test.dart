import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:glutenguard/data/database/app_database.dart';

AppDatabase _makeTestDb() =>
    AppDatabase(NativeDatabase.memory());

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() => db = _makeTestDb());
    tearDown(() => db.close());

    // 1. insert a scan and retrieve it
    test('insert and retrieve scan history', () async {
      await db.scanHistoryDao.insertScan(ScanHistoryItemsCompanion.insert(
        barcode: '1234567890',
        productName: 'Test Bread',
        resultTier: 'RED',
        flaggedIngredients: '["wheat flour"]',
        scannedAt: DateTime(2024, 1, 15),
      ));

      final scans = await db.scanHistoryDao.allScans();
      expect(scans.length, 1);
      expect(scans.first.barcode, '1234567890');
      expect(scans.first.resultTier, 'RED');
    });

    // 2. empty history returns empty list
    test('empty scan history returns empty list', () async {
      final scans = await db.scanHistoryDao.allScans();
      expect(scans, isEmpty);
    });

    // 3. add item to safe list and read it back
    test('add and retrieve safe list item', () async {
      await db.scanHistoryDao.addToSafeList(SafeListItemsCompanion.insert(
        barcode: '9876543210',
        productName: 'GF Crackers',
        addedAt: DateTime(2024, 1, 15),
      ));

      final items = await db.scanHistoryDao.allSafeItems();
      expect(items.length, 1);
      expect(items.first.productName, 'GF Crackers');

      final safe = await db.scanHistoryDao.isSafe('9876543210');
      expect(safe, isTrue);
    });

    // 4. cache a product and retrieve it; null for uncached barcode
    test('cache product and return null for uncached barcode', () async {
      await db.productCacheDao.upsertCache(ProductCacheItemsCompanion.insert(
        barcode: '5555555555',
        jsonPayload: '{"name":"Gluten Free Pasta"}',
        cachedAt: DateTime.now(),
      ));

      final cached = await db.productCacheDao.getCached('5555555555');
      expect(cached, isNotNull);
      expect(cached!.barcode, '5555555555');

      final missing = await db.productCacheDao.getCached('0000000000');
      expect(missing, isNull);
    });

    // 5. add pantry item and retrieve it
    test('add and retrieve pantry item', () async {
      await db.productCacheDao.upsertPantryItem(PantryItemsCompanion.insert(
        ingredientId: 'p001',
        name: 'Chicken Breast',
        isInPantry: const Value(true),
        updatedAt: DateTime.now(),
      ));

      final items = await db.productCacheDao.allPantryItems();
      expect(items.length, 1);
      expect(items.first.ingredientId, 'p001');
      expect(items.first.isInPantry, isTrue);
    });

    // 6. insert reaction log and retrieve it
    test('insert and retrieve reaction log', () async {
      await db.scanHistoryDao.insertReaction(ReactionLogsCompanion.insert(
        productName: 'Suspicious Bread',
        reactionDate: DateTime(2024, 5, 10, 14, 30),
        symptomsJson: '["Bloating","Headache"]',
        severity: 3,
      ));

      final reactions = await db.scanHistoryDao.allReactions();
      expect(reactions.length, 1);
      expect(reactions.first.productName, 'Suspicious Bread');
      expect(reactions.first.severity, 3);
      expect(reactions.first.symptomsJson, '["Bloating","Headache"]');
    });

    // 7. delete reaction log
    test('delete reaction log removes it', () async {
      final id = await db.scanHistoryDao.insertReaction(
          ReactionLogsCompanion.insert(
        productName: 'Test Product',
        reactionDate: DateTime.now(),
        symptomsJson: '["Nausea"]',
        severity: 2,
      ));

      await db.scanHistoryDao.deleteReaction(id);
      final reactions = await db.scanHistoryDao.allReactions();
      expect(reactions, isEmpty);
    });

    // 8. empty reactions returns empty list
    test('empty reactions returns empty list', () async {
      final reactions = await db.scanHistoryDao.allReactions();
      expect(reactions, isEmpty);
    });

    // 9. reaction notes are nullable
    test('reaction log stores nullable notes and barcode', () async {
      await db.scanHistoryDao.insertReaction(ReactionLogsCompanion.insert(
        productName: 'Test',
        reactionDate: DateTime.now(),
        symptomsJson: '["Fatigue"]',
        severity: 1,
        notes: const Value(null),
        barcode: const Value(null),
      ));

      final reactions = await db.scanHistoryDao.allReactions();
      expect(reactions.first.notes, isNull);
      expect(reactions.first.barcode, isNull);
    });
  });
}
