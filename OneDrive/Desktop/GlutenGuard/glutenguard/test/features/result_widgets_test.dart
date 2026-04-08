import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/data/models/scan_result.dart';
import 'package:glutenguard/features/results/explanation_card_widget.dart';
import 'package:glutenguard/features/results/ingredient_chip_widget.dart';
import 'package:glutenguard/features/results/quick_save_toast.dart';
import 'package:glutenguard/features/results/result_header_widget.dart';
import 'package:glutenguard/features/results/source_badge_widget.dart';
import 'package:glutenguard/features/scanner/ocr/ocr_result_page.dart';

// ── ResultHeaderWidget ────────────────────────────────────────────────────────

void main() {
  group('ResultHeaderWidget', () {
    Widget build(int tier, {String? name, String? brand}) => MaterialApp(
          home: Scaffold(
            body: ResultHeaderWidget(
                tier: tier, productName: name, brand: brand),
          ),
        );

    testWidgets('tier 1 shows "Contains gluten"', (t) async {
      await t.pumpWidget(build(1));
      expect(find.text('Contains gluten'), findsOneWidget);
    });

    testWidgets('tier 0 shows "No gluten detected"', (t) async {
      await t.pumpWidget(build(0));
      expect(find.text('No gluten detected'), findsOneWidget);
    });

    testWidgets('tier 2 shows "Uncertain — verify first"', (t) async {
      await t.pumpWidget(build(2));
      expect(find.textContaining('Uncertain'), findsOneWidget);
    });

    testWidgets('shows product name when provided', (t) async {
      await t.pumpWidget(build(0, name: 'Oat Crackers'));
      expect(find.text('Oat Crackers'), findsOneWidget);
    });

    testWidgets('hides product name when null', (t) async {
      await t.pumpWidget(build(0));
      expect(find.text('Oat Crackers'), findsNothing);
    });

    testWidgets('shows brand when provided', (t) async {
      await t.pumpWidget(build(0, name: 'Crackers', brand: 'BrandX'));
      expect(find.text('BrandX'), findsOneWidget);
    });

    testWidgets('hides brand when null', (t) async {
      await t.pumpWidget(build(0, name: 'Crackers'));
      expect(find.text('BrandX'), findsNothing);
    });

    testWidgets('RED shows ✕ icon', (t) async {
      await t.pumpWidget(build(1));
      expect(find.text('✕'), findsOneWidget);
    });

    testWidgets('GREEN shows ✓ icon', (t) async {
      await t.pumpWidget(build(0));
      expect(find.text('✓'), findsOneWidget);
    });

    testWidgets('AMBER shows ? icon', (t) async {
      await t.pumpWidget(build(2));
      expect(find.text('?'), findsOneWidget);
    });
  });

  // ── ExplanationCardWidget ───────────────────────────────────────────────────

  group('ExplanationCardWidget', () {
    Widget build(String reason, int tier) => MaterialApp(
          home: Scaffold(
            body: ExplanationCardWidget(reason: reason, tier: tier),
          ),
        );

    testWidgets('shows reason text for RED', (t) async {
      await t.pumpWidget(build('Contains wheat flour.', 1));
      expect(find.text('Contains wheat flour.'), findsOneWidget);
    });

    testWidgets('shows reason text for AMBER', (t) async {
      await t.pumpWidget(build('Uncertain starch source.', 2));
      expect(find.text('Uncertain starch source.'), findsOneWidget);
    });

    testWidgets('renders without crash for empty reason', (t) async {
      await t.pumpWidget(build('', 1));
      expect(find.byType(ExplanationCardWidget), findsOneWidget);
    });
  });

  // ── IngredientChipWidget ────────────────────────────────────────────────────

  group('IngredientChipWidget', () {
    Widget build(IngredientResult result) => MaterialApp(
          home: Scaffold(
            body: IngredientChipWidget(result: result),
          ),
        );

    testWidgets('tier 0 shows "Safe" chip', (t) async {
      await t.pumpWidget(
          build(const IngredientResult(raw: 'rice flour', tier: 0)));
      expect(find.text('Safe'), findsOneWidget);
      expect(find.text('rice flour'), findsOneWidget);
    });

    testWidgets('tier 1 shows "Gluten" chip', (t) async {
      await t.pumpWidget(
          build(const IngredientResult(raw: 'wheat flour', tier: 1)));
      expect(find.text('Gluten'), findsOneWidget);
      expect(find.text('wheat flour'), findsOneWidget);
    });

    testWidgets('tier 2 shows "Verify" chip', (t) async {
      await t.pumpWidget(
          build(const IngredientResult(raw: 'modified starch', tier: 2)));
      expect(find.text('Verify'), findsOneWidget);
      expect(find.text('modified starch'), findsOneWidget);
    });

    testWidgets('long ingredient name renders without overflow', (t) async {
      await t.pumpWidget(build(const IngredientResult(
          raw: 'hydrolyzed wheat protein concentrate', tier: 1)));
      expect(find.textContaining('hydrolyzed'), findsOneWidget);
    });
  });

  // ── SourceBadgeWidget ───────────────────────────────────────────────────────

  group('SourceBadgeWidget', () {
    Widget build(ScanSource source, int pct, int count) => MaterialApp(
          home: Scaffold(
            body: SourceBadgeWidget(
                source: source,
                confidencePct: pct,
                ingredientCount: count),
          ),
        );

    testWidgets('shows "Barcode" for barcode source', (t) async {
      await t.pumpWidget(build(ScanSource.barcode, 100, 5));
      expect(find.textContaining('Barcode'), findsOneWidget);
    });

    testWidgets('shows "OCR" for ocr source', (t) async {
      await t.pumpWidget(build(ScanSource.ocr, 88, 3));
      expect(find.textContaining('OCR'), findsOneWidget);
    });

    testWidgets('shows "Manual" for manual source', (t) async {
      await t.pumpWidget(build(ScanSource.manual, 100, 2));
      expect(find.textContaining('Manual'), findsOneWidget);
    });

    testWidgets('shows confidence percentage', (t) async {
      await t.pumpWidget(build(ScanSource.ocr, 87, 4));
      expect(find.textContaining('87%'), findsOneWidget);
    });

    testWidgets('shows ingredient count', (t) async {
      await t.pumpWidget(build(ScanSource.barcode, 100, 12));
      expect(find.textContaining('12 ingredients'), findsOneWidget);
    });

    testWidgets('singular "ingredient" for count of 1', (t) async {
      await t.pumpWidget(build(ScanSource.ocr, 95, 1));
      expect(find.textContaining('1 ingredient'), findsOneWidget);
      expect(find.textContaining('1 ingredients'), findsNothing);
    });
  });

  // ── QuickSaveToast ──────────────────────────────────────────────────────────

  group('QuickSaveToast', () {
    testWidgets('shows "Saved to safe list" text', (t) async {
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: QuickSaveToast(
            onDismissed: () {},
            duration: const Duration(seconds: 30),
          ),
        ),
      ));
      expect(find.textContaining('Saved to safe list'), findsOneWidget);
    });

    testWidgets('shows Undo button', (t) async {
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: QuickSaveToast(
            onDismissed: () {},
            duration: const Duration(seconds: 30),
          ),
        ),
      ));
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('calls onUndo when Undo tapped', (t) async {
      bool undoCalled = false;
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: QuickSaveToast(
            onDismissed: () {},
            onUndo: () => undoCalled = true,
            duration: const Duration(seconds: 30),
          ),
        ),
      ));
      await t.tap(find.text('Undo'));
      await t.pumpAndSettle();
      expect(undoCalled, isTrue);
    });

    testWidgets('calls onDismissed after duration', (t) async {
      bool dismissed = false;
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: QuickSaveToast(
            onDismissed: () => dismissed = true,
            duration: const Duration(milliseconds: 100),
          ),
        ),
      ));
      await t.pump(const Duration(milliseconds: 200));
      await t.pumpAndSettle();
      expect(dismissed, isTrue);
    });
  });

  // ── OcrResultPage (uses shared widgets) ────────────────────────────────────

  group('OcrResultPage', () {
    ScanResult makeScanResult(int tier) => ScanResult(
          tier: tier,
          reason: tier == 1
              ? 'Contains gluten: wheat flour.'
              : tier == 2
                  ? 'Uncertain: modified starch.'
                  : 'No gluten detected.',
          ingredientResults: [
            IngredientResult(raw: 'wheat flour', tier: tier),
            const IngredientResult(raw: 'sugar', tier: 0),
          ],
        );

    testWidgets('RED — shows Contains gluten', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(1), confidence: 0.92),
      ));
      expect(find.text('Contains gluten'), findsOneWidget);
    });

    testWidgets('RED — shows explanation card', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(1), confidence: 0.88),
      ));
      expect(find.textContaining('Contains gluten: wheat flour'), findsOneWidget);
    });

    testWidgets('RED — shows Do not eat label', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(1), confidence: 0.9),
      ));
      expect(find.text('Do not eat'), findsOneWidget);
    });

    testWidgets('GREEN — shows No gluten detected', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(0), confidence: 0.9),
      ));
      expect(find.text('No gluten detected'), findsOneWidget);
    });

    testWidgets('GREEN — shows Save to safe list button', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(0), confidence: 0.9),
      ));
      expect(find.text('Save to safe list'), findsOneWidget);
    });

    testWidgets('GREEN — save shows toast', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(0), confidence: 0.9),
      ));
      await t.tap(find.text('Save to safe list'));
      await t.pump();
      expect(find.textContaining('Saved to safe list'), findsOneWidget);
    });

    testWidgets('AMBER — shows Uncertain title', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(2), confidence: 0.8),
      ));
      expect(find.textContaining('Uncertain'), findsWidgets);
    });

    testWidgets('AMBER — shows Contact manufacturer button', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(2), confidence: 0.8),
      ));
      expect(find.text('Contact manufacturer'), findsOneWidget);
    });

    testWidgets('shows OCR source badge', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(0), confidence: 0.85),
      ));
      expect(find.textContaining('OCR'), findsOneWidget);
      expect(find.textContaining('85%'), findsOneWidget);
    });

    testWidgets('medical disclaimer always present', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(0), confidence: 0.9),
      ));
      expect(find.textContaining('not a medical device'), findsOneWidget);
    });

    testWidgets('ingredient chips shown for all results', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(1), confidence: 0.9),
      ));
      expect(find.byType(IngredientChipWidget), findsWidgets);
    });

    testWidgets('Scan again button present', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(1), confidence: 0.9),
      ));
      expect(find.text('Scan again'), findsOneWidget);
    });

    testWidgets('GREEN — Scan another button present', (t) async {
      await t.pumpWidget(MaterialApp(
        home: OcrResultPage(scanResult: makeScanResult(0), confidence: 0.9),
      ));
      expect(find.text('Scan another'), findsOneWidget);
    });
  });
}
