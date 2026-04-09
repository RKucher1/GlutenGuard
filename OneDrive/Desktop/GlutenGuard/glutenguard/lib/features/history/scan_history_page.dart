import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final scanHistoryStreamProvider = StreamProvider<List<ScanHistoryItem>>((ref) {
  return ref.watch(scanHistoryDaoProvider).watchAllScans();
});

// Stub — wired to RevenueCat in P6.
final isProProvider = Provider<bool>((_) => false);

// ── Page ──────────────────────────────────────────────────────────────────────

class ScanHistoryPage extends ConsumerWidget {
  const ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryStreamProvider);
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Scan History',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (historyAsync.valueOrNull?.isNotEmpty == true)
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: AppColors.textMuted),
              tooltip: 'Clear history',
              onPressed: () => _confirmClear(context, ref),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reaction'),
        backgroundColor: AppColors.brandBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log reaction',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.textPrimary)),
          ),
        ),
        data: (allItems) {
          if (allItems.isEmpty) return const _EmptyHistory();
          return _HistoryBody(allItems: allItems, isPro: isPro);
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will permanently delete all scan history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(scanHistoryDaoProvider).clearHistory();
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.resultRed)),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 56, color: AppColors.textMuted),
              SizedBox(height: 16),
              Text(
                'No scans yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Scanned products will appear here.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

// ── History body with date grouping + pro gate ────────────────────────────────

class _HistoryBody extends StatelessWidget {
  final List<ScanHistoryItem> allItems;
  final bool isPro;

  const _HistoryBody({required this.allItems, required this.isPro});

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final visible = isPro ? allItems : allItems.where((i) => i.scannedAt.isAfter(cutoff)).toList();
    final hidden = isPro ? <ScanHistoryItem>[] : allItems.where((i) => !i.scannedAt.isAfter(cutoff)).toList();

    // Group visible items by date label
    final groups = _groupByDate(visible);

    return ListView(
      children: [
        for (final entry in groups.entries) ...[
          _DateSeparator(label: entry.key),
          ...entry.value.map((item) => _HistoryItemCard(item: item)),
        ],
        if (hidden.isNotEmpty) _ProGateCard(hiddenCount: hidden.length),
        const SizedBox(height: 80), // FAB clearance
      ],
    );
  }

  Map<String, List<ScanHistoryItem>> _groupByDate(List<ScanHistoryItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final result = <String, List<ScanHistoryItem>>{};

    for (final item in items) {
      final d = item.scannedAt;
      final day = DateTime(d.year, d.month, d.day);
      String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('EEE, MMM d').format(d);
      }
      result.putIfAbsent(label, () => []).add(item);
    }
    return result;
  }
}

// ── Date separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.4,
          ),
        ),
      );
}

// ── History item card ─────────────────────────────────────────────────────────

class _HistoryItemCard extends StatelessWidget {
  final ScanHistoryItem item;
  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(item.scannedAt);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          _TierDot(tier: item.resultTier),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.productName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(timeStr,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── Tier dot ──────────────────────────────────────────────────────────────────

class _TierDot extends StatelessWidget {
  final String tier; // 'GREEN' | 'AMBER' | 'RED'
  const _TierDot({required this.tier});

  Color get _color => switch (tier) {
        'RED' => AppColors.resultRed,
        'AMBER' => AppColors.resultAmber,
        _ => AppColors.resultGreen,
      };

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$tier result',
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
      );
}

// ── Pro gate card ─────────────────────────────────────────────────────────────

class _ProGateCard extends StatelessWidget {
  final int hiddenCount;
  const _ProGateCard({required this.hiddenCount});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.blueLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$hiddenCount older ${hiddenCount == 1 ? 'scan' : 'scans'} hidden',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upgrade to Pro for unlimited scan history.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},  // wired to PaywallPage in P6
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Upgrade to Pro',
                    style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      );
}
