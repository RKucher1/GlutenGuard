import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// In-screen save confirmation toast with an Undo action.
///
/// Auto-dismisses after [duration]. Calls [onDismissed] when it disappears
/// (either by timer or by parent rebuilding with visible=false).
/// Calls [onUndo] when the Undo button is tapped.
class QuickSaveToast extends StatefulWidget {
  final VoidCallback? onUndo;
  final VoidCallback onDismissed;
  final Duration duration;

  const QuickSaveToast({
    super.key,
    this.onUndo,
    required this.onDismissed,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<QuickSaveToast> createState() => _QuickSaveToastState();
}

class _QuickSaveToastState extends State<QuickSaveToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOut),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    _anim.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _anim.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.brandNavy,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.resultGreen, size: 18),
                SizedBox(width: 8),
                Text(
                  'Saved to safe list',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
              TextButton(
                onPressed: () {
                  _timer?.cancel();
                  widget.onUndo?.call();
                  _dismiss();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 32),
                ),
                child: const Text(
                  'Undo',
                  style: TextStyle(
                    color: AppColors.brandBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
