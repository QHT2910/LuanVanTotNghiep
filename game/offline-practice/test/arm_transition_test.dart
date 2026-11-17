import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scene/scene.dart' as fs;
import 'package:vector_math/vector_math.dart' as vm;
import 'package:offline_practice/src/presentation/arm_transition.dart';
import 'package:offline_practice/src/presentation/layered_pose.dart';

void main() {
  test('transition start, midpoint, pause, endpoint and invalid delta', () {
    final t = ArmTransition()..begin();
    expect(t.alpha, 0);
    t.advance(0);
    expect(t.alpha, 0);
    t.advance(.06);
    expect(t.alpha, closeTo(.5, 1e-12));
    t.advance(.06);
    expect(t.alpha, 1);
    expect(t.active, isFalse);
    t.reset();
    expect(t.alpha, 1);
    expect(() => t.advance(double.nan), throwsArgumentError);
    expect(() => t.advance(-.1), throwsArgumentError);
  });
  test('interrupt interpolation begins at submitted rotation', () {
    final q = vm.Quaternion.identity();
    final target = vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), 1);
    final shown = fs.QuaternionSlerp(q).slerp(target, .37);
    final next = vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), .8);
    final start = fs.QuaternionSlerp(shown).slerp(next, 0);
    for (var i = 0; i < 4; i++)
      expect(start.storage[i], closeTo(shown.storage[i], 1e-6));
    final end = fs.QuaternionSlerp(shown).slerp(next, 1);
    expect(fs.QuaternionSlerp(end).dot(next).abs(), closeTo(1, 1e-6));
  });
  test(
    'public TRS copy preserves authored negative-scale axis and independence',
    () {
      final source = fs.Node(name: 'source')
        ..position = vm.Vector3(1, 2, 3)
        ..rotation = vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), .6)
        ..scale = vm.Vector3(1, -2, 3);
      final copy = fs.Node(name: 'copy');
      copyJointPose(source, copy);
      expect(copy.scale.storage.toList(), [1, -2, 3]);
      for (var i = 0; i < 16; i++)
        expect(
          copy.localTransform.storage[i],
          closeTo(source.localTransform.storage[i], 1e-6),
        );
      copy.position = vm.Vector3.zero();
      expect(source.position.x, 1);
    },
  );
}
