import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/scan_result.dart';

/// Displays the result of an OCR ingredient-label scan.
///
/// Receives a fully-analysed [ScanResult] and the [confidence] score
/// (0.0–1.0) from [OcrService] so the source badge can show accuracy.
class OcrResultPage extends StatelessWidget {
  final ScanResult scanResult;
  final double confidence; // 0.0–1.0

  const OcrResultPage({
    super.key,
    required this.scanResult,
    required this.confidence,
  });

  // ── Verdict helpers ──────────────────────────────────────────────────────

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

  String get _verdictIcon => switch (scanResult.tier) {
        1 => '✕',
        2 => '?',
        _ => '✓',
      };

  String get _verdictTitle => switch (scanResult.tier) {
        1 => 'Contains gluten',
        2 => 'Uncertain — verify first',
        _ => 'No gluten detected',
      };

  int get _confidencePct => (confidence * 100).round().clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VerdictBand(
              bandBg: _bandBg,
              accentColor: _accentColor,
              icon: _verdictIcon,
              title: _verdictTitle,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Explanation block — RED results lead with this
                  if (scanResult.tier == 1)
                    _ExplanationCard(reason: scanResult.reason),

                  // Ingredient list
                  const _SectionLabel(text: 'INGREDIENTS'),
                  const SizedBox(height: 8),
                  ...scanResult.ingredientResults.map(
                    (ir) => _IngredientRow(result: ir),
                  ),

                  // Source badge
                  const SizedBox(height: 12),
                  _SourceBadge(
                    confidencePct: _confidencePct,
                    ingredientCount: scanResult.ingredientResults.length,
                  ),
                ],
              ),
            ),

            // Action buttons
            _ActionButtons(
              context: context,
              tier: scanResult.tier,
            ),

            // Medical disclaimer — always visible
            const _MedicalDisclaimer(),
          ],
        ),
      ),
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

// ── Verdict band ──────────────────────────────────────────────────────────────

class _VerdictBand extends StatelessWidget {
  final Color bandBg;
  final Color accentColor;
  final String icon;
  final String title;

  const _VerdictBand({
    required this.bandBg,
    required this.accentColor,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: bandBg,
        padding:
            const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: accentColor),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ingredient label scan',
            style: TextStyle(
                fontSize: 12, color: AppColors.textMuted),
          ),
        ]),
      );
}

// ── Explanation card (RED results) ────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  final String reason;
  const _ExplanationCard({required this.reason});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.redLight,
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: AppColors.resultRed, width: 3),
          ),
        ),
        child: Text(
          reason,
          style: const TextStyle(
              fontSize: 13,
              color: AppColors.resultRed,
              height: 1.5),
        ),
      );
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.5),
      );
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
      padding: const EdgeInsets.symmetric(vertical: 7),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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

// ── Source badge ──────────────────────────────────────────────────────────────

class _SourceBadge extends StatelessWidget {
  final int confidencePct;
  final int ingredientCount;
  const _SourceBadge(
      {required this.confidencePct, required this.ingredientCount});

  @override
  Widget build(BuildContext context) => Row(children: [
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
          'OCR · $ingredientCount ingredients · $confidencePct% confidence',
          style:
              const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ]);
}

// ── Action buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final BuildContext context;
  final int tier;
  const _ActionButtons({required this.context, required this.tier});

  @override
  Widget build(BuildContext ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
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
          if (tier == 0) ...[
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)),
                ),
                child: const Text('Save to safe list'),
              ),
            ),
          ],
          if (tier == 1) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.resultRed),
                  ),
                ),
              ),
            ),
          ],
        ]),
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
