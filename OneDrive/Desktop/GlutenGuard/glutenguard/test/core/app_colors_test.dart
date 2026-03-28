import 'package:flutter_test/flutter_test.dart';
import 'package:glutenguard/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppColors', () {
    test('brandNavy has correct value', () {
      expect(AppColors.brandNavy, const Color(0xFF1A1A2E));
    });
    test('brandBlue has correct value', () {
      expect(AppColors.brandBlue, const Color(0xFF3A7BF7));
    });
    test('resultGreen has correct value', () {
      expect(AppColors.resultGreen, const Color(0xFF2E7D32));
    });
    test('resultRed has correct value', () {
      expect(AppColors.resultRed, const Color(0xFFC0272D));
    });
    test('resultAmber has correct value', () {
      expect(AppColors.resultAmber, const Color(0xFFB45309));
    });
  });
}
