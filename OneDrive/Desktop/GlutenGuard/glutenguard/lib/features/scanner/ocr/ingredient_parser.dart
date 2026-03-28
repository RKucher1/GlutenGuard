class IngredientParser {
  /// Parses raw OCR ingredient text into a clean [List<String>].
  ///
  /// Splits on commas and semicolons that are NOT inside parentheses.
  /// Handles common OCR artefacts (bullets, vertical bars).
  static List<String> parse(String rawText) {
    if (rawText.trim().isEmpty) return [];

    var text = rawText
        .replaceAll('|', 'I') // vertical bar misread as I
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final ingredients = <String>[];
    int depth = 0;
    final current = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '(') {
        depth++;
        current.write(char);
      } else if (char == ')') {
        if (depth > 0) depth--;
        current.write(char);
      } else if ((char == ',' || char == ';') && depth == 0) {
        final ingredient = current.toString().trim();
        if (ingredient.length > 1) {
          ingredients.add(_clean(ingredient));
        }
        current.clear();
      } else {
        current.write(char);
      }
    }

    final last = current.toString().trim();
    if (last.length > 1) ingredients.add(_clean(last));

    return ingredients.where((i) => i.isNotEmpty && i.length > 1).toList();
  }

  static String _clean(String raw) => raw
      .trim()
      .replaceAll(RegExp(r'^[\.\*\-\·•]+\s*'), '') // leading bullets
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Parses a nutrition facts block (multi-line OCR text) into a
  /// [NutritionFromOcr] with values normalised to per 100g.
  static NutritionFromOcr? parseNutrition(String? rawNutritionText) {
    if (rawNutritionText == null || rawNutritionText.trim().isEmpty) {
      return null;
    }

    final lines = rawNutritionText.split('\n');

    double? calories;
    double? protein;
    double? fat;
    double? carbs;
    double? fibre;
    double? sugar;
    double? sodium;
    double? servingG;

    for (final rawLine in lines) {
      final line = rawLine.toLowerCase();
      final numbers = RegExp(r'(\d+(?:\.\d+)?)')
          .allMatches(rawLine)
          .map((m) => double.tryParse(m.group(1)!))
          .whereType<double>()
          .toList();
      if (numbers.isEmpty) continue;

      if (line.contains('calorie') && !line.contains('from')) {
        calories ??= numbers.first;
      } else if (line.contains('total fat') ||
          (line.contains('fat') &&
              !line.contains('trans') &&
              !line.contains('saturated'))) {
        fat ??= numbers.first;
      } else if (line.contains('protein')) {
        protein ??= numbers.first;
      } else if (line.contains('total carb') ||
          line.contains('carbohydrate')) {
        carbs ??= numbers.first;
      } else if (line.contains('dietary fiber') ||
          line.contains('dietary fibre') ||
          line.contains('fibre')) {
        fibre ??= numbers.first;
      } else if (line.contains('total sugar') ||
          (line.contains('sugar') && !line.contains('added'))) {
        sugar ??= numbers.first;
      } else if (line.contains('sodium')) {
        sodium ??= numbers.first;
      } else if (line.contains('serving size')) {
        final gMatch = RegExp(r'(\d+(?:\.\d+)?)\s*g', caseSensitive: false)
            .firstMatch(rawLine);
        if (gMatch != null) {
          servingG = double.tryParse(gMatch.group(1)!);
        }
      }
    }

    if (calories == null && protein == null && fat == null) return null;

    return NutritionFromOcr(
      caloriesPer100g: _toP100g(calories, servingG),
      proteinPer100g: _toP100g(protein, servingG),
      fatPer100g: _toP100g(fat, servingG),
      carbsPer100g: _toP100g(carbs, servingG),
      fibrePer100g: _toP100g(fibre, servingG),
      sugarPer100g: _toP100g(sugar, servingG),
      sodiumMgPer100g: _toP100g(sodium, servingG),
      servingSizeG: servingG,
    );
  }

  static double? _toP100g(double? value, double? servingG) {
    if (value == null) return null;
    if (servingG == null || servingG <= 0) return value;
    return (value / servingG) * 100.0;
  }
}

class NutritionFromOcr {
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? fatPer100g;
  final double? carbsPer100g;
  final double? fibrePer100g;
  final double? sugarPer100g;
  final double? sodiumMgPer100g;
  final double? servingSizeG;

  const NutritionFromOcr({
    this.caloriesPer100g,
    this.proteinPer100g,
    this.fatPer100g,
    this.carbsPer100g,
    this.fibrePer100g,
    this.sugarPer100g,
    this.sodiumMgPer100g,
    this.servingSizeG,
  });
}
