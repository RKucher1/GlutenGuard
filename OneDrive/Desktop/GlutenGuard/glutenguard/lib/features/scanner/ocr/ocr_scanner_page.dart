import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/analysis/gluten_analysis_engine.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/knowledge_base/gluten_knowledge_base.dart';
import '../menu/menu_scanner_page.dart';
import 'ingredient_parser.dart';
import 'ocr_service.dart';
import 'ocr_result_page.dart';

class OcrScannerPage extends ConsumerStatefulWidget {
  const OcrScannerPage({super.key});

  @override
  ConsumerState<OcrScannerPage> createState() => _OcrScannerPageState();
}

class _OcrScannerPageState extends ConsumerState<OcrScannerPage> {
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

    // Pause viewfinder while image_picker is open
    await _controller.stop();

    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    // Restart viewfinder regardless of outcome
    await _controller.start();

    if (file == null) return; // user cancelled

    setState(() {
      _isScanning = true;
      _previewText = 'Reading ingredients…';
    });

    try {
      final inputImage = InputImage.fromFilePath(file.path);

      // Partial preview: run quick scan first so the overlay shows something
      final preview = await _ocrService.scanPreview(inputImage);
      if (mounted && preview.isNotEmpty) {
        setState(() => _previewText = preview);
      }

      final ocrResult = await _ocrService.scanIngredients(inputImage);

      if (!mounted) return;

      if (!ocrResult.hasIngredients) {
        _setError('No ingredient label detected. Try again.');
        return;
      }

      final ingredients = IngredientParser.parse(ocrResult.rawText);
      final engine = GlutenAnalysisEngine(GlutenKnowledgeBase.instance);
      final scanResult = engine.analyseProduct(ingredients: ingredients);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OcrResultPage(
            scanResult: scanResult,
            confidence: ocrResult.confidence,
          ),
        ),
      );
    } catch (e) {
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
        // ── Camera feed ──────────────────────────────────────────────────────
        MobileScanner(
          controller: _controller,
          onDetect: (_) {}, // barcode detection not used here
        ),

        // ── Header ───────────────────────────────────────────────────────────
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
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
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

        // ── Scan area with live text overlay ─────────────────────────────────
        Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 200,
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

              // Live preview text
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ]),
          ),
        ),

        // ── Mode chips ───────────────────────────────────────────────────────
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
                selected: true,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _ModeChip(
                label: 'Menu',
                selected: false,
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const MenuScannerPage()),
                ),
              ),
            ],
          ),
        ),

        // ── Scan button ──────────────────────────────────────────────────────
        Positioned(
          bottom: 64,
          left: 0,
          right: 0,
          child: Center(
            child: Semantics(
              label: 'Scan ingredient label',
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
                      : const Icon(Icons.text_fields,
                          color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
        ),

        // ── Instruction ──────────────────────────────────────────────────────
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Text(
            'Point at ingredient label · Tap to scan',
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

// ── Scan corner decorator ──────────────────────────────────────────────────────

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

// ── Mode chip ─────────────────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
