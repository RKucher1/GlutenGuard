import 'package:drift/drift.dart';
import 'app_database.dart';

part 'scan_history_dao.g.dart';

@DriftAccessor(tables: [ScanHistoryItems, SafeListItems])
class ScanHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$ScanHistoryDaoMixin {
  ScanHistoryDao(super.db);

  // ─── Scan History ───────────────────────────────────────────────────────────

  Future<List<ScanHistoryItem>> allScans() =>
      (select(scanHistoryItems)
            ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)]))
          .get();

  Stream<List<ScanHistoryItem>> watchAllScans() =>
      (select(scanHistoryItems)
            ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)]))
          .watch();

  Future<int> insertScan(ScanHistoryItemsCompanion entry) =>
      into(scanHistoryItems).insert(entry);

  Future<int> deleteScan(int id) =>
      (delete(scanHistoryItems)..where((t) => t.id.equals(id))).go();

  Future<void> clearHistory() => delete(scanHistoryItems).go();

  // ─── Safe List ──────────────────────────────────────────────────────────────

  Future<List<SafeListItem>> allSafeItems() =>
      (select(safeListItems)
            ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .get();

  Stream<List<SafeListItem>> watchSafeList() =>
      (select(safeListItems)
            ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .watch();

  Future<bool> isSafe(String barcode) async {
    final row = await (select(safeListItems)
          ..where((t) => t.barcode.equals(barcode)))
        .getSingleOrNull();
    return row != null;
  }

  Future<int> addToSafeList(SafeListItemsCompanion entry) =>
      into(safeListItems).insertOnConflictUpdate(entry);

  Future<int> removeFromSafeList(String barcode) =>
      (delete(safeListItems)..where((t) => t.barcode.equals(barcode))).go();
}
