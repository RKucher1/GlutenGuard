import '../../../core/analysis/gluten_analysis_engine.dart';
import '../../../data/models/scan_result.dart';

/// Per-dish analysis result produced by [MenuScannerService].
class MenuDishResult {
  final String dishText;
  final ScanResult scanResult;
  bool manualGlutenOverride;

  MenuDishResult({
    required this.dishText,
    required this.scanResult,
    this.manualGlutenOverride = false,
  });

  /// Effective tier used for display and safety decisions.
  ///
  /// Manual override forces RED (tier 1) regardless of the analysis result —
  /// e.g. when a waiter confirms a dish contains gluten.
  int get effectiveTier => manualGlutenOverride ? 1 : scanResult.tier;
}

/// Converts raw menu OCR text into per-dish gluten verdicts.
///
/// Each non-trivial line of text is run independently through
/// [GlutenAnalysisEngine] — the same pipeline as the ingredients scanner
/// with no new analysis logic.
class MenuScannerService {
  final GlutenAnalysisEngine _engine;

  static const int _minLineLength = 3;

  MenuScannerService(this._engine);

  /// Splits [fullText] by newline, filters noise, and returns one
  /// [MenuDishResult] per non-trivial line.
  List<MenuDishResult> analyseMenuText(String fullText) {
    if (fullText.trim().isEmpty) return [];

    final lines = fullText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.length >= _minLineLength)
        .where((l) => !isNoise(l))
        .toList();

    return lines.map((line) {
      final result = _engine.analyseProduct(
        ingredients: [line],
        productName: line,
      );
      return MenuDishResult(dishText: line, scanResult: result);
    }).toList();
  }

  /// Returns true for strings that are obviously not dish descriptions.
  static bool isNoise(String line) {
    if (RegExp(r'^\d+$').hasMatch(line)) return true; // table numbers
    if (RegExp(r'^\$?\d+\.\d{2}$').hasMatch(line)) return true; // prices
    return false;
  }
}
