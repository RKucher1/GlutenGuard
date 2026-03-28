import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/features/product_lookup/open_food_facts_service.dart';

void main() {
  group('OpenFoodFactsService', () {
    test('parses a full product response correctly', () {
      final service = OpenFoodFactsService();
      final product = service.testParseResponse({
        'status': 1,
        'product': {
          'product_name': 'Test Rice Cakes',
          'brands': 'TestBrand',
          'ingredients_text': 'brown rice, salt',
          'allergens_tags': <String>[],
          'labels_tags': ['en:gluten-free'],
          'traces_tags': <String>[],
          'nutriments': {
            'energy-kcal_100g': 380.0,
            'proteins_100g': 7.5,
            'fat_100g': 3.2,
            'carbohydrates_100g': 80.1,
            'fiber_100g': 2.1,
            'sugars_100g': 0.5,
            'sodium_100g': 0.001,
          },
          'serving_size': '2 cakes (18g)',
        }
      }, '1234567890');

      expect(product, isNotNull);
      expect(product!.productName, 'Test Rice Cakes');
      expect(product.brand, 'TestBrand');
      expect(product.isGlutenFreeLabelled, true);
      expect(product.nutrition!.caloriesPer100g, 380.0);
      expect(product.nutrition!.proteinPer100g, 7.5);
      expect(product.nutrition!.sodiumPer100g, 1.0); // 0.001g * 1000 = 1mg
      expect(product.nutrition!.servingSizeLabel, '2 cakes (18g)');
      expect(product.nutrition!.servingSizeG, 18.0);
    });

    test('parses ingredients list from ingredients_text when no structured list', () {
      final service = OpenFoodFactsService();
      final product = service.testParseResponse({
        'status': 1,
        'product': {
          'product_name': 'Test',
          'ingredients_text': 'almond flour, coconut oil, eggs, sea salt',
          'allergens_tags': <String>[],
          'labels_tags': <String>[],
          'traces_tags': <String>[],
        }
      }, '1111');

      expect(product!.ingredientsList.length, 4);
      expect(product.ingredientsList.first, 'almond flour');
    });

    test('handles missing nutriments gracefully — returns null nutrition', () {
      final service = OpenFoodFactsService();
      final product = service.testParseResponse({
        'status': 1,
        'product': {
          'product_name': 'Minimal Product',
          'ingredients_text': 'water',
          'allergens_tags': <String>[],
          'labels_tags': <String>[],
          'traces_tags': <String>[],
        }
      }, '2222');

      expect(product!.nutrition, isNull);
      expect(product.productName, 'Minimal Product');
    });

    test('detects GF label from product name', () {
      final service = OpenFoodFactsService();
      final product = service.testParseResponse({
        'status': 1,
        'product': {
          'product_name': 'Bob\'s Gluten Free Flour',
          'ingredients_text': 'rice flour',
          'allergens_tags': <String>[],
          'labels_tags': <String>[],
          'traces_tags': <String>[],
        }
      }, '3333');

      expect(product!.isGlutenFreeLabelled, true);
    });

    test('converts kJ to kcal when kcal field is missing', () {
      final service = OpenFoodFactsService();
      final product = service.testParseResponse({
        'status': 1,
        'product': {
          'product_name': 'EU Product',
          'ingredients_text': 'rice',
          'allergens_tags': <String>[],
          'labels_tags': <String>[],
          'traces_tags': <String>[],
          'nutriments': {
            'energy_100g': 1590.0, // kJ — common in EU products
          }
        }
      }, '4444');

      // 1590 kJ / 4.184 ≈ 380 kcal
      expect(product!.nutrition!.caloriesPer100g!, closeTo(380, 5));
    });

    test('returns null when status is 0 (product not found)', () {
      final service = OpenFoodFactsService();
      final product = service.testParseResponse({
        'status': 0,
        'status_verbose': 'product not found',
      }, '9999');

      expect(product, isNull);
    });
  });
}
