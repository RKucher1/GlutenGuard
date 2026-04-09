import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/analysis/gluten_analysis_engine.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/knowledge_base/gluten_knowledge_base.dart';
import '../../../data/models/scan_result.dart';
import '../ocr/ocr_result_page.dart';
import '../ocr/ocr_scanner_page.dart';
import '../ocr/ocr_service.dart';
import 'menu_highlight_painter.dart';
import 'menu_scanner_service.dart';

// ── MenuScannerPage ────────────────────────────────────────────────────────────

/// Full-frame OCR camera page for scanning restaurant menus.
///
/// Captures a photo via [image_picker], runs all text lines through
/// [OcrService] + [MenuScannerService] (same pipeline as the ingredients
/// scanner — no new analysis logic), then pushes [MenuResultPage].
class MenuScannerPage extends StatefulWidget {
  const MenuScannerPage({super.key});

  @override
  State<MenuScannerPage> createState() => _MenuScannerPageState();
}

class _MenuScannerPageState extends State<MenuScannerPage> {
  late final MobileScannerController _controller;
  late final OcrService _ocrService;
  final ImagePicker _picker = ImagePicker();
  String _previewText = '';
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _ocrService = OcrService();
  }

  @override
  void dispose() {
    _controller.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _onScan() async {
    if (_isScanning) return;
    HapticFeedback.mediumImpact();

    // Pause viewfinder while image_picker is open.
    await _controller.stop();
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    await _controller.start();

    if (file == null) return; // user cancelled

    setState(() {
      _isScanning = true;
      _previewText = 'Reading menu text…';
    });

    try {
      final inputImage = InputImage.fromFilePath(file.path);

      // Show a partial preview while the full scan runs.
      final preview = await _ocrService.scanPreview(inputImage);
      if (mounted && preview.isNotEmpty) {
        setState(() => _previewText = preview);
      }

      final ocrResult = await _ocrService.scanIngredients(inputImage);

      if (!mounted) return;

      // Menu mode uses fullText (all detected lines), not the ingredient block.
      final menuText = ocrResult.fullText.isNotEmpty
          ? ocrResult.fullText
          : ocrResult.rawText;

      if (menuText.isEmpty) {
        _setError('No text detected. Point at the menu text and try again.');
        return;
      }

      final service = MenuScannerService(
        GlutenAnalysisEngine(GlutenKnowledgeBase.instance),
      );
      final dishes = service.analyseMenuText(menuText);

      if (!mounted) return;

      if (dishes.isEmpty) {
        _setError(
            'No dish descriptions found. Try scanning closer to the text.');
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MenuResultPage(
            dishes: dishes,
            confidence: ocrResult.confidence,
          ),
        ),
      );
    } catch (_) {
      if (mounted) _setError('Error scanning. Please try again.');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _setError(String msg) {
    if (mounted) {
      setState(() {
        _isScanning = false;
        _previewText = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // ── Camera feed ────────────────────────────────────────────────────
        MobileScanner(controller: _controller, onDetect: (_) {}),

        // ── Header ─────────────────────────────────────────────────────────
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.eco, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GlutenGuard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
                Row(children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: Icon(
                      _controller.torchEnabled == true
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () => _controller.toggleTorch(),
                  ),
                ]),
              ],
            ),
          ),
        ),

        // ── Viewfinder — taller than ingredient scanner for menu pages ─────
        Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 320,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.brandBlue.withValues(alpha: 0.65),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(children: [
              const Positioned(
                  top: -1,
                  left: -1,
                  child: _Corner(top: true, left: true)),
              const Positioned(
                  top: -1,
                  right: -1,
                  child: _Corner(top: true, left: false)),
              const Positioned(
                  bottom: -1,
                  left: -1,
                  child: _Corner(top: false, left: true)),
              const Positioned(
                  bottom: -1,
                  right: -1,
                  child: _Corner(top: false, left: false)),

              if (_previewText.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _previewText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.4,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ]),
          ),
        ),

        // ── Mode chips ─────────────────────────────────────────────────────
        Positioned(
          bottom: 150,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ModeChip(
                label: 'Barcode',
                selected: false,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 10),
              _ModeChip(
                label: 'Ingredients',
                selected: false,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const OcrScannerPage()),
                ),
              ),
              const SizedBox(width: 10),
              const _ModeChip(label: 'Menu', selected: true, onTap: null),
            ],
          ),
        ),

        // ── Scan button ────────────────────────────────────────────────────
        Positioned(
          bottom: 64,
          left: 0,
          right: 0,
          child: Center(
            child: Semantics(
              label: 'Scan menu',
              button: true,
              child: GestureDetector(
                onTap: _onScan,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _isScanning
                        ? AppColors.brandBlue.withValues(alpha: 0.7)
                        : AppColors.brandBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: _isScanning
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : const Icon(Icons.restaurant_menu,
                          color: Colors.white, size: 26),
                ),
              ),
            ),
          ),
        ),

        // ── Instruction ────────────────────────────────────────────────────
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Text(
            'Point at menu · Tap to scan full page',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── MenuResultPage ─────────────────────────────────────────────────────────────

/// Scrollable dish list showing one RED / AMBER / GREEN dot per line.
///
/// Each row has a checkbox ("Waiter confirmed contains gluten") that forces
/// the dot to RED regardless of the analysis result.  Tapping a row pushes
/// [OcrResultPage] to show the full ingredient-level detail for that dish.
class MenuResultPage extends StatefulWidget {
  final List<MenuDishResult> dishes;
  final double confidence;

  const MenuResultPage({
    super.key,
    required this.dishes,
    required this.confidence,
  });

  @override
  State<MenuResultPage> createState() => _MenuResultPageState();
}

class _MenuResultPageState extends State<MenuResultPage> {
  void _navigateToDishDetail(MenuDishResult dish) {
    final scanResult = dish.manualGlutenOverride
        ? ScanResult(
            tier: 1,
            reason: 'Waiter confirmed this dish contains gluten.',
            ingredientResults: dish.scanResult.ingredientResults,
            productName: dish.dishText,
          )
        : dish.scanResult;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OcrResultPage(
          scanResult: scanResult,
          confidence: widget.confidence,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: AppColors.brandNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Menu Scan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: widget.dishes.isEmpty
          ? _buildEmptyState()
          : _buildDishList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surfaceGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_menu,
                  color: AppColors.textMuted, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'No dishes detected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Point the camera at the menu text and scan again.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishList() {
    final redCount =
        widget.dishes.where((d) => d.effectiveTier == 1).length;
    final amberCount =
        widget.dishes.where((d) => d.effectiveTier == 2).length;

    return Column(
      children: [
        // ── Summary + instruction ─────────────────────────────────────────
        Container(
          color: AppColors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (redCount > 0) ...[
                  _TierBadge(count: redCount, tier: 1),
                  const SizedBox(width: 8),
                ],
                if (amberCount > 0) ...[
                  _TierBadge(count: amberCount, tier: 2),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    '${widget.dishes.length} dish${widget.dishes.length == 1 ? '' : 'es'} scanned',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.right,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              const Text(
                'Tap a dish for ingredient details. '
                'Check the box if a waiter confirmed it contains gluten.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderColor),

        // ── Dish list ─────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            itemCount: widget.dishes.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.borderColor),
            itemBuilder: (context, i) {
              final dish = widget.dishes[i];
              return _DishRow(
                dish: dish,
                onTap: () => _navigateToDishDetail(dish),
                onOverrideChanged: (v) =>
                    setState(() => dish.manualGlutenOverride = v),
              );
            },
          ),
        ),

        // ── Medical disclaimer — always visible ───────────────────────────
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Text(
            'GlutenGuard is not a medical device. '
            'Always verify with the restaurant if you have celiac disease '
            'or severe gluten sensitivity.',
            style: TextStyle(
                fontSize: 10, color: AppColors.textMuted, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── _DishRow ──────────────────────────────────────────────────────────────────

class _DishRow extends StatelessWidget {
  final MenuDishResult dish;
  final VoidCallback onTap;
  final ValueChanged<bool> onOverrideChanged;

  const _DishRow({
    required this.dish,
    required this.onTap,
    required this.onOverrideChanged,
  });

  Color get _dotColor => switch (dish.effectiveTier) {
        1 => AppColors.resultRed,
        2 => AppColors.resultAmber,
        _ => AppColors.resultGreen,
      };

  String get _semanticsLabel => switch (dish.effectiveTier) {
        1 => '${dish.dishText}, contains gluten',
        2 => '${dish.dishText}, uncertain — verify first',
        _ => '${dish.dishText}, no gluten detected',
      };

  @override
  Widget build(BuildContext context) {
    final isRed = dish.effectiveTier == 1;

    return Semantics(
      label: _semanticsLabel,
      child: Container(
        color: isRed
            ? AppColors.redLight.withValues(alpha: 0.6)
            : AppColors.white,
        child: Row(children: [
          // Verdict dot
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: CustomPaint(
              size: const Size(12, 12),
              painter: MenuHighlightPainter(color: _dotColor),
            ),
          ),

          // Dish text — full row tap for detail
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  dish.dishText,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight:
                        isRed ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),

          // Override checkbox
          Semantics(
            label: 'Waiter confirmed contains gluten',
            child: Checkbox(
              value: dish.manualGlutenOverride,
              onChanged: (v) => onOverrideChanged(v ?? false),
              activeColor: AppColors.resultRed,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),

          // Chevron
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 18),
          ),
        ]),
      ),
    );
  }
}

// ── _TierBadge ────────────────────────────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  final int count;
  final int tier;

  const _TierBadge({required this.count, required this.tier});

  @override
  Widget build(BuildContext context) {
    final color = tier == 1 ? AppColors.resultRed : AppColors.resultAmber;
    final bg = tier == 1 ? AppColors.redLight : AppColors.amberLight;
    final label = tier == 1 ? 'RED' : 'AMBER';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        '$count $label',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ── Shared scanner UI helpers (private to this file) ──────────────────────────

class _Corner extends StatelessWidget {
  final bool top, left;
  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(painter: _CornerPainter(top: top, left: left)),
      );
}

class _CornerPainter extends CustomPainter {
  final bool top, left;
  _CornerPainter({required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width * 0.65 : -size.width * 0.65;
    final dy = top ? size.height * 0.65 : -size.height * 0.65;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.brandBlue
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.brandBlue
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}
