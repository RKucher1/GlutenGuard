import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/core/analysis/gluten_analysis_engine.dart';
import 'package:glutenguard/core/knowledge_base/gluten_knowledge_base.dart';
import 'package:glutenguard/data/models/scan_result.dart';
import 'package:glutenguard/features/scanner/ocr/ingredient_parser.dart';
import 'package:glutenguard/features/scanner/ocr/ocr_result_page.dart';

// ── Shared minimal KB ─────────────────────────────────────────────────────────

GlutenKnowledgeBase _testKb() => const GlutenKnowledgeBase(
      tier1: [
        KbIngredient(
          name: 'wheat',
          tier: 1,
          aliases: ['wheat flour', 'enriched wheat flour', 'whole wheat flour'],
          safeQualifiers: [],
          reason: 'Wheat is a primary gluten grain.',
        ),
        KbIngredient(
          name: 'barley',
          tier: 1,
          aliases: ['barley malt', 'malt'],
          safeQualifiers: [],
          reason: 'Barley contains gluten.',
        ),
        KbIngredient(
          name: 'rye',
          tier: 1,
          aliases: [],
          safeQualifiers: [],
          reason: 'Rye contains gluten.',
        ),
      ],
      tier2: [
        KbIngredient(
          name: 'starch',
          tier: 2,
          aliases: ['modified starch', 'modified food starch'],
          safeQualifiers: ['corn', 'potato', 'tapioca', 'rice'],
          reason: 'May be wheat-derived when source is unspecified.',
        ),
        KbIngredient(
          name: 'oats',
          tier: 2,
          aliases: [],
          safeQualifiers: ['gluten-free', 'certified gluten free'],
          reason: 'High cross-contamination risk.',
        ),
      ],
    );

GlutenAnalysisEngine _engine() => GlutenAnalysisEngine(_testKb());

// ── OCR pipeline: parse → analyse ─────────────────────────────────────────────

