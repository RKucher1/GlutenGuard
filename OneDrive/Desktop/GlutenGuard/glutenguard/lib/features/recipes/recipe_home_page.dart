import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RecipeHomePage extends StatelessWidget {
  const RecipeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            'Recipes tab',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
