import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_result.dart';
import '../product_lookup/product_lookup_provider.dart';

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
        appBar: AppBar(backgroundColor: AppColors.brandNavy),
        body: Center(child: Text('Error: $e')),
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
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
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

// ── Main result body ──────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  final dynamic product;
  final ScanResult scanResult;
  const _ResultBody({required this.product, required this.scanResult});

  Color get _bandBg => switch (scanResult.tier) {
        1 => AppColors.redLight,
        2 => AppColors.amberLight,
        _ => AppColors.greenLight,
      };

  Color get _accentColor => switch (scanResult.tier) {
        1 => AppColors.resultRed,
        2 => AppColors.resultAmber,
        _ => AppColors.resultGreen,
      };

  String get _icon => switch (scanResult.tier) {
        1 => '✕',
        2 => '?',
        _ => '✓',
      };

  String get _title => switch (scanResult.tier) {
        1 => 'Contains gluten',
        2 => 'Uncertain — verify first',
        _ => 'No gluten detected',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result band
            Container(
              width: double.infinity,
              color: _bandBg,
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 20),
              child: Column(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _icon,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _accentColor),
                ),
                const SizedBox(height: 4),
                Text(
                  product.productName,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                if (product.brand != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    product.brand!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explanation for RED
                  if (scanResult.tier == 1) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(
                              color: AppColors.resultRed, width: 3),
                        ),
                      ),
                      child: Text(
                        scanResult.reason,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.resultRed,
                            height: 1.5),
                      ),
                    ),
                  ],

                  // Ingredient chips
                  const Text(
                    'INGREDIENTS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  ...scanResult.ingredientResults.map(
                    (ir) => _IngredientRow(result: ir),
                  ),

                  // Source badge
                  const SizedBox(height: 12),
                  Row(children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.brandBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Open Food Facts · ${scanResult.ingredientResults.length} ingredients',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ]),

                  // Nutrition summary
                  if (product.nutrition != null) ...[
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
                    _NutritionRow(nutrition: product.nutrition!),
                  ],
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(
                          color: AppColors.borderColor),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)),
                    ),
                    child: const Text('Scan again'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scanResult.tier == 0
                          ? AppColors.brandBlue
                          : scanResult.tier == 1
                              ? AppColors.resultRed
                              : AppColors.resultAmber,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)),
                    ),
                    child: Text(
                      scanResult.tier == 0 ? 'Save to safe list' : 'Do not eat',
                    ),
                  ),
                ),
              ]),
            ),

            // Medical disclaimer
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Text(
                'GlutenGuard is not a medical device. '
                'Always verify with the manufacturer if you have celiac disease or severe gluten sensitivity.',
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ingredient row ────────────────────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  final IngredientResult result;
  const _IngredientRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final chipBg = switch (result.tier) {
      1 => AppColors.redLight,
      2 => AppColors.amberLight,
      _ => AppColors.greenLight,
    };
    final chipText = switch (result.tier) {
      1 => AppColors.resultRed,
      2 => AppColors.resultAmber,
      _ => AppColors.resultGreen,
    };
    final label = switch (result.tier) {
      1 => 'Gluten',
      2 => 'Verify',
      _ => 'Safe',
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceGray, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              result.raw,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: chipText),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nutrition row ─────────────────────────────────────────────────────────────

class _NutritionRow extends StatelessWidget {
  final dynamic nutrition;
  const _NutritionRow({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        style: const TextStyle(
            fontSize: 12, color: AppColors.textPrimary),
      ),
    );
  }
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
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700),
      ),
    );
