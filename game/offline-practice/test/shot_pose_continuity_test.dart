import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/presentation/shot_pose_clock.dart';

void main() {
  test(
    'release keeps the last displayed sample for early, ideal and full charge',
    () {
      for (final q in [0.0, .6, 1.0]) {
        final p = ShotPoseClock()..charge();
        final displayed = p.sample(q);
        p.release();
        expect(p.sample(0), displayed);
        p.advance(0);
        expect(p.sample(0), displayed);
        p.advance(.000001);
        expect((p.sample(0) - displayed).abs(), lessThan(.00001));
        p.advance(.3);
        expect(p.active, isFalse);
        expect(p.sample(0), 2);
      }
    },
  );
}
