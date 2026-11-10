import 'package:flutter_test/flutter_test.dart';
import 'package:offline_practice/src/simulation/config.dart';

void main() {
  test('Non-finite launch settings are rejected before rendering', () {
    expect(() => const PracticeConfig(gravity: double.nan).validate(),
        throwsArgumentError);
  });
}
