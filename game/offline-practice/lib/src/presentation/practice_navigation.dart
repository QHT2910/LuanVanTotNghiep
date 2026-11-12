import 'package:flutter/material.dart';

class PracticeNavigation extends StatefulWidget {
  const PracticeNavigation({
    super.key,
    required this.onExit,
    required this.child,
  });
  final VoidCallback onExit;
  final Widget child;
  @override
  State<PracticeNavigation> createState() => _PracticeNavigationState();
}

class _PracticeNavigationState extends State<PracticeNavigation> {
  bool _exiting = false;
  void _finish() {
    if (_exiting) return;
    _exiting = true;
    widget.onExit();
  }

  void _back() {
    if (_exiting || !mounted || !Navigator.canPop(context)) return;
    _finish();
    Navigator.of(context).pop<void>();
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: true,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) _finish();
    },
    child: Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: FilledButton.tonalIcon(
              key: const ValueKey('return_menu'),
              onPressed: Navigator.canPop(context) ? _back : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Menu'),
            ),
          ),
        ),
      ],
    ),
  );
}
