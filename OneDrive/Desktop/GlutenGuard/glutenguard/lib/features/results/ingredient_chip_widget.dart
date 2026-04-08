import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_result.dart';

/// One row in the ingredients list — ingredient name on the left,
/// tier chip (Gluten / Verify / Safe) on the right.
class IngredientChipWidget extends StatelessWidget {
  final IngredientResult result;

  const IngredientChipWidget({super.key, required this.result});

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
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: chipText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
