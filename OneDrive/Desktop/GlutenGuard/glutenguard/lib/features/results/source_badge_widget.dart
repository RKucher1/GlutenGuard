import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ScanSource { barcode, ocr, manual }

/// Displays the detection method and confidence percentage.
/// Shown on every result screen — spec requirement.
class SourceBadgeWidget extends StatelessWidget {
  final ScanSource source;
  final int confidencePct; // 0–100
  final int ingredientCount;

  const SourceBadgeWidget({
    super.key,
    required this.source,
    required this.confidencePct,
    required this.ingredientCount,
  });

  String get _sourceLabel => switch (source) {
        ScanSource.barcode => 'Barcode',
        ScanSource.ocr => 'OCR',
        ScanSource.manual => 'Manual',
      };

  @override
  Widget build(BuildContext context) {
    return Row(children: [
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
        '$_sourceLabel · $ingredientCount ingredient${ingredientCount == 1 ? '' : 's'} · $confidencePct% confidence',
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
    ]);
  }
}
