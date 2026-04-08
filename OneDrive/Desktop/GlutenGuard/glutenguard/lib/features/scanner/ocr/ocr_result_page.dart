import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/scan_result.dart';
import '../../results/explanation_card_widget.dart';
import '../../results/ingredient_chip_widget.dart';
import '../../results/quick_save_toast.dart';
import '../../results/result_header_widget.dart';
import '../../results/source_badge_widget.dart';

/// Displays the result of an OCR ingredient-label scan.
class OcrResultPage extends StatefulWidget {
  final ScanResult scanResult;
  final double confidence; // 0.0–1.0

  const OcrResultPage({
    super.key,
    required this.scanResult,
    required this.confidence,
  });

  @override
  State<OcrResultPage> createState() => _OcrResultPageState();
}

class _OcrResultPageState extends State<OcrResultPage> {
  bool _showToast = false;
  bool _saved = false;

  int get _confidencePct =>
      (widget.confidence * 100).round().clamp(0, 100);

  void _onSave() {
    if (_saved) return;
    setState(() {
      _showToast = true;
      _saved = true;
    });
  }

  void _onUndo() => setState(() => _saved = false);
  void _onToastDismissed() => setState(() => _showToast = false);

  @override
  Widget build(BuildContext context) {
    final sr = widget.scanResult;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Verdict header ────────────────────────────────────────────
              ResultHeaderWidget(
                tier: sr.tier,
                productName: 'Ingredient label scan',
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Explanation leads for RED and AMBER
                    if (sr.tier == 1)
                      ExplanationCardWidget(reason: sr.reason, tier: 1),
                    if (sr.tier == 2)
                      ExplanationCardWidget(reason: sr.reason, tier: 2),

                    // Ingredient list
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

                    // Source badge — OCR + confidence
                    const SizedBox(height: 12),
                    SourceBadgeWidget(
                      source: ScanSource.ocr,
                      confidencePct: _confidencePct,
                      ingredientCount: sr.ingredientResults.length,
                    ),
                  ],
                ),
              ),

              // ── Action buttons per spec ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: _OcrActionSection(
                  tier: sr.tier,
                  saved: _saved,
                  onSave: _onSave,
                  onScanAgain: () => Navigator.of(context).pop(),
                ),
              ),

              // ── Medical disclaimer — always visible ───────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Text(
                  'GlutenGuard is not a medical device. '
                  'Always verify with the manufacturer if you have celiac disease '
                  'or severe gluten sensitivity.',
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

        // ── QuickSaveToast overlay ────────────────────────────────────────
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

  AppBar _buildAppBar(BuildContext context) => AppBar(
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
}

// ── Action section (OCR variant) ──────────────────────────────────────────────

class _OcrActionSection extends StatelessWidget {
  final int tier;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onScanAgain;

  const _OcrActionSection({
    required this.tier,
    required this.saved,
    required this.onSave,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    if (tier == 1) {
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
                  color: AppColors.resultRed),
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

    // AMBER
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
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
