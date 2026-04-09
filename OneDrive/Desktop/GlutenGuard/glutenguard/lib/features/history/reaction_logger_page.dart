import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';

// ── Symptoms list ─────────────────────────────────────────────────────────────

const _kSymptoms = [
  'Bloating',
  'Abdominal pain',
  'Diarrhea',
  'Nausea',
  'Headache',
  'Fatigue',
  'Brain fog',
  'Skin rash',
  'Joint pain',
  'Other',
];

// ── Provider: pre-select most recent RED/AMBER scan from last 24h ─────────────
// (non-private so tests can override it)

final suspiciousProductProvider = FutureProvider<ScanHistoryItem?>((ref) async {
  final dao = ref.read(scanHistoryDaoProvider);
  final recent = await dao.allScans();
  final cutoff = DateTime.now().subtract(const Duration(hours: 24));
  return recent
      .where((s) =>
          (s.resultTier == 'RED' || s.resultTier == 'AMBER') &&
          s.scannedAt.isAfter(cutoff))
      .firstOrNull;
});

// ── Page ──────────────────────────────────────────────────────────────────────

class ReactionLoggerPage extends ConsumerStatefulWidget {
  const ReactionLoggerPage({super.key});

  @override
  ConsumerState<ReactionLoggerPage> createState() => _ReactionLoggerPageState();
}

class _ReactionLoggerPageState extends ConsumerState<ReactionLoggerPage> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _reactionDate = DateTime.now();
  final Set<String> _selectedSymptoms = {};
  int _severity = 2;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Read the pre-fetched suspicious scan after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final item = ref.read(suspiciousProductProvider).valueOrNull;
      if (item != null && _productController.text.isEmpty) {
        _productController.text = item.productName;
      }
    });
  }

  @override
  void dispose() {
    _productController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pre-fill product name once from suspicious scan — use ref.listen to
    // avoid side effects inside build().
    ref.listen<AsyncValue<ScanHistoryItem?>>(suspiciousProductProvider,
        (_, next) {
      next.whenData((item) {
        if (item != null && _productController.text.isEmpty) {
          _productController.text = item.productName;
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Log a Reaction',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Product ──────────────────────────────────────────────────────
            const _SectionLabel('Suspected product'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _productController,
              decoration: _inputDecoration('Product name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 18),

            // ── Date ─────────────────────────────────────────────────────────
            const _SectionLabel('When did it happen?'),
            const SizedBox(height: 6),
            _DatePickerField(
              date: _reactionDate,
              onChanged: (d) => setState(() => _reactionDate = d),
            ),
            const SizedBox(height: 18),

            // ── Symptoms ─────────────────────────────────────────────────────
            const _SectionLabel('Symptoms'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _kSymptoms.map((s) {
                final selected = _selectedSymptoms.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: selected,
                  selectedColor: AppColors.blueLight,
                  checkmarkColor: AppColors.brandBlue,
                  backgroundColor: AppColors.surfaceGray,
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.brandBlue
                        : AppColors.textMuted,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: selected
                        ? AppColors.brandBlue
                        : AppColors.borderColor,
                  ),
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedSymptoms.add(s);
                    } else {
                      _selectedSymptoms.remove(s);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // ── Severity ─────────────────────────────────────────────────────
            const _SectionLabel('Severity'),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Mild',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Expanded(
                  child: Slider(
                    value: _severity.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: AppColors.resultAmber,
                    label: _severityLabel(_severity),
                    onChanged: (v) => setState(() => _severity = v.round()),
                  ),
                ),
                const Text('Severe',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            Center(
              child: Text(
                _severityLabel(_severity),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.resultAmber),
              ),
            ),
            const SizedBox(height: 18),

            // ── Notes ─────────────────────────────────────────────────────────
            const _SectionLabel('Notes (optional)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              decoration: _inputDecoration('Any additional details...'),
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // ── Save button ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  disabledBackgroundColor:
                      AppColors.brandBlue.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save reaction log',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Privacy note below save per spec ──────────────────────────────
            const Text(
              'This data is stored only on your device and will never be shared.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _severityLabel(int s) => switch (s) {
        1 => 'Mild',
        2 => 'Moderate',
        3 => 'Significant',
        4 => 'Severe',
        _ => 'Very severe',
      };

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final dao = ref.read(scanHistoryDaoProvider);
      final suspiciousItem = ref.read(suspiciousProductProvider).valueOrNull;
      await dao.insertReaction(ReactionLogsCompanion.insert(
        productName: _productController.text.trim(),
        barcode: Value(suspiciousItem?.barcode),
        reactionDate: _reactionDate,
        symptomsJson: jsonEncode(_selectedSymptoms.toList()),
        severity: _severity,
        notes: Value(_notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim()),
      ));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surfaceGray,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.5),
      ),
    );

class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMM d, yyyy — h:mm a').format(date);
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onChanged(DateTime(
            picked.year, picked.month, picked.day,
            date.hour, date.minute,
          ));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
