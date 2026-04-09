import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'features/scanner/barcode/barcode_scanner_page.dart';
import 'features/safe_list/safe_list_page.dart';
import 'features/recipes/recipe_home_page.dart';
import 'features/history/scan_history_page.dart';
import 'features/history/reaction_logger_page.dart';
import 'features/settings/settings_page.dart';

final _router = GoRouter(
  initialLocation: '/scan',
  routes: [
    GoRoute(
      path: '/reaction',
      builder: (c, s) => const ReactionLoggerPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/scan', builder: (c, s) => const BarcodeScannerPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/safelist', builder: (c, s) => const SafeListPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/recipes', builder: (c, s) => const RecipeHomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/history', builder: (c, s) => const ScanHistoryPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
        ]),
      ],
    ),
  ],
);

class GlutenGuardApp extends StatelessWidget {
  const GlutenGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GlutenGuard',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandBlue,
          surface: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderColor, width: 0.5),
          ),
          color: AppColors.white,
        ),
        child: NavigationBar(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.blueLight,
          selectedIndex: shell.currentIndex,
          onDestinationSelected: shell.goBranch,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: Icon(Icons.qr_code_scanner, color: AppColors.brandBlue),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark, color: AppColors.brandBlue),
              label: 'Safe list',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.brandBlue),
              label: 'Recipes',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history, color: AppColors.brandBlue),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppColors.brandBlue),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
