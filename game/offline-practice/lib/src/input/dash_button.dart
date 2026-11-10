import 'package:flutter/material.dart';

class PracticeDashButton extends StatefulWidget {
  const PracticeDashButton({
    super.key,
    required this.onDash,
    required this.resetToken,
    this.enabled = true,
  });

  final VoidCallback onDash;
  final int resetToken;
  final bool enabled;

  @override
  State<PracticeDashButton> createState() => _PracticeDashButtonState();
}

class _PracticeDashButtonState extends State<PracticeDashButton> {
  int? _owner;

  @override
  void didUpdateWidget(PracticeDashButton oldWidget) {
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
      label: 'dash_button',
      enabled: widget.enabled,
      button: true,
      excludeSemantics: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (!widget.enabled || _owner != null) return;
          setState(() => _owner = event.pointer);
          widget.onDash();
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
              ? Colors.teal
              : Colors.tealAccent,
          child: const Text('Dash', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
