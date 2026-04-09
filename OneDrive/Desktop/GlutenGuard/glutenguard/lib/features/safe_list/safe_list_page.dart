import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import 'safe_list_provider.dart';
import 'safe_list_share_service.dart';

class SafeListPage extends ConsumerWidget {
  const SafeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeListAsync = ref.watch(safeListStreamProvider);
    final flaggedAsync = ref.watch(flaggedProductNamesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Safe List',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (safeListAsync.valueOrNull?.isNotEmpty == true)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.brandBlue),
              tooltip: 'Share safe list',
              onPressed: () =>
                  SafeListShareService.share(safeListAsync.value!),
            ),
        ],
      ),
      body: safeListAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error loading safe list: $e',
                style: const TextStyle(color: AppColors.textPrimary)),
          ),
        ),
        data: (items) {
          if (items.isEmpty) return const _EmptySafeList();
          final flaggedNames = flaggedAsync.valueOrNull ?? {};
          final alertItems = flaggedNames.isEmpty
              ? <SafeListItem>[]
              : items
                  .where((i) => flaggedNames.any(
                        (fn) => i.productName.toLowerCase().contains(fn),
                      ))
                  .toList();
          return _SafeListBody(items: items, alertItems: alertItems);
        },
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptySafeList extends StatelessWidget {
  const _EmptySafeList();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_outline,
                  size: 56, color: AppColors.textMuted),
              const SizedBox(height: 16),
              const Text(
                'Your safe list is empty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap 'Save to safe list' on a GREEN result\nto add products here.",
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Start Scanning'),
              ),
            ],
          ),
        ),
      );
}

// ── List body ─────────────────────────────────────────────────────────────────

class _SafeListBody extends ConsumerWidget {
  final List<SafeListItem> items;
  final List<SafeListItem> alertItems;

  const _SafeListBody({required this.items, required this.alertItems});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        if (alertItems.isNotEmpty) _AmberAlertBanner(alertItems: alertItems),
        ...items.map((item) => _SafeListItemCard(
              item: item,
              isAlerted: alertItems.any((a) => a.id == item.id),
              onRemove: () async {
                await ref
                    .read(scanHistoryDaoProvider)
                    .removeFromSafeList(item.barcode);
              },
            )),
      ],
    );
  }
}

// ── Amber alert banner ────────────────────────────────────────────────────────

class _AmberAlertBanner extends StatelessWidget {
  final List<SafeListItem> alertItems;

  const _AmberAlertBanner({required this.alertItems});

  @override
  Widget build(BuildContext context) {
    final names = alertItems.map((i) => i.productName).join(', ');
    return Semantics(
      label: 'Safety alert for $names',
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.amberLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.resultAmber.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.resultAmber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Flagged product alert',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.resultAmber,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$names ${alertItems.length == 1 ? 'has' : 'have'} been flagged. '
                    'Verify with the manufacturer before consuming.',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Item card ─────────────────────────────────────────────────────────────────

class _SafeListItemCard extends StatelessWidget {
  final SafeListItem item;
  final bool isAlerted;
  final VoidCallback onRemove;

  const _SafeListItemCard({
    required this.item,
    required this.isAlerted,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(item.addedAt);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.resultRed,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isAlerted ? AppColors.amberLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAlerted
                ? AppColors.resultAmber.withValues(alpha: 0.3)
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          children: [
            // Colour dot per spec
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isAlerted ? AppColors.resultAmber : AppColors.resultGreen,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Saved $dateStr',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isAlerted)
              const Icon(Icons.warning_amber_rounded,
                  size: 16, color: AppColors.resultAmber),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
              tooltip: 'Remove from safe list',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
