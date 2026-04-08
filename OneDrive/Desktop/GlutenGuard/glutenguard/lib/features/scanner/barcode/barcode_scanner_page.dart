import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../product_lookup/product_lookup_provider.dart';
import '../../results/result_page.dart';
import '../ocr/ocr_scanner_page.dart';

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<BarcodeScannerPage> createState() =>
      _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  MobileScannerController? _controller;
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    setState(() => _scanning = false);
    HapticFeedback.mediumImpact();

    await ref.read(productLookupProvider.notifier).lookupBarcode(barcode);

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ResultPage()),
    );

    // Resume scanning after returning
    setState(() => _scanning = true);
    ref.read(productLookupProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final lookupState = ref.watch(productLookupProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Camera viewfinder
        MobileScanner(
          controller: _controller!,
          onDetect: _onDetect,
        ),

        // Header bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                    child: const Icon(Icons.eco,
                        color: Colors.white, size: 16),
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
                IconButton(
                  icon: Icon(
                    _controller?.torchEnabled == true
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: () => _controller?.toggleTorch(),
                ),
              ],
            ),
          ),
        ),

        // Scan frame
        Center(child: _ScanFrame()),

        // Mode chips
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ModeChip(
                label: 'Barcode',
                selected: true,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _ModeChip(
                label: 'Ingredients',
                selected: false,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OcrScannerPage(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Loading overlay
        if (lookupState.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.65),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: AppColors.brandBlue, strokeWidth: 2),
                  SizedBox(height: 14),
                  Text(
                    'Checking ingredients...',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

        // Instruction
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Text(
            'Point at barcode · Hold steady',
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

class _ScanFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.brandBlue.withValues(alpha: 0.6),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Stack(children: [
        Positioned(
            top: -1, left: -1, child: _Corner(top: true, left: true)),
        Positioned(
            top: -1, right: -1, child: _Corner(top: true, left: false)),
        Positioned(
            bottom: -1,
            left: -1,
            child: _Corner(top: false, left: true)),
        Positioned(
            bottom: -1,
            right: -1,
            child: _Corner(top: false, left: false)),
      ]),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top, left;
  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 20,
        height: 20,
        child:
            CustomPaint(painter: _CornerPainter(top: top, left: left)),
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
  final VoidCallback onTap;
  const _ModeChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
}
