import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result.freezed.dart';
part 'scan_result.g.dart';

@freezed
class ScanResult with _$ScanResult {
  const factory ScanResult({
    required int tier, // 0=safe, 1=red (gluten), 2=amber (uncertain)
    required String reason,
    required List<IngredientResult> ingredientResults,
    @Default(false) bool isGlutenFreeLabelled,
    @Default(false) bool hasFlaggedProduct,
    String? productName,
    String? barcode,
  }) = _ScanResult;

  factory ScanResult.fromJson(Map<String, dynamic> json) =>
      _$ScanResultFromJson(json);
}

@freezed
class IngredientResult with _$IngredientResult {
  const factory IngredientResult({
    required String raw,
    required int tier, // 0=safe, 1=red, 2=amber
    String? reason,
  }) = _IngredientResult;

  factory IngredientResult.fromJson(Map<String, dynamic> json) =>
      _$IngredientResultFromJson(json);
}
