import 'package:dio/dio.dart';
import '../../data/models/product.dart';

class OpenFoodFactsService {
  final Dio _dio;

  OpenFoodFactsService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://world.openfoodfacts.org',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              headers: {
                'User-Agent': 'GlutenGuard/1.0 (celiac safety scanner)',
              },
            ));

  Future<Product?> fetchByBarcode(String barcode) async {
    try {
      final response = await _dio.get('/api/v0/product/$barcode.json');

      if (response.statusCode != 200) return null;

      final data = response.data as Map<String, dynamic>;
      return testParseResponse(data, barcode);
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Parsing helpers ───────────────────────────────────────────────────────

  String? _string(Map<String, dynamic> p, List<String> keys) {
    for (final key in keys) {
      final val = p[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    return null;
  }

  List<String> _stringList(Map<String, dynamic> p, String key) {
    final val = p[key];
    if (val == null) return [];
    if (val is List) return val.map((e) => e.toString()).toList();
    return [];
  }

  List<String> _parseIngredientsList(Map<String, dynamic> p) {
    // Try structured ingredients array first
    final ingredients = p['ingredients'] as List<dynamic>?;
    if (ingredients != null && ingredients.isNotEmpty) {
      return ingredients
          .map((i) => (i as Map<String, dynamic>?)?['text']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    // Fall back to splitting ingredients_text
    final text = p['ingredients_text']?.toString() ?? '';
    if (text.isEmpty) return [];
    return text
        .split(RegExp(r'[,;]'))
        .map((s) => s.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((s) => s.length > 1)
        .toList();
  }

  bool _isGlutenFreeLabelled(Map<String, dynamic> p) {
    final labels = _stringList(p, 'labels_tags');
    final name = (p['product_name'] ?? '').toString().toLowerCase();
    return labels.any((l) => l.contains('gluten-free') || l.contains('gluten_free')) ||
        name.contains('gluten free') ||
        name.contains('gluten-free');
  }

  NutritionProfile? _parseNutrition(Map<String, dynamic> p) {
    final n = p['nutriments'] as Map<String, dynamic>?;
    if (n == null) return null;

    final calories = _double(n, ['energy-kcal_100g', 'energy-kcal']);
    // If no kcal field, try converting from kJ
    final caloriesFinal =
        calories ?? _kilojouleToKcal(_double(n, ['energy_100g', 'energy']));

    // Sodium: OFF stores in g per 100g, convert to mg
    final sodiumG = _double(n, ['sodium_100g', 'sodium']);
    final sodiumMg = sodiumG != null ? sodiumG * 1000 : null;

    // Serving size
    final servingStr = p['serving_size']?.toString();
    final servingG = _parseServingGrams(servingStr);

    if (caloriesFinal == null && _double(n, ['proteins_100g']) == null) {
      return null; // No meaningful nutrition data
    }

    return NutritionProfile(
      caloriesPer100g: caloriesFinal,
      proteinPer100g: _double(n, ['proteins_100g', 'proteins']),
      fatPer100g: _double(n, ['fat_100g', 'fat']),
      carbsPer100g: _double(n, ['carbohydrates_100g', 'carbohydrates']),
      fibrePer100g: _double(n, ['fiber_100g', 'fiber', 'fibers_100g']),
      sugarPer100g: _double(n, ['sugars_100g', 'sugars']),
      sodiumPer100g: sodiumMg,
      servingSizeG: servingG,
      servingSizeLabel: servingStr,
      source: 'off',
    );
  }

  double? _double(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final val = m[key];
      if (val == null) continue;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      final parsed = double.tryParse(val.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  double? _kilojouleToKcal(double? kj) => kj != null ? (kj / 4.184) : null;

  double? _parseServingGrams(String? servingStr) {
    if (servingStr == null || servingStr.isEmpty) return null;
    // Extract grams from strings like "1 cup (240g)" or "30 g" or "30g"
    final match =
        RegExp(r'(\d+(?:\.\d+)?)\s*g', caseSensitive: false).firstMatch(servingStr);
    if (match != null) return double.tryParse(match.group(1)!);
    // Try parsing pure number (might be grams)
    return double.tryParse(servingStr.replaceAll(RegExp(r'[^\d.]'), ''));
  }

  // Test helper — exposes internal parsing without HTTP
  Product? testParseResponse(Map<String, dynamic> data, String barcode) {
    if (data['status'] != 1) return null;
    final p = data['product'] as Map<String, dynamic>? ?? {};
    return Product(
      barcode: barcode,
      productName:
          _string(p, ['product_name', 'product_name_en']) ?? 'Unknown product',
      brand: _string(p, ['brands']),
      imageUrl: _string(p, ['image_front_url', 'image_url']),
      ingredientsText:
          _string(p, ['ingredients_text', 'ingredients_text_en']) ?? '',
      ingredientsList: _parseIngredientsList(p),
      allergenTags: _stringList(p, 'allergens_tags'),
      labelsTags: _stringList(p, 'labels_tags'),
      tracesTags: _stringList(p, 'traces_tags'),
      isGlutenFreeLabelled: _isGlutenFreeLabelled(p),
      nutrition: _parseNutrition(p),
      dataSource: 'off',
    );
  }
}
