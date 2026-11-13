import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/presentation/practice_hud.dart';
import 'package:offline_practice/src/input/joystick.dart';
import 'package:offline_practice/src/input/jump_button.dart';
import 'package:offline_practice/src/input/dash_button.dart';

PracticeHudData sample({
  double charge = 0,
  double target = 0.6,
  String dash = 'ready',
}) =>
    (score: 7, round: 3, points: 2, charge: charge, target: target, dash: dash);
Widget fixture(ValueNotifier<PracticeHudData> data, {Widget? stick}) =>
    MaterialApp(
      home: Scaffold(
        body: OfflinePracticeHud(
          data: data,
          joystick:
              stick ??
              const SizedBox(key: ValueKey('stick'), width: 152, height: 152),
          jump: PracticeJumpButton(
            key: const ValueKey('jump'),
            size: practiceActionSize,
            resetToken: 0,
            onJump: () {},
          ),
          dash: PracticeDashButton(
            key: const ValueKey('dash'),
            size: practiceActionSize,
            resetToken: 0,
            onDash: () {},
          ),
          shoot: SizedBox(
            key: const ValueKey('shoot'),
            width: practiceShootSize.width,
            height: practiceShootSize.height,
          ),
          reset: const SizedBox(key: ValueKey('reset'), width: 88, height: 48),
        ),
      ),
    );

void main() {
  testWidgets('Landscape input bounds fit without overlap', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final data = ValueNotifier<PracticeHudData>(sample());
    addTearDown(data.dispose);
    for (final size in [const Size(724, 280), const Size(960, 540)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(fixture(data));
      final boxes = [
        for (final id in ['stick', 'jump', 'dash', 'shoot', 'reset'])
          tester.getRect(find.byKey(ValueKey(id))),
      ];
      for (final rect in boxes) {
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(size.width));
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.bottom, lessThanOrEqualTo(size.height));
        expect(rect.height, greaterThanOrEqualTo(48));
      }
      for (var a = 0; a < boxes.length; a++) {
        for (var b = a + 1; b < boxes.length; b++) {
          expect(boxes[a].overlaps(boxes[b]), isFalse);
        }
      }
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
    'Typed score, configurable charge target and independent cooldown',
    (tester) async {
      final data = ValueNotifier<PracticeHudData>(sample());
      addTearDown(data.dispose);
      await tester.pumpWidget(fixture(data));
      expect(find.text('OFFLINE  7 điểm  ·  Lượt 3  ·  2đ'), findsOneWidget);
      final actionRects = {
        for (final id in ['jump', 'dash', 'shoot'])
          id: tester.getRect(find.byKey(ValueKey(id))),
      };
      data.value = sample(charge: 0.4, target: 0.7, dash: 'cooldown');
      await tester.pump();
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byKey(const ValueKey('shot_charge')),
            )
            .value,
        0.4,
      );
      expect(find.text('Mục tiêu 70%'), findsOneWidget);
      expect(find.text('Hồi chiêu'), findsOneWidget);
      for (final id in actionRects.keys) {
        expect(tester.getRect(find.byKey(ValueKey(id))), actionRects[id]);
      }
      data.value = sample(charge: 0.4, target: 0.7, dash: 'dashing');
      await tester.pump();
      for (final id in actionRects.keys) {
        expect(tester.getRect(find.byKey(ValueKey(id))), actionRects[id]);
      }
      expect(find.textContaining('03:00'), findsNothing);
      final marker = tester.getRect(
            find.byKey(const ValueKey('charge_target')),
          ),
          bar = tester.getRect(find.byKey(const ValueKey('shot_charge')));
      expect(marker.center.dx - bar.left, closeTo(bar.width * 0.7, 0.01));
    },
  );
  testWidgets('Charge updates retain held joystick state and release', (
    tester,
  ) async {
    final data = ValueNotifier<PracticeHudData>(sample());
    addTearDown(data.dispose);
    var axis = Offset.zero;
    await tester.pumpWidget(
      fixture(
        data,
        stick: PracticeJoystick(
          key: const ValueKey('stick'),
          resetToken: 0,
          visualThumbRadius: 27,
          onChanged: (v) => axis = v,
        ),
      ),
    );
    final center = tester.getCenter(find.byKey(const ValueKey('stick')));
    final finger = await tester.startGesture(
      center + const Offset(22, 0),
      pointer: 71,
    );
    final state = tester.state(find.byType(PracticeJoystick));
    expect(axis.dx, closeTo((0.5 - 0.15) / 0.85, 1e-9));
    data.value = sample(charge: 0.8, dash: 'cooldown');
    await tester.pump();
    expect(
      identical(state, tester.state(find.byType(PracticeJoystick))),
      isTrue,
    );
    expect(axis.dx, greaterThan(0));
    await finger.up();
    expect(axis, Offset.zero);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
