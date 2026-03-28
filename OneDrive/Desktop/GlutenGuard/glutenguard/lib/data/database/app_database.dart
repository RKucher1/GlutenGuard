import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'scan_history_dao.dart';
import 'product_cache_dao.dart';

part 'app_database.g.dart';

// ─── Tables ───────────────────────────────────────────────────────────────────

class ScanHistoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text()();
  TextColumn get productName => text()();
  TextColumn get resultTier => text()();          // GREEN | AMBER | RED
  TextColumn get flaggedIngredients => text()();  // JSON list
  DateTimeColumn get scannedAt => dateTime()();
}

class SafeListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().unique()();
  TextColumn get productName => text()();
  DateTimeColumn get addedAt => dateTime()();
}

class ProductCacheItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().unique()();
  TextColumn get jsonPayload => text()();         // raw OFF/FDC response
  DateTimeColumn get cachedAt => dateTime()();
}

class PantryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingredientId => text().unique()(); // e.g. p001, f001
  TextColumn get name => text()();
  BoolColumn get isInPantry => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [ScanHistoryItems, SafeListItems, ProductCacheItems, PantryItems],
  daos: [ScanHistoryDao, ProductCacheDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'glutenguard.db'));
    return NativeDatabase.createInBackground(file);
  });
}
