import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/setup.dart';

void main() {
  test('steps run in order and done stays put', () {
    var s = SetupStep.welcome;
    final seen = [s];
    while (s != SetupStep.done) {
      s = nextStep(s);
      seen.add(s);
    }
    expect(seen, SetupStep.values);
    expect(nextStep(SetupStep.done), SetupStep.done);
  });

  test('a restored family skips children and time (AD-7)', () {
    expect(nextStep(SetupStep.account, restored: true), SetupStep.done);
    expect(nextStep(SetupStep.pin, restored: true), SetupStep.account);
  });

  test('back goes one step back and stops at welcome', () {
    expect(backStep(SetupStep.children), SetupStep.account);
    expect(backStep(SetupStep.welcome), SetupStep.welcome);
  });

  test('parseStep reads names; null and unknown are finished', () {
    expect(parseStep('time'), SetupStep.time);
    expect(parseStep(null), isNull);
    expect(parseStep('nope'), isNull);
  });

  test('one dot per step', () {
    expect(SetupStep.values.map(dotIndex), [0, 1, 2, 3, 4, 5]);
    expect(setupDots, SetupStep.values.length);
  });
}
