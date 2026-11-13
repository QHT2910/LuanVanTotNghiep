import 'dart:math' as math;

import 'package:flutter/material.dart';

bool _finite(Offset p) => p.dx.isFinite && p.dy.isFinite;

// Stable even for very large finite coordinates.
Offset clampJoystickUnit(Offset p) {
  if (!_finite(p)) return Offset.zero;
  final scale = math.max(p.dx.abs(), p.dy.abs());
  if (scale == 0) return Offset.zero;
  final scaled = p / scale;
  final length = math.sqrt(scaled.dx * scaled.dx + scaled.dy * scaled.dy);
  if (scale <= 1 / length) return p;
  return scaled / length;
}

void _checkDeadZone(double value) {
  if (!value.isFinite || value < 0 || value >= 1) {
    throw ArgumentError.value(value, 'deadZone', 'Must be in [0, 1)');
  }
}

Offset radialJoystickAxis(Offset normalized, {double deadZone = 0.15}) {
  _checkDeadZone(deadZone);
  final bounded = clampJoystickUnit(normalized);
  final radius = bounded.distance;
  if (radius <= deadZone) return Offset.zero;
  final magnitude = (radius - deadZone) / (1 - deadZone);
  return bounded * (magnitude / radius);
}

// Pure input model: no Widget, Scene, timer, camera or GPU.
class JoystickInput {
  JoystickInput({this.deadZone = 0.15}) {
    _checkDeadZone(deadZone);
  }

  final double deadZone;
  int? _owner;
  Offset _knob = Offset.zero;
  Offset _axis = Offset.zero;

  int? get owner => _owner;
  Offset get knob => _knob;
  Offset get axis => _axis;

  bool down(int pointer, Offset normalized) {
    if (_owner != null || !_finite(normalized)) return false;
    _owner = pointer;
    _apply(normalized);
    return true;
  }

  bool move(int pointer, Offset normalized) {
    if (_owner != pointer) return false;
    _apply(normalized); // A non-finite owner sample becomes neutral.
    return true;
  }

  bool end(int pointer) {
    if (_owner != pointer) return false;
    reset();
    return true;
  }

  void reset() {
    _owner = null;
    _knob = Offset.zero;
    _axis = Offset.zero;
  }

  void _apply(Offset normalized) {
    _knob = clampJoystickUnit(normalized);
    _axis = radialJoystickAxis(_knob, deadZone: deadZone);
  }
}

class PracticeJoystick extends StatefulWidget {
  const PracticeJoystick({
    super.key,
    required this.onChanged,
    required this.resetToken,
    this.enabled = true,
    this.deadZone = 0.15,
    this.hitSize = 152,
    this.radius = 64,
    this.thumbRadius = 20,
    this.backgroundColor,
    this.thumbColor,
    this.visualThumbRadius,
  });

  final ValueChanged<Offset> onChanged;
  final int resetToken;
  final bool enabled;
  final double deadZone;
  final double hitSize;
  final double radius;
  final double thumbRadius;
  final Color? backgroundColor, thumbColor;
  final double? visualThumbRadius;

  @override
  State<PracticeJoystick> createState() => _PracticeJoystickState();
}

class _PracticeJoystickState extends State<PracticeJoystick> {
  late JoystickInput _input;
  int _revision = 0;

  void _validate() {
    _checkDeadZone(widget.deadZone);
    final visualRadius = widget.visualThumbRadius ?? widget.thumbRadius;
    final values = [
      widget.hitSize,
      widget.radius,
      widget.thumbRadius,
      visualRadius,
    ];
    if (values.any((v) => !v.isFinite) ||
        widget.thumbRadius <= 0 ||
        widget.radius <= widget.thumbRadius ||
        visualRadius <= 0 ||
        visualRadius >= widget.radius ||
        widget.hitSize < widget.radius * 2) {
      throw ArgumentError('Invalid joystick geometry');
    }
  }

  @override
  void initState() {
    super.initState();
    _validate();
    _input = JoystickInput(deadZone: widget.deadZone);
  }

  @override
  void didUpdateWidget(PracticeJoystick oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validate();
    if (oldWidget.resetToken != widget.resetToken ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.deadZone != widget.deadZone ||
        oldWidget.hitSize != widget.hitSize ||
        oldWidget.radius != widget.radius ||
        oldWidget.thumbRadius != widget.thumbRadius) {
      _input.reset();
      _input = JoystickInput(deadZone: widget.deadZone);
      final revision = ++_revision;
      // didUpdateWidget is already followed by build: no setState here.
      // Notify after this frame; never update a parent during its build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || revision != _revision) return;
        widget.onChanged(Offset.zero);
      });
    }
  }

  Offset _normalized(Offset position) {
    final center = Offset(widget.hitSize / 2, widget.hitSize / 2);
    final travel = widget.radius - widget.thumbRadius;
    return (position - center) / travel;
  }

  void _changed() {
    ++_revision; // Invalidates an older deferred-neutral notification.
    setState(() {});
    widget.onChanged(_input.axis);
  }

  @override
  void dispose() {
    ++_revision;
    _input.reset();
    // No callback while disposing: parent must neutralize before removal.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.hitSize / 2;
    final thumbRadius = widget.visualThumbRadius ?? widget.thumbRadius;
    final travel = widget.radius - thumbRadius;
    final knob = _input.knob * travel;
    return Semantics(
      label: 'move_joystick',
      enabled: widget.enabled,
      excludeSemantics: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (!widget.enabled) return;
          if (_input.down(event.pointer, _normalized(event.localPosition))) {
            _changed();
          }
        },
        onPointerMove: (event) {
          if (!widget.enabled) return;
          if (_input.move(event.pointer, _normalized(event.localPosition))) {
            _changed();
          }
        },
        onPointerUp: (event) {
          if (_input.end(event.pointer)) _changed();
        },
        onPointerCancel: (event) {
          if (_input.end(event.pointer)) _changed();
        },
        child: SizedBox.square(
          dimension: widget.hitSize,
          child: Stack(
            children: [
              Positioned(
                left: center - widget.radius,
                top: center - widget.radius,
                child: Container(
                  width: widget.radius * 2,
                  height: widget.radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.enabled
                        ? widget.backgroundColor ?? Colors.blueGrey.shade700
                        : Colors.grey.shade700,
                    border: Border.all(color: Colors.white70),
                  ),
                ),
              ),
              Positioned(
                left: center - travel * widget.deadZone,
                top: center - travel * widget.deadZone,
                child: IgnorePointer(
                  child: Container(
                    width: travel * widget.deadZone * 2,
                    height: travel * widget.deadZone * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: center + knob.dx - thumbRadius,
                top: center + knob.dy - thumbRadius,
                child: IgnorePointer(
                  child: Container(
                    key: const ValueKey('joystick_thumb'),
                    width: thumbRadius * 2,
                    height: thumbRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.thumbColor ?? Colors.lightBlueAccent,
                    ),
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
