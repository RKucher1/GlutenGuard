import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import '../../data/models/product.dart';
import '../../data/models/scan_result.dart';
import '../product_lookup/product_lookup_provider.dart';
import 'explanation_card_widget.dart';
import 'ingredient_chip_widget.dart';
import 'quick_save_toast.dart';
import 'result_header_widget.dart';
import 'source_badge_widget.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productLookupProvider);

    return state.when(
      loading: () => const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.brandBlue)),
      ),
      error: (e, _) => Scaffold(
        appBar: _appBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.textPrimary)),
          ),
        ),
      ),
      data: (data) {
        if (data.product == null || data.scanResult == null) {
          return _NotFoundPage(context: context);
        }
        return _ResultBody(
          product: data.product!,
          scanResult: data.scanResult!,
        );
      },

    );
  }
}

// ── Not found ─────────────────────────────────────────────────────────────────

class _NotFoundPage extends StatelessWidget {
  final BuildContext context;
  const _NotFoundPage({required this.context});

  @override
  Widget build(BuildContext ctx) => Scaffold(
        backgroundColor: AppColors.white,
        appBar: _appBar(ctx),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'Product not found',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try scanning the ingredient label directly.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Scan again'),
                ),
              ],
            ),
          ),
        ),
      );
}

// ── Result body ───────────────────────────────────────────────────────────────

class _ResultBody extends ConsumerStatefulWidget {
  final Product product;
  final ScanResult scanResult;

  const _ResultBody({required this.product, required this.scanResult});

  @override
  ConsumerState<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends ConsumerState<_ResultBody> {
  bool _showToast = false;
  bool _saved = false;
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();
    // Auto-save every scan to history on first render.
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSaveHistory());
  }

  Future<void> _autoSaveHistory() async {
    if (_historySaved) return;
    _historySaved = true;
    final dao = ref.read(scanHistoryDaoProvider);
    final tierLabel = switch (widget.scanResult.tier) {
      1 => 'RED',
      2 => 'AMBER',
      _ => 'GREEN',
    };
    final flaggedJson = jsonEncode(widget.scanResult.ingredientResults
        .where((r) => r.tier > 0)
        .map((r) => r.raw)
        .toList());
    await dao.insertScan(ScanHistoryItemsCompanion.insert(
      barcode: widget.product.barcode ?? '',
      productName: widget.product.productName,
      resultTier: tierLabel,
      flaggedIngredients: flaggedJson,
      scannedAt: DateTime.now(),
    ));
  }

  Future<void> _onSave() async {
    if (_saved) return;
    setState(() {
      _showToast = true;
      _saved = true;
    });
    final dao = ref.read(scanHistoryDaoProvider);
    await dao.addToSafeList(SafeListItemsCompanion.insert(
      barcode: widget.product.barcode ?? widget.product.productName,
      productName: widget.product.productName,
      addedAt: DateTime.now(),
    ));
  }

  Future<void> _onUndo() async {
    setState(() => _saved = false);
    final dao = ref.read(scanHistoryDaoProvider);
    await dao.removeFromSafeList(
        widget.product.barcode ?? widget.product.productName);
  }

  void _onToastDismissed() => setState(() => _showToast = false);

  ScanResult get sr => widget.scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Verdict header ──────────────────────────────────────────────
              ResultHeaderWidget(
                tier: sr.tier,
                productName: widget.product.productName,
                brand: widget.product.brand,
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // RED: explanation leads
                    if (sr.tier == 1)
                      ExplanationCardWidget(reason: sr.reason, tier: 1),

                    // AMBER: explanation below (community flag will be above in P5)
                    if (sr.tier == 2)
                      ExplanationCardWidget(reason: sr.reason, tier: 2),

                    // Ingredients section
                    const Text(
                      'INGREDIENTS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    ...sr.ingredientResults.map(
                      (ir) => IngredientChipWidget(result: ir),
                    ),

                    // Source badge
                    const SizedBox(height: 12),
                    SourceBadgeWidget(
                      source: ScanSource.barcode,
                      confidencePct: 100,
                      ingredientCount: sr.ingredientResults.length,
                    ),

                    // Nutrition (if available)
                    if (widget.product.nutrition != null) ...[
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.borderColor),
                      const SizedBox(height: 16),
                      const Text(
                        'NUTRITION PER 100G',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      _NutritionRow(nutrition: widget.product.nutrition!),
                    ],
                  ],
                ),
              ),

              // ── Action buttons per spec ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: _ActionSection(
                  tier: sr.tier,
                  saved: _saved,
                  onSave: _onSave,
                  onScanAgain: () => Navigator.pop(context),
                ),
              ),

              // ── Medical disclaimer — always visible ─────────────────────────
              const _MedicalDisclaimer(),
            ],
          ),
        ),

        // ── QuickSaveToast overlay ──────────────────────────────────────────
        if (_showToast)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: QuickSaveToast(
              onUndo: _onUndo,
              onDismissed: _onToastDismissed,
            ),
          ),
      ]),
    );
  }
}

