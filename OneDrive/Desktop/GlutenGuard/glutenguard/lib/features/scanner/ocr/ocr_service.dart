import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ingredient_region_detector.dart';

class OcrResult {
  final String rawText; // ingredient block only
  final String fullText; // everything OCR detected
  final String? nutritionRawText; // nutrition panel text
  final double confidence;
  final int lineCount;

  const OcrResult({
    required this.rawText,
    required this.fullText,
    this.nutritionRawText,
    required this.confidence,
    required this.lineCount,
  });

  bool get hasIngredients => rawText.trim().isNotEmpty;
  bool get hasNutrition =>
      nutritionRawText != null && nutritionRawText!.isNotEmpty;
  bool get isLowConfidence => confidence < 0.7;
}

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  static const double confidenceThreshold = 0.7;

  static const _anchors = [
    'ingredients:',
    'ingredients',
    'contains:',
    'contient:',
    'ingredientes:',
    'zutaten:',
    'ingrédients:',
    'ingr.:',
    'ingr:',
    'ingredient:',
  ];

  static const _terminators = [
    'nutrition facts',
    'supplement facts',
    'distributed by',
    'manufactured by',
    'best before',
    'best by',
    'use by',
    'net wt',
    'net weight',
    'keep refrigerated',
    'store in',
    'allergen information',
    'may contain',
    'www.',
    'http',
    '.com',
    'upc',
    'barcode',
    'kosher',
    'certified',
    'non-gmo',
    'gluten free',
  ];

  Future<OcrResult> scanIngredients(InputImage image) async {
    final recognised = await _recognizer.processImage(image);

    final lines = recognised.blocks.expand((b) => b.lines).toList();

    final textLines = lines
        .map((l) => l.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    // Average confidence across all lines (null-safe — default 0.85)
    double avgConfidence = 0.85;
    if (lines.isNotEmpty) {
      final confidences =
          lines.map((l) => l.confidence ?? 0.85).toList();
      avgConfidence =
          confidences.reduce((a, b) => a + b) / confidences.length;
    }

    final ingredientBlock = IngredientRegionDetector.extract(
      textLines,
      anchors: _anchors,
      terminators: _terminators,
    );

    final nutritionBlock = NutritionRegionDetector.extract(textLines);

    return OcrResult(
      rawText: ingredientBlock,
      fullText: textLines.join('\n'),
      nutritionRawText: nutritionBlock,
      confidence: avgConfidence,
      lineCount: textLines.length,
    );
  }

  /// Returns a short preview string for the live-preview overlay.
  Future<String> scanPreview(InputImage image) async {
    final recognised = await _recognizer.processImage(image);
    final text = recognised.blocks
        .expand((b) => b.lines)
        .map((l) => l.text)
        .join(' ');
    return text.length > 80 ? '${text.substring(0, 80)}...' : text;
  }

  void dispose() => _recognizer.close();
}
