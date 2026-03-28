import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/core/analysis/gluten_analysis_engine.dart';
import 'package:glutenguard/core/knowledge_base/gluten_knowledge_base.dart';

// Minimal knowledge base for fast unit tests — no Flutter asset loading needed.
GlutenKnowledgeBase _testKb() => const GlutenKnowledgeBase(
      tier1: [
        KbIngredient(
          name: 'wheat',
          tier: 1,
          aliases: [
            'wheat flour',
            'enriched wheat flour',
            'whole wheat flour',
            'whole wheat',
            'enriched flour',
            'vital wheat gluten',
            'hydrolyzed wheat protein',
            'wheat starch',
            'seitan',
            'semolina',
            'spelt',
            'kamut',
            'farro',
            'einkorn',
            'emmer',
            'triticale',
            'durum',
            'durum wheat',
            'couscous',
            'bulgur',
          ],
          safeQualifiers: [],
          reason: 'Wheat is a primary gluten grain.',
        ),
        KbIngredient(
          name: 'barley',
          tier: 1,
          aliases: [
            'barley flour',
            'barley malt',
            'barley malt extract',
            'malted barley',
            'pearl barley',
          ],
          safeQualifiers: [],
          reason: 'Barley contains hordein gluten proteins.',
        ),
        KbIngredient(
          name: 'rye',
          tier: 1,
          aliases: ['rye flour', 'rye bread'],
          safeQualifiers: [],
          reason: 'Rye contains secalin gluten proteins.',
        ),
        KbIngredient(
          name: 'malt',
          tier: 1,
          aliases: [
            'malt extract',
            'malt syrup',
            'malt flavoring',
            'malt vinegar',
            'malted barley flour',
          ],
          safeQualifiers: [],
          reason: 'Malt is derived from barley.',
        ),
        KbIngredient(
          name: 'brewer\'s yeast',
          tier: 1,
          aliases: ['brewers yeast'],
          safeQualifiers: [],
          reason: 'By-product of beer brewing — barley-derived.',
        ),
      ],
      tier2: [
        KbIngredient(
          name: 'starch',
          tier: 2,
          aliases: [
            'food starch',
            'modified starch',
            'modified food starch',
            'vegetable starch',
          ],
          safeQualifiers: [
            'tapioca',
            'cassava',
            'corn',
            'maize',
            'potato',
            'rice',
            'arrowroot',
          ],
          reason: 'Starch source may be wheat when unspecified.',
        ),
        KbIngredient(
          name: 'oats',
          tier: 2,
          aliases: ['rolled oats', 'oat flour', 'oat bran', 'whole grain oats'],
          safeQualifiers: [
            'certified gluten-free oats',
            'purity protocol oats',
            'gluten-free oats',
          ],
          reason: 'High cross-contamination risk unless certified GF.',
        ),
        KbIngredient(
          name: 'natural flavors',
          tier: 2,
          aliases: [
            'natural flavoring',
            'natural flavourings',
            'artificial flavors',
          ],
          safeQualifiers: [],
          reason: 'May contain barley-derived flavouring agents.',
        ),
      ],
    );

