import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/input/joystick.dart';

void expectAxis(Offset actual, Offset expected) {
  expect(actual.dx, closeTo(expected.dx, 1e-9));
  expect(actual.dy, closeTo(expected.dy, 1e-9));
}

void main() {
  test('Radial dead zone includes the exact boundary', () {
    expectAxis(radialJoystickAxis(Offset.zero), Offset.zero);
    expectAxis(radialJoystickAxis(const Offset(0.14, 0)), Offset.zero);
    expectAxis(radialJoystickAxis(const Offset(0.15, 0)), Offset.zero);
    expect(radialJoystickAxis(const Offset(0.1501, 0)).dx, greaterThan(0));
    expectAxis(
      radialJoystickAxis(const Offset(0.575, 0)),
      const Offset(0.5, 0),
    );
  });

  test('Radius one, outside clamp and diagonal keep a unit magnitude', () {
    expectAxis(radialJoystickAxis(const Offset(1, 0)), const Offset(1, 0));
    expectAxis(radialJoystickAxis(const Offset(20, 0)), const Offset(1, 0));
    final diagonal = radialJoystickAxis(const Offset(1, 1));
    expect(diagonal.distance, closeTo(1, 1e-9));
    expect(diagonal.dx, closeTo(1 / math.sqrt(2), 1e-9));
    expect(diagonal.dy, closeTo(1 / math.sqrt(2), 1e-9));
    expect(
      clampJoystickUnit(const Offset(1e308, 1e308)).distance,
      closeTo(1, 1e-9),
    );
  });

  test('Owner ignores other down/move/up/cancel; release is neutral', () {
    final input = JoystickInput();
    expect(input.down(1, const Offset(0.8, 0)), isTrue);
    final axis = input.axis;
    expect(input.down(2, const Offset(-1, 0)), isFalse);
    expect(input.move(2, const Offset(-1, 0)), isFalse);
    expect(input.end(2), isFalse);
    expectAxis(input.axis, axis);
    expect(input.end(1), isTrue);
    expect(input.owner, isNull);
    expectAxis(input.axis, Offset.zero);
    expectAxis(input.knob, Offset.zero);
    expect(input.move(2, const Offset(-1, 0)), isFalse);
    expect(input.down(2, const Offset(-1, 0)), isTrue);
    expect(input.end(2), isTrue); // Same path as pointer cancel.
    expectAxis(input.axis, Offset.zero);
  });

  test('Non-finite input is safe, reset invalidates an old owner', () {
    final input = JoystickInput();
    expect(input.down(1, const Offset(double.nan, 0)), isFalse);
    expect(input.owner, isNull);
    expect(input.down(1, const Offset(1, 0)), isTrue);
    expect(input.move(1, const Offset(double.infinity, 0)), isTrue);
    expectAxis(input.axis, Offset.zero);
    expectAxis(input.knob, Offset.zero);
    input.move(1, const Offset(0.7, 0));
    input.reset();
    expect(input.move(1, const Offset(1, 0)), isFalse);
    expect(input.end(1), isFalse);
    expectAxis(input.axis, Offset.zero);
    expect(() => JoystickInput(deadZone: 1), throwsArgumentError);
    expect(() => JoystickInput(deadZone: double.nan), throwsArgumentError);
  });

  testWidgets('Widget ignores a second pointer on stick; cancel centers knob', (
    tester,
  ) async {
    var axis = Offset.zero;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PracticeJoystick(
            key: const ValueKey('stick'),
            resetToken: 0,
            onChanged: (value) => axis = value,
          ),
        ),
      ),
    );
    final center = tester.getCenter(find.byKey(const ValueKey('stick')));
    final first = await tester.startGesture(
      center + const Offset(22, 0),
      pointer: 11,
    );
    await tester.pump();
    expect(axis.dx, closeTo((0.5 - 0.15) / 0.85, 1e-9));
    expect(
      tester.getCenter(find.byKey(const ValueKey('joystick_thumb'))),
      center + const Offset(22, 0),
    );

    final second = await tester.startGesture(center, pointer: 12);
    await second.moveTo(center - const Offset(40, 0));
    await second.up();
    await tester.pump();
    expect(axis.dx, closeTo((0.5 - 0.15) / 0.85, 1e-9));

    await first.cancel();
    await tester.pump();
    expectAxis(axis, Offset.zero);
    expect(
      tester.getCenter(find.byKey(const ValueKey('joystick_thumb'))),
      center,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
