import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String productName,
    String? brand,
    String? barcode,
    String? imageUrl,
    // Gluten analysis inputs
    required String ingredientsText,
    @Default([]) List<String> ingredientsList,
    @Default([]) List<String> allergenTags,
    @Default([]) List<String> labelsTags,
    @Default([]) List<String> tracesTags,
    @Default(false) bool isGlutenFreeLabelled,
    // Nutrition data
    NutritionProfile? nutrition,
    // Source
    @Default('off') String dataSource,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
class NutritionProfile with _$NutritionProfile {
  const factory NutritionProfile({
    double? caloriesPer100g,
    double? proteinPer100g,
    double? fatPer100g,
    double? carbsPer100g,
    double? fibrePer100g,
    double? sugarPer100g,
    double? sodiumPer100g, // stored as mg per 100g
    double? servingSizeG,
    String? servingSizeLabel,
    @Default('off') String source, // 'off' | 'usda' | 'ocr'
  }) = _NutritionProfile;

  factory NutritionProfile.fromJson(Map<String, dynamic> json) =>
      _$NutritionProfileFromJson(json);
}
