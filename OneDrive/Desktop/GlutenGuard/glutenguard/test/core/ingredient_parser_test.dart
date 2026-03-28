import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/features/scanner/ocr/ingredient_parser.dart';
import 'package:glutenguard/features/scanner/ocr/ingredient_region_detector.dart';
import 'package:glutenguard/features/scanner/ocr/ocr_service.dart';

void main() {
  // ── IngredientParser.parse ────────────────────────────────────────────────

  group('IngredientParser.parse', () {
    test('splits simple comma-separated list', () {
      final result = IngredientParser.parse('rice flour, water, salt');
      expect(result, ['rice flour', 'water', 'salt']);
    });

    test('handles sub-ingredients in parentheses', () {
      final result = IngredientParser.parse(
          'enriched flour (wheat flour, niacin, iron), water, salt');
      expect(result.length, 3);
      expect(result.first, 'enriched flour (wheat flour, niacin, iron)');
      expect(result.last, 'salt');
    });

    test('handles semicolon separator', () {
      final result =
          IngredientParser.parse('almond flour; coconut oil; eggs');
      expect(result.length, 3);
    });

    test('removes leading bullets and dots', () {
      final result = IngredientParser.parse('• rice, • salt, • water');
      expect(result.first, 'rice');
    });

    test('handles empty string', () {
      expect(IngredientParser.parse(''), isEmpty);
    });

    test('handles single ingredient', () {
      final result = IngredientParser.parse('water');
      expect(result.length, 1);
      expect(result.first, 'water');
    });

    test('trims whitespace from ingredients', () {
      final result =
          IngredientParser.parse('  rice flour  ,  water  ,  salt  ');
      expect(result, ['rice flour', 'water', 'salt']);
    });

    test('real world label with complex nesting', () {
      final result = IngredientParser.parse(
          'Almonds, Sugar, Cocoa Butter, Chocolate (Sugar, Chocolate, '
          'Cocoa Butter, Soya Lecithin, Vanillin), Salt');
      expect(result.length, 5);
      expect(result.any((i) => i.contains('Chocolate')), true);
    });

    test('preserves gluten ingredient inside parentheses', () {
      final result = IngredientParser.parse(
          'natural flavors (barley malt extract), sea salt');
      expect(result.length, 2);
      expect(result.first.contains('barley malt extract'), true);
    });

    test('replaces square brackets with parentheses', () {
      final result = IngredientParser.parse(
          'enriched flour [wheat flour, niacin], water');
      expect(result.length, 2);
      expect(result.first, contains('wheat flour'));
    });
  });

  // ── IngredientRegionDetector.extract ─────────────────────────────────────

  group('IngredientRegionDetector.extract', () {
    test('finds ingredient block after Ingredients: anchor', () {
      final lines = [
        'Siete Almond Flour Tortillas',
        'NET WT 8 OZ',
        'Ingredients: Almond flour, water, tapioca starch, sea salt',
        'Nutrition Facts',
        'Serving size 1 tortilla (35g)',
      ];
      final result = IngredientRegionDetector.extract(
        lines,
        anchors: ['ingredients:'],
        terminators: ['nutrition facts'],
      );
      expect(result, contains('Almond flour'));
      expect(result, contains('sea salt'));
      expect(result, isNot(contains('Nutrition Facts')));
    });

    test('stops at terminator', () {
      final lines = [
        'Ingredients: rice flour, water, salt',
        'Distributed by TestCo LLC',
      ];
      final result = IngredientRegionDetector.extract(
        lines,
        anchors: ['ingredients:'],
        terminators: ['distributed by'],
      );
      expect(result, contains('rice flour'));
      expect(result, isNot(contains('TestCo')));
    });

    test('returns a string for lines with no anchor', () {
      final lines = ['Product Name', 'Net Weight', 'Bar Code'];
      final result = IngredientRegionDetector.extract(
        lines,
        anchors: ['ingredients:'],
        terminators: ['nutrition facts'],
      );
      expect(result, isA<String>());
    });

    test('handles multilingual anchor', () {
      final lines = [
        'Ingrédients: farine de riz, eau, sel',
        'Valeurs nutritives',
      ];
      final result = IngredientRegionDetector.extract(
        lines,
        anchors: ['ingrédients:'],
        terminators: ['valeurs nutritives'],
      );
      expect(result, contains('farine de riz'));
    });
  });

  // ── IngredientParser.parseNutrition ──────────────────────────────────────

  group('IngredientParser.parseNutrition', () {
    test('parses standard US nutrition label text', () {
      const text = '''Nutrition Facts
Serving Size 2 crackers (28g)
Calories 130
Total Fat 5g
Protein 2g
Total Carbohydrate 18g
Dietary Fiber 1g
Total Sugars 2g
Sodium 150mg''';
      final result = IngredientParser.parseNutrition(text);
      expect(result, isNotNull);
      // Values normalised to per 100g from 28g serving
      expect(result!.caloriesPer100g!, closeTo(464, 10));
      expect(result.proteinPer100g!, closeTo(7.1, 0.5));
    });

    test('returns null for empty string', () {
      expect(IngredientParser.parseNutrition(''), isNull);
    });

    test('returns null for null input', () {
      expect(IngredientParser.parseNutrition(null), isNull);
    });

    test('returns null when no numbers present', () {
      expect(
          IngredientParser.parseNutrition('No nutrition data here'),
          isNull);
    });

    test('hasIngredients is false when rawText is empty', () {
      const result = OcrResult(
        rawText: '',
        fullText: 'some text',
        confidence: 0.9,
        lineCount: 3,
      );
      expect(result.hasIngredients, false);
    });

    test('isLowConfidence is true below 0.7', () {
      const result = OcrResult(
        rawText: 'wheat flour',
        fullText: 'wheat flour',
        confidence: 0.6,
        lineCount: 1,
      );
      expect(result.isLowConfidence, true);
    });

    test('isLowConfidence is false at or above 0.7', () {
      const result = OcrResult(
        rawText: 'wheat flour',
        fullText: 'wheat flour',
        confidence: 0.75,
        lineCount: 1,
      );
      expect(result.isLowConfidence, false);
    });
  });
}