void main() {
  late GlutenAnalysisEngine engine;

  setUp(() {
    GlutenKnowledgeBase.setInstance(_testKb());
    engine = GlutenAnalysisEngine.instance;
  });

  tearDown(() => GlutenKnowledgeBase.clearInstance());

  // ── Tier 1 — always RED ────────────────────────────────────────────────────

  group('Tier 1 — gluten ingredients always RED', () {
    test('wheat flour → tier 1', () {
      final result = engine.analyseProduct(
          ingredients: ['wheat flour', 'water', 'salt']);
      expect(result.tier, 1);
    });

    test('enriched wheat flour → tier 1', () {
      final result = engine.analyseProduct(
          ingredients: ['enriched wheat flour', 'water', 'yeast']);
      expect(result.tier, 1);
    });

    test('barley malt extract → tier 1', () {
      final result = engine.analyseProduct(
          ingredients: ['barley malt extract', 'hops', 'water']);
      expect(result.tier, 1);
    });

    test('malt vinegar → tier 1 via malt alias', () {
      final result =
          engine.analyseProduct(ingredients: ['malt vinegar', 'salt']);
      expect(result.tier, 1);
    });

    test('seitan → tier 1', () {
      final result = engine.analyseProduct(ingredients: ['seitan']);
      expect(result.tier, 1);
    });

    test('rye flour → tier 1', () {
      final result =
          engine.analyseProduct(ingredients: ['rye flour', 'water']);
      expect(result.tier, 1);
    });

    test('spelt → tier 1', () {
      final result = engine.analyseProduct(ingredients: ['spelt', 'water']);
      expect(result.tier, 1);
    });
  });

  // ── FALSE POSITIVE guard — buckwheat ──────────────────────────────────────

  group('False positive guards', () {
    test('buckwheat does NOT trigger wheat rule', () {
      final result =
          engine.analyseProduct(ingredients: ['buckwheat flour', 'water']);
      expect(result.tier, 0,
          reason: 'buckwheat must not match \\bwheat\\b word boundary');
    });

    test('buckwheat groats → GREEN', () {
      final result =
          engine.analyseProduct(ingredients: ['buckwheat groats', 'salt']);
      expect(result.tier, 0);
    });

    test('maltodextrin does NOT trigger malt rule', () {
      final result =
          engine.analyseProduct(ingredients: ['maltodextrin', 'water']);
      // maltodextrin hits the tier2 dextrin rule — could be amber
      // but must NOT be RED from the malt word-boundary check
      expect(result.tier, isNot(1),
          reason: 'maltodextrin must not match \\bmalt\\b');
    });
  });

  // ── Tier 2 — AMBER ────────────────────────────────────────────────────────

  group('Tier 2 — uncertain ingredients → AMBER', () {
    test('modified food starch (no qualifier) → tier 2', () {
      final result = engine.analyseProduct(
          ingredients: ['modified food starch', 'salt']);
      expect(result.tier, 2);
    });

    test('rolled oats (no GF qualifier) → tier 2', () {
      final result = engine.analyseProduct(
          ingredients: ['rolled oats', 'honey', 'almonds']);
      expect(result.tier, 2);
    });

    test('natural flavors (no qualifier) → tier 2', () {
      final result = engine.analyseProduct(
          ingredients: ['apple juice concentrate', 'natural flavors', 'water']);
      expect(result.tier, 2);
    });
  });

  // ── Safe qualifiers → GREEN ───────────────────────────────────────────────

  group('Safe qualifiers turn AMBER to GREEN', () {
    test('tapioca starch → GREEN', () {
      final result =
          engine.analyseProduct(ingredients: ['tapioca starch', 'water']);
      expect(result.tier, 0);
    });

    test('corn starch → GREEN', () {
      final result =
          engine.analyseProduct(ingredients: ['corn starch', 'sugar']);
      expect(result.tier, 0);
    });

    test('potato starch → GREEN', () {
      final result =
          engine.analyseProduct(ingredients: ['potato starch']);
      expect(result.tier, 0);
    });

    test('certified gluten-free oats → GREEN', () {
      final result = engine.analyseProduct(
          ingredients: ['certified gluten-free oats', 'honey']);
      expect(result.tier, 0);
    });
  });

  // ── All-green products ────────────────────────────────────────────────────

  group('All-green ingredient lists', () {
    test('simple GF product → tier 0', () {
      final result = engine.analyseProduct(ingredients: [
        'almond flour',
        'coconut oil',
        'eggs',
        'sea salt',
      ]);
      expect(result.tier, 0);
    });

    test('empty ingredients → tier 0', () {
      final result = engine.analyseProduct(ingredients: []);
      expect(result.tier, 0);
    });
  });

  // ── Tier precedence ───────────────────────────────────────────────────────

  group('Tier precedence', () {
    test('mix of tier 1 and tier 2 → overall tier 1', () {
      final result = engine.analyseProduct(ingredients: [
        'modified starch', // tier 2
        'wheat flour', // tier 1
        'salt',
      ]);
      expect(result.tier, 1);
    });

    test('mix of tier 0 and tier 2 → overall tier 2', () {
      final result = engine.analyseProduct(ingredients: [
        'almond flour', // safe
        'rolled oats', // tier 2
        'honey',
      ]);
      expect(result.tier, 2);
    });
  });

  // ── IngredientResult detail ───────────────────────────────────────────────

  group('IngredientResult detail', () {
    test('wheat flour ingredient result has correct tier', () {
      final result = engine.analyseProduct(
          ingredients: ['wheat flour', 'water', 'salt']);
      final wheatResult =
          result.ingredientResults.firstWhere((r) => r.raw == 'wheat flour');
      expect(wheatResult.tier, 1);
      expect(wheatResult.reason, isNotNull);
    });

    test('safe ingredient result has tier 0', () {
      final result = engine.analyseProduct(
          ingredients: ['rice flour', 'water']);
      final riceResult =
          result.ingredientResults.firstWhere((r) => r.raw == 'rice flour');
      expect(riceResult.tier, 0);
    });
  });
}