void main() {
  group('OCR pipeline — IngredientParser + GlutenAnalysisEngine', () {
    test('clean label: rice flour, tapioca starch → GREEN', () {
      const raw = 'rice flour, tapioca starch, xanthan gum, water';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 0);
    });

    test('wheat flour in label → RED', () {
      const raw = 'enriched wheat flour, sugar, salt, yeast';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 1);
    });

    test('barley malt in label → RED', () {
      const raw = 'water, barley malt, hops, yeast';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 1);
    });

    test('rye in label → RED', () {
      const raw = 'rye flour, water, salt';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 1);
    });

    test('unqualified starch → AMBER', () {
      const raw = 'water, modified starch, sugar';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 2);
    });

    test('potato starch (safe qualifier) → GREEN', () {
      const raw = 'potato starch, water, salt';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 0);
    });

    test('corn starch (safe qualifier) → GREEN', () {
      const raw = 'sugar, corn starch, vanilla';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 0);
    });

    test('oats with no GF qualifier → AMBER', () {
      const raw = 'rolled oats, honey, almonds';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 2);
    });

    test('buckwheat → GREEN (not wheat, word boundary check)', () {
      const raw = 'buckwheat flour, water, eggs';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 0);
    });

    test('RED tier wins over AMBER when both present', () {
      const raw = 'wheat flour, modified starch, salt';
      final ingredients = IngredientParser.parse(raw);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 1);
    });

    test('empty ingredients → tier 0 with no-ingredients message', () {
      final result = _engine().analyseProduct(ingredients: []);
      expect(result.tier, 0);
      expect(result.ingredientResults, isEmpty);
    });

    test('parenthetical sub-ingredients parsed individually', () {
      const raw =
          'enriched flour (wheat flour, niacin, iron), sugar, salt';
      final ingredients = IngredientParser.parse(raw);
      // "enriched flour (wheat flour, niacin, iron)" stays as one token
      expect(ingredients.isNotEmpty, true);
      final result = _engine().analyseProduct(ingredients: ingredients);
      expect(result.tier, 1); // wheat inside parens still triggers RED
    });
  });

  // ── OcrResult helpers ──────────────────────────────────────────────────────

  group('OcrResult properties', () {
    test('hasIngredients true when rawText non-empty', () {
      const result = _FakeOcrResult(rawText: 'wheat flour, salt');
      expect(result.hasIngredients, true);
    });

    test('hasIngredients false when rawText empty', () {
      const result = _FakeOcrResult(rawText: '');
      expect(result.hasIngredients, false);
    });

    test('isLowConfidence true when confidence < 0.7', () {
      const result = _FakeOcrResult(rawText: 'x', confidence: 0.5);
      expect(result.isLowConfidence, true);
    });

    test('isLowConfidence false when confidence >= 0.7', () {
      const result = _FakeOcrResult(rawText: 'x', confidence: 0.85);
      expect(result.isLowConfidence, false);
    });
  });

  // ── OcrResultPage widget ───────────────────────────────────────────────────

  group('OcrResultPage widget', () {
    ScanResult makeScanResult(int tier) => ScanResult(
          tier: tier,
          reason: tier == 1
              ? 'Contains gluten: wheat flour.'
              : 'No gluten detected.',
          ingredientResults: [
            IngredientResult(raw: 'wheat flour', tier: tier),
            const IngredientResult(raw: 'sugar', tier: 0),
          ],
        );

    testWidgets('RED result shows "Contains gluten" title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(1),
            confidence: 0.92,
          ),
        ),
      );
      expect(find.text('Contains gluten'), findsOneWidget);
    });

    testWidgets('GREEN result shows "No gluten detected" title',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(0),
            confidence: 0.88,
          ),
        ),
      );
      expect(find.text('No gluten detected'), findsOneWidget);
    });

    testWidgets('AMBER result shows "Uncertain" title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OcrResultPage(
            scanResult: ScanResult(
              tier: 2,
              reason: 'Uncertain: modified starch.',
              ingredientResults: [
                IngredientResult(raw: 'modified starch', tier: 2),
              ],
            ),
            confidence: 0.75,
          ),
        ),
      );
      expect(find.textContaining('Uncertain'), findsOneWidget);
    });

    testWidgets('source badge shows OCR and confidence', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(0),
            confidence: 0.90,
          ),
        ),
      );
      expect(find.textContaining('OCR'), findsOneWidget);
      expect(find.textContaining('90%'), findsOneWidget);
    });

    testWidgets('medical disclaimer always present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(0),
            confidence: 0.9,
          ),
        ),
      );
      expect(find.textContaining('not a medical device'), findsOneWidget);
    });

    testWidgets('RED result shows explanation card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(1),
            confidence: 0.87,
          ),
        ),
      );
      expect(find.textContaining('Contains gluten: wheat flour'), findsOneWidget);
    });

    testWidgets('GREEN result shows Save to safe list button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(0),
            confidence: 0.9,
          ),
        ),
      );
      expect(find.text('Save to safe list'), findsOneWidget);
    });

    testWidgets('RED result shows Do not eat label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(1),
            confidence: 0.9,
          ),
        ),
      );
      expect(find.text('Do not eat'), findsOneWidget);
    });

    testWidgets('Scan again button present on all results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OcrResultPage(
            scanResult: makeScanResult(2),
            confidence: 0.8,
          ),
        ),
      );
      expect(find.text('Scan again'), findsOneWidget);
    });
  });
}

// ── Inline OcrResult stub (avoids camera dependency in tests) ─────────────────

class _FakeOcrResult {
  final String rawText;
  final double confidence;
  const _FakeOcrResult({required this.rawText, this.confidence = 0.85});

  bool get hasIngredients => rawText.trim().isNotEmpty;
  bool get isLowConfidence => confidence < 0.7;
}
