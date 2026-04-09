import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glutenguard/core/analysis/gluten_analysis_engine.dart';
import 'package:glutenguard/core/constants/app_colors.dart';
import 'package:glutenguard/core/knowledge_base/gluten_knowledge_base.dart';
import 'package:glutenguard/data/models/scan_result.dart';
import 'package:glutenguard/features/scanner/menu/menu_highlight_painter.dart';
import 'package:glutenguard/features/scanner/menu/menu_scanner_page.dart';
import 'package:glutenguard/features/scanner/menu/menu_scanner_service.dart';

// ── Shared test KB ─────────────────────────────────────────────────────────────

GlutenKnowledgeBase _testKb() => const GlutenKnowledgeBase(
      tier1: [
        KbIngredient(
          name: 'wheat',
          tier: 1,
          aliases: ['wheat flour', 'wheat crumbs'],
          safeQualifiers: [],
          reason: 'Wheat is a primary gluten grain.',
        ),
        KbIngredient(
          name: 'soy sauce',
          tier: 1,
          aliases: [],
          safeQualifiers: ['gluten-free', 'gf'],
          reason: 'Traditional soy sauce contains wheat.',
        ),
      ],
      tier2: [
        KbIngredient(
          name: 'starch',
          tier: 2,
          aliases: ['modified starch'],
          safeQualifiers: ['corn', 'potato', 'tapioca'],
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

MenuScannerService _service() =>
    MenuScannerService(GlutenAnalysisEngine(_testKb()));

// ── MenuScannerService — unit tests ───────────────────────────────────────────

void main() {
  group('MenuScannerService.analyseMenuText', () {
    test('empty string returns empty list', () {
      expect(_service().analyseMenuText(''), isEmpty);
    });

    test('whitespace-only string returns empty list', () {
      expect(_service().analyseMenuText('   \n\n  '), isEmpty);
    });

    test('lines shorter than 3 chars are filtered', () {
      expect(_service().analyseMenuText('ab\nxy'), isEmpty);
    });

    test('line containing wheat → tier 1 (RED)', () {
      final dishes =
          _service().analyseMenuText('Grilled chicken with wheat crumbs');
      expect(dishes, hasLength(1));
      expect(dishes.first.scanResult.tier, 1);
    });

    test('line containing soy sauce → tier 1 (RED)', () {
      final dishes =
          _service().analyseMenuText('Stir fry vegetables with soy sauce');
      expect(dishes, hasLength(1));
      expect(dishes.first.scanResult.tier, 1);
    });

    test('line containing unqualified starch → tier 2 (AMBER)', () {
      final dishes =
          _service().analyseMenuText('Chicken in modified starch sauce');
      expect(dishes, hasLength(1));
      expect(dishes.first.scanResult.tier, 2);
    });

    test('safe line → tier 0 (GREEN)', () {
      final dishes =
          _service().analyseMenuText('Grilled salmon with lemon butter');
      expect(dishes, hasLength(1));
      expect(dishes.first.scanResult.tier, 0);
    });

    test('oats without GF qualifier → tier 2 (AMBER)', () {
      final dishes = _service().analyseMenuText('Porridge made with oats and honey');
      expect(dishes, hasLength(1));
      expect(dishes.first.scanResult.tier, 2);
    });

    test('multiple lines produce one result per non-noise line', () {
      const menu = '''
Grilled Salmon
Pasta Carbonara with wheat flour
Chicken Caesar Salad
12.99
42
''';
      final dishes = _service().analyseMenuText(menu);
      // "12.99" and "42" are noise → filtered; 3 dish lines remain
      expect(dishes, hasLength(3));
    });

    test('dishText matches the original OCR line', () {
      const line = 'Beef Wellington with puff pastry';
      final dishes = _service().analyseMenuText(line);
      expect(dishes.first.dishText, line);
    });

    test('scanResult.productName equals the dish text', () {
      const line = 'Lamb chops with rosemary';
      final dishes = _service().analyseMenuText(line);
      expect(dishes.first.scanResult.productName, line);
    });

    test('corn starch (safe qualifier) → GREEN', () {
      final dishes =
          _service().analyseMenuText('Sauce thickened with corn starch');
      expect(dishes.first.scanResult.tier, 0);
    });
  });

  // ── Noise filter ────────────────────────────────────────────────────────────

  group('MenuScannerService.isNoise', () {
    test('integer string is noise', () {
      expect(MenuScannerService.isNoise('42'), isTrue);
    });

    test('single digit is noise', () {
      expect(MenuScannerService.isNoise('5'), isTrue);
    });

    test('price with dollar sign is noise', () {
      expect(MenuScannerService.isNoise(r'$12.99'), isTrue);
    });

    test('bare decimal price is noise', () {
      expect(MenuScannerService.isNoise('8.50'), isTrue);
    });

    test('dish name is not noise', () {
      expect(MenuScannerService.isNoise('Pasta Carbonara'), isFalse);
    });

    test('short word is not noise', () {
      expect(MenuScannerService.isNoise('abc'), isFalse);
    });
  });

  // ── MenuDishResult ──────────────────────────────────────────────────────────

  group('MenuDishResult.effectiveTier', () {
    MenuDishResult _makeDish(int tier) => MenuDishResult(
          dishText: 'Test dish',
          scanResult: ScanResult(
            tier: tier,
            reason: 'test',
            ingredientResults: [],
          ),
        );

    test('override false → returns scan result tier', () {
      final dish = _makeDish(0);
      expect(dish.effectiveTier, 0);
    });

    test('override true forces tier 1 regardless of analysis tier', () {
      final dish = _makeDish(0)..manualGlutenOverride = true;
      expect(dish.effectiveTier, 1);
    });

    test('override true on AMBER dish → tier 1', () {
      final dish = _makeDish(2)..manualGlutenOverride = true;
      expect(dish.effectiveTier, 1);
    });

    test('override false on RED dish stays RED', () {
      final dish = _makeDish(1);
      expect(dish.effectiveTier, 1);
    });
  });

  // ── MenuHighlightPainter ────────────────────────────────────────────────────

  group('MenuHighlightPainter', () {
    test('shouldRepaint returns false when color unchanged', () {
      const a = MenuHighlightPainter(color: AppColors.resultGreen);
      const b = MenuHighlightPainter(color: AppColors.resultGreen);
      expect(a.shouldRepaint(b), isFalse);
    });

    test('shouldRepaint returns true when color changes', () {
      const green = MenuHighlightPainter(color: AppColors.resultGreen);
      const red = MenuHighlightPainter(color: AppColors.resultRed);
      expect(green.shouldRepaint(red), isTrue);
    });

    test('shouldRepaint RED→AMBER is true', () {
      const red = MenuHighlightPainter(color: AppColors.resultRed);
      const amber = MenuHighlightPainter(color: AppColors.resultAmber);
      expect(red.shouldRepaint(amber), isTrue);
    });
  });

  // ── MenuResultPage widget tests ─────────────────────────────────────────────

  group('MenuResultPage widget', () {
    List<MenuDishResult> _makeDishes() => [
          MenuDishResult(
            dishText: 'Grilled Salmon',
            scanResult: const ScanResult(
              tier: 0,
              reason: 'No gluten detected.',
              ingredientResults: [],
              productName: 'Grilled Salmon',
            ),
          ),
          MenuDishResult(
            dishText: 'Pasta with wheat flour',
            scanResult: const ScanResult(
              tier: 1,
              reason: 'Contains gluten: wheat flour.',
              ingredientResults: [
                IngredientResult(raw: 'wheat flour', tier: 1),
              ],
              productName: 'Pasta with wheat flour',
            ),
          ),
          MenuDishResult(
            dishText: 'Chicken with starch sauce',
            scanResult: const ScanResult(
              tier: 2,
              reason: 'Uncertain: starch.',
              ingredientResults: [
                IngredientResult(raw: 'starch', tier: 2),
              ],
              productName: 'Chicken with starch sauce',
            ),
          ),
        ];

    testWidgets('shows dish text for each line', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(dishes: _makeDishes(), confidence: 0.88),
        ),
      );
      expect(find.text('Grilled Salmon'), findsOneWidget);
      expect(find.text('Pasta with wheat flour'), findsOneWidget);
      expect(find.text('Chicken with starch sauce'), findsOneWidget);
    });

    testWidgets('shows dish count summary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(dishes: _makeDishes(), confidence: 0.88),
        ),
      );
      expect(find.textContaining('3 dishes scanned'), findsOneWidget);
    });

    testWidgets('medical disclaimer is always visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(dishes: _makeDishes(), confidence: 0.88),
        ),
      );
      expect(find.textContaining('not a medical device'), findsOneWidget);
    });

    testWidgets('RED tier badge shown when RED dishes exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(dishes: _makeDishes(), confidence: 0.88),
        ),
      );
      expect(find.textContaining('RED'), findsOneWidget);
    });

    testWidgets('AMBER tier badge shown when AMBER dishes exist',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(dishes: _makeDishes(), confidence: 0.88),
        ),
      );
      expect(find.textContaining('AMBER'), findsOneWidget);
    });

    testWidgets('checkbox is present for each dish row', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(dishes: _makeDishes(), confidence: 0.88),
        ),
      );
      expect(find.byType(Checkbox), findsNWidgets(3));
    });

    testWidgets('empty dishes list shows empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MenuResultPage(dishes: [], confidence: 0.85),
        ),
      );
      expect(find.text('No dishes detected'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('ticking override checkbox rebuilds dot for that dish',
        (tester) async {
      final dishes = [
        MenuDishResult(
          dishText: 'Safe dish',
          scanResult: const ScanResult(
            tier: 0,
            reason: 'No gluten.',
            ingredientResults: [],
          ),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(home: MenuResultPage(dishes: dishes, confidence: 0.9)),
      );

      // Checkbox should be unchecked initially
      final cb = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(cb.value, isFalse);

      // Tap checkbox
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // Override is now true — dish.manualGlutenOverride was mutated
      expect(dishes.first.manualGlutenOverride, isTrue);

      // Checkbox should now be checked
      final cbAfter = tester.widget<Checkbox>(find.byType(Checkbox).first);
      expect(cbAfter.value, isTrue);
    });

    testWidgets('instruction text shown in dish list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(dishes: _makeDishes(), confidence: 0.88),
        ),
      );
      expect(find.textContaining('Tap a dish for'), findsOneWidget);
    });

    testWidgets('singular "dish" label for single result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuResultPage(
            dishes: [
              MenuDishResult(
                dishText: 'Roast chicken',
                scanResult: const ScanResult(
                  tier: 0,
                  reason: 'Safe.',
                  ingredientResults: [],
                ),
              )
            ],
            confidence: 0.9,
          ),
        ),
      );
      expect(find.textContaining('1 dish scanned'), findsOneWidget);
    });
  });
}
