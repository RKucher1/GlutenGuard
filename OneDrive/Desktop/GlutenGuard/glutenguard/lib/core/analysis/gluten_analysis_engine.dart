import '../../data/models/scan_result.dart';
import '../knowledge_base/gluten_knowledge_base.dart';

class GlutenAnalysisEngine {
  final GlutenKnowledgeBase _kb;

  GlutenAnalysisEngine(this._kb);

  /// Singleton that uses the loaded knowledge base.
  static GlutenAnalysisEngine get instance =>
      GlutenAnalysisEngine(GlutenKnowledgeBase.instance);

  ScanResult analyseProduct({
    required List<String> ingredients,
    String? productName,
    String? barcode,
    bool isGlutenFreeLabelled = false,
  }) {
    if (ingredients.isEmpty) {
      return ScanResult(
        tier: 0,
        reason: 'No ingredients to analyse.',
        ingredientResults: [],
        productName: productName,
        barcode: barcode,
        isGlutenFreeLabelled: isGlutenFreeLabelled,
      );
    }

    final results = ingredients.map(_analyseIngredient).toList();

    // Tier 1 (RED) takes priority over tier 2 (AMBER) — severity not numeric order.
    final hasTier1 = results.any((r) => r.tier == 1);
    final hasTier2 = results.any((r) => r.tier == 2);
    final maxTier = hasTier1 ? 1 : hasTier2 ? 2 : 0;

    final reason = _buildReason(results, maxTier, isGlutenFreeLabelled);

    return ScanResult(
      tier: maxTier,
      reason: reason,
      ingredientResults: results,
      productName: productName,
      barcode: barcode,
      isGlutenFreeLabelled: isGlutenFreeLabelled,
    );
  }

  IngredientResult _analyseIngredient(String raw) {
    final n = raw.toLowerCase().trim();

    // Tier 1 — word boundary matching (never use contains — catches buckwheat as wheat)
    for (final item in _kb.tier1) {
      for (final alias in [item.name, ...item.aliases]) {
        final pattern = RegExp(
          r'\b' + RegExp.escape(alias.toLowerCase()) + r'\b',
        );
        if (pattern.hasMatch(n)) {
          // Check safe qualifiers — e.g. "gluten-free licorice"
          if (item.safeQualifiers.isNotEmpty) {
            final isSafe = item.safeQualifiers
                .any((q) => n.contains(q.toLowerCase()));
            if (isSafe) continue;
          }
          return IngredientResult(raw: raw, tier: 1, reason: item.reason);
        }
      }
    }

    // Tier 2 — word boundary matching to prevent false positives (e.g. groats ≠ oats)
    for (final item in _kb.tier2) {
      final aliasHit = [item.name, ...item.aliases].any((a) {
        final p = RegExp(r'\b' + RegExp.escape(a.toLowerCase()) + r'\b');
        return p.hasMatch(n);
      });
      if (aliasHit) {
        final isSafe = item.safeQualifiers
            .any((q) => n.contains(q.toLowerCase()));
        if (!isSafe) {
          return IngredientResult(raw: raw, tier: 2, reason: item.reason);
        }
      }
    }

    return IngredientResult(raw: raw, tier: 0, reason: null);
  }

  String _buildReason(
    List<IngredientResult> results,
    int maxTier,
    bool isGlutenFreeLabelled,
  ) {
    switch (maxTier) {
      case 1:
        final flagged = results.where((r) => r.tier == 1).toList();
        final names = flagged.map((r) => r.raw).take(3).join(', ');
        return 'Contains gluten: $names. '
            '${flagged.first.reason ?? ""}';
      case 2:
        final flagged = results.where((r) => r.tier == 2).toList();
        final names = flagged.map((r) => r.raw).take(3).join(', ');
        return 'Uncertain gluten status — verify before eating. '
            'Flagged: $names. ${flagged.first.reason ?? ""}';
      default:
        if (isGlutenFreeLabelled) {
          return 'Labelled gluten-free. No gluten ingredients detected.';
        }
        return 'No gluten ingredients detected in the listed ingredients.';
    }
  }
}
