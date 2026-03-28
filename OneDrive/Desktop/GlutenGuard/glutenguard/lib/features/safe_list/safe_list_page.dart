import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SafeListPage extends StatelessWidget {
  const SafeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            'Safe list tab',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
