import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/pin.dart';

void main() {
  group('isValidPin', () {
    test('accepts exactly four digits', () {
      expect(isValidPin('0000'), isTrue);
      expect(isValidPin('1234'), isTrue);
    });
    test('rejects other lengths and non-digits', () {
      for (final bad in ['', '123', '12345', '12a4', ' 123', '١٢٣٤']) {
        expect(isValidPin(bad), isFalse, reason: bad);
      }
    });
  });

  group('PinHasher', () {
    final hasher = PinHasher(random: Random(1), iterations: 50);

    test('hash never contains the PIN and verifies only the right PIN', () {
      final salt = hasher.newSalt();
      final hash = hasher.hash('2468', salt);
      expect(hash, isNot(contains('2468')));
      expect(hash, hasLength(64));
      expect(hasher.verify('2468', salt, hash), isTrue);
      expect(hasher.verify('2469', salt, hash), isFalse);
    });

    test('salts are 16 random bytes and differ between calls', () {
      final a = hasher.newSalt();
      final b = hasher.newSalt();
      expect(a, hasLength(32));
      expect(a, isNot(b));
      expect(hasher.hash('1111', a), isNot(hasher.hash('1111', b)));
    });

    test('default uses 10,000 iterations', () {
      expect(PinHasher().iterations, 10000);
    });
  });

  test('constantTimeEquals', () {
    expect(constantTimeEquals('abc', 'abc'), isTrue);
    expect(constantTimeEquals('abc', 'abd'), isFalse);
    expect(constantTimeEquals('abc', 'ab'), isFalse);
  });

  group('PinLockoutPolicy', () {
    const policy = PinLockoutPolicy();
    final t0 = DateTime(2027, 1, 5, 9);

    test('counts failures and locks on the fifth for 60 s', () {
      var state = const LockoutState(failedCount: 0, lockedUntil: null);
      for (var i = 1; i <= 4; i++) {
        state = policy.afterFailure(state.failedCount, t0);
        expect(state.failedCount, i);
        expect(state.lockedUntil, isNull);
        expect(policy.attemptsLeft(state.failedCount), 5 - i);
      }
      state = policy.afterFailure(state.failedCount, t0);
      expect(state.lockedUntil, t0.add(const Duration(seconds: 60)));
      expect(state.failedCount, 0);
    });

    test('is locked until exactly 60 s later', () {
      final until = t0.add(const Duration(seconds: 60));
      expect(policy.isLocked(until, t0), isTrue);
      expect(
        policy.isLocked(until, t0.add(const Duration(seconds: 59))),
        isTrue,
      );
      expect(policy.isLocked(until, until), isFalse);
      expect(policy.isLocked(null, t0), isFalse);
    });
  });
}
