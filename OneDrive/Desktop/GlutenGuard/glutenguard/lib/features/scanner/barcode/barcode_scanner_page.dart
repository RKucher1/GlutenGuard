import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            'Scan tab — coming in Session 3',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
