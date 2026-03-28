import 'package:drift/drift.dart';
import 'app_database.dart';

part 'product_cache_dao.g.dart';

@DriftAccessor(tables: [ProductCacheItems, PantryItems])
class ProductCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ProductCacheDaoMixin {
  ProductCacheDao(super.db);

  // ─── Product Cache ──────────────────────────────────────────────────────────

  Future<ProductCacheItem?> getCached(String barcode) =>
      (select(productCacheItems)
            ..where((t) => t.barcode.equals(barcode)))
          .getSingleOrNull();

  Future<int> upsertCache(ProductCacheItemsCompanion entry) =>
      into(productCacheItems).insertOnConflictUpdate(entry);

  Future<int> deleteCache(String barcode) =>
      (delete(productCacheItems)..where((t) => t.barcode.equals(barcode))).go();

  /// Remove cache entries older than [maxAge].
  Future<void> evictOlderThan(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    return (delete(productCacheItems)
          ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  // ─── Pantry Items ───────────────────────────────────────────────────────────

  Future<List<PantryItem>> allPantryItems() =>
      (select(pantryItems)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Stream<List<PantryItem>> watchPantry() =>
      (select(pantryItems)
            ..where((t) => t.isInPantry.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> upsertPantryItem(PantryItemsCompanion entry) =>
      into(pantryItems).insertOnConflictUpdate(entry);

  Future<int> togglePantryItem(String ingredientId, {required bool inPantry}) =>
      (update(pantryItems)
            ..where((t) => t.ingredientId.equals(ingredientId)))
          .write(PantryItemsCompanion(
        isInPantry: Value(inPantry),
        updatedAt: Value(DateTime.now()),
      ));
}
