import 'package:flutter/material.dart';

class PracticeJumpButton extends StatefulWidget {
  const PracticeJumpButton({
    super.key,
    required this.onJump,
    required this.resetToken,
    this.enabled = true,
  });

  final VoidCallback onJump;
  final int resetToken;
  final bool enabled;

  @override
  State<PracticeJumpButton> createState() => _PracticeJumpButtonState();
}

class _PracticeJumpButtonState extends State<PracticeJumpButton> {
  int? _owner;

  @override
  void didUpdateWidget(PracticeJumpButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.resetToken != widget.resetToken) {
      _owner = null;
    }
  }

  void _end(int pointer) {
    if (!mounted || _owner != pointer) return;
    setState(() => _owner = null);
  }

  @override
  void dispose() {
    _owner = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'jump_button',
      enabled: widget.enabled,
      button: true,
      excludeSemantics: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (!widget.enabled || _owner != null) return;
          setState(() => _owner = event.pointer);
          // One edge. Keep ownership even if logic rejects the jump.
          widget.onJump();
        },
        onPointerUp: (event) => _end(event.pointer),
        onPointerCancel: (event) => _end(event.pointer),
        child: Container(
          width: 88,
          height: 64,
          alignment: Alignment.center,
          color: !widget.enabled
              ? Colors.grey
              : _owner == null
              ? Colors.indigo
              : Colors.indigoAccent,
          child: const Text('Nhảy', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
