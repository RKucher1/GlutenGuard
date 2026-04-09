import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/knowledge_base/gluten_knowledge_base.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';

/// Live stream of safe list items, newest first.
final safeListStreamProvider = StreamProvider<List<SafeListItem>>((ref) {
  return ref.watch(scanHistoryDaoProvider).watchSafeList();
});

/// Flagged product names from the local knowledge base (lower-cased).
/// Returns empty set on error (e.g. rootBundle unavailable in tests).
final flaggedProductNamesProvider = FutureProvider<Set<String>>((ref) async {
  try {
    final kb = await GlutenKnowledgeBase.load();
    return kb.flaggedProducts.map((f) => f.name.toLowerCase()).toSet();
  } catch (_) {
    return {};
  }
});
