import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
import 'scan_history_dao.dart';
import 'product_cache_dao.dart';

/// Singleton database instance for the app lifetime.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final scanHistoryDaoProvider = Provider<ScanHistoryDao>((ref) {
  return ref.watch(databaseProvider).scanHistoryDao;
});

final productCacheDaoProvider = Provider<ProductCacheDao>((ref) {
  return ref.watch(databaseProvider).productCacheDao;
});
