import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Settings')),
      body: const SafeArea(
        child: Center(
          child: Text(
            'Settings — coming in Week 8',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
