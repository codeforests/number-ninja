import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// A PIN is exactly 4 digits (PAR-01).
bool isValidPin(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);

/// Salted, iterated SHA-256 hashing for the parent PIN (PAR-02, design §5).
class PinHasher {
  PinHasher({Random? random, this.iterations = 10000})
    : _random = random ?? Random.secure();

  final Random _random;
  final int iterations;

  /// A random 16-byte salt as hex.
  String newSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return _hex(bytes);
  }

  String hash(String pin, String salt) {
    var digest = sha256.convert(utf8.encode('$salt:$pin')).bytes;
    for (var i = 1; i < iterations; i++) {
      digest = sha256.convert([...digest, ...utf8.encode(salt)]).bytes;
    }
    return _hex(digest);
  }

  bool verify(String pin, String salt, String expectedHash) =>
      constantTimeEquals(hash(pin, salt), expectedHash);

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Compares two strings without returning early on the first difference.
bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// Wrong-PIN lockout (PAR-03): after [maxFailures] wrong entries in a row,
/// PIN entry is blocked for [lockDuration].
class PinLockoutPolicy {
  const PinLockoutPolicy({
    this.maxFailures = 5,
    this.lockDuration = const Duration(seconds: 60),
  });

  final int maxFailures;
  final Duration lockDuration;

  bool isLocked(DateTime? lockedUntil, DateTime now) =>
      lockedUntil != null && now.isBefore(lockedUntil);

  /// The state after one more wrong PIN at [now].
  LockoutState afterFailure(int failedCount, DateTime now) {
    final count = failedCount + 1;
    if (count >= maxFailures) {
      return LockoutState(failedCount: 0, lockedUntil: now.add(lockDuration));
    }
    return LockoutState(failedCount: count, lockedUntil: null);
  }

  int attemptsLeft(int failedCount) => maxFailures - failedCount;
}

class LockoutState {
  const LockoutState({required this.failedCount, required this.lockedUntil});

  final int failedCount;
  final DateTime? lockedUntil;
}
