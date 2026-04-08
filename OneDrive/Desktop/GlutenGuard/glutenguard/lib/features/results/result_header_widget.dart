import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Coloured verdict band shown at the top of every result screen.
///
/// Contains a circle icon (✓ / ✕ / ?), the verdict title, and optionally
/// a product name and brand subtitle.
class ResultHeaderWidget extends StatelessWidget {
  final int tier; // 0=green, 1=red, 2=amber
  final String? productName;
  final String? brand;

  const ResultHeaderWidget({
    super.key,
    required this.tier,
    this.productName,
    this.brand,
  });

  Color get _bandBg => switch (tier) {
        1 => AppColors.redLight,
        2 => AppColors.amberLight,
        _ => AppColors.greenLight,
      };

  Color get _accentColor => switch (tier) {
        1 => AppColors.resultRed,
        2 => AppColors.resultAmber,
        _ => AppColors.resultGreen,
      };

  String get _icon => switch (tier) {
        1 => '✕',
        2 => '?',
        _ => '✓',
      };

  String get _title => switch (tier) {
        1 => 'Contains gluten',
        2 => 'Uncertain — verify first',
        _ => 'No gluten detected',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _bandBg,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _accentColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _icon,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _accentColor,
          ),
        ),
        if (productName != null) ...[
          const SizedBox(height: 4),
          Text(
            productName!,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
        if (brand != null) ...[
          const SizedBox(height: 2),
          Text(
            brand!,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ]),
    );
  }
}
