import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const brandName = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.3,
  );
  static const screenTitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted,
  );
  static const caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted,
  );
  static const resultTitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
  );
  static const ingredientName = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
}
