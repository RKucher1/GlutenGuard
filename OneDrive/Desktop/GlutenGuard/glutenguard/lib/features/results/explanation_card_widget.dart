import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Explanation card — appears FIRST on RED and AMBER results.
///
/// For RED: left border in [AppColors.resultRed], red text.
/// For AMBER: left border in [AppColors.resultAmber], amber text.
class ExplanationCardWidget extends StatelessWidget {
  final String reason;
  final int tier; // 1=red, 2=amber

  const ExplanationCardWidget({
    super.key,
    required this.reason,
    required this.tier,
  });

  Color get _borderColor =>
      tier == 1 ? AppColors.resultRed : AppColors.resultAmber;

  Color get _bgColor =>
      tier == 1 ? AppColors.redLight : AppColors.amberLight;

  Color get _textColor =>
      tier == 1 ? AppColors.resultRed : AppColors.resultAmber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: _borderColor, width: 3),
        ),
      ),
      child: Text(
        reason,
        style: TextStyle(
          fontSize: 13,
          color: _textColor,
          height: 1.5,
        ),
      ),
    );
  }
}