// ── Action section per verdict ─────────────────────────────────────────────────

class _ActionSection extends StatelessWidget {
  final int tier;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onScanAgain;

  const _ActionSection({
    required this.tier,
    required this.saved,
    required this.onSave,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    if (tier == 1) {
      // RED — "Do not eat" label (not a button) + "Scan again"
      return Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.redLight,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.resultRed),
          ),
          child: const Center(
            child: Text(
              'Do not eat',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.resultRed,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onScanAgain,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.borderColor),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
            child: const Text('Scan again'),
          ),
        ),
      ]);
    }

    if (tier == 0) {
      // GREEN — "Save to Safe List" (blue button) + "Scan another" secondary
      return Column(children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: saved ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              disabledBackgroundColor:
                  AppColors.brandBlue.withValues(alpha: 0.5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
            child: Text(saved ? 'Saved ✓' : 'Save to safe list'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onScanAgain,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.borderColor),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11)),
            ),
            child: const Text('Scan another'),
          ),
        ),
      ]);
    }

    // AMBER — "Contact manufacturer" CTA + "Scan again"
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {}, // URL launcher wired in P5
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.resultAmber,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11)),
          ),
          child: const Text('Contact manufacturer'),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onScanAgain,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            side: const BorderSide(color: AppColors.borderColor),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11)),
          ),
          child: const Text('Scan again'),
        ),
      ),
    ]);
  }
}

// ── Nutrition row ─────────────────────────────────────────────────────────────

class _NutritionRow extends StatelessWidget {
  final dynamic nutrition;
  const _NutritionRow({required this.nutrition});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Calories: ${nutrition.caloriesPer100g?.toStringAsFixed(0) ?? "—"} kcal  '
          'Protein: ${nutrition.proteinPer100g?.toStringAsFixed(1) ?? "—"}g  '
          'Fat: ${nutrition.fatPer100g?.toStringAsFixed(1) ?? "—"}g  '
          'Carbs: ${nutrition.carbsPer100g?.toStringAsFixed(1) ?? "—"}g  '
          'Na: ${nutrition.sodiumPer100g?.toStringAsFixed(0) ?? "—"}mg',
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
        ),
      );
}

// ── Medical disclaimer ────────────────────────────────────────────────────────

class _MedicalDisclaimer extends StatelessWidget {
  const _MedicalDisclaimer();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Text(
          'GlutenGuard is not a medical device. '
          'Always verify with the manufacturer if you have celiac disease '
          'or severe gluten sensitivity.',
          style: TextStyle(
              fontSize: 10, color: AppColors.textMuted, height: 1.4),
          textAlign: TextAlign.center,
        ),
      );
}

// ── Shared app bar ────────────────────────────────────────────────────────────

AppBar _appBar(BuildContext context) => AppBar(
      backgroundColor: AppColors.brandNavy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'GlutenGuard',
        style: TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
