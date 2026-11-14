import 'package:drift/drift.dart';

import '../domain/clock.dart';
import '../domain/pin.dart';
import 'database.dart';

sealed class PinResult {
  const PinResult();
}

class PinOk extends PinResult {
  const PinOk();
}

class PinWrong extends PinResult {
  const PinWrong(this.attemptsLeft);
  final int attemptsLeft;
}

class PinLocked extends PinResult {
  const PinLocked(this.until);
  final DateTime until;
}

/// Stores and checks the parent PIN (PAR-01..04). The lockout lives in the
/// database so restarting the app does not reset it (AC-3).
class PinRepository {
  PinRepository(
    this._db, {
    required this.clock,
    PinHasher? hasher,
    this.policy = const PinLockoutPolicy(),
  }) : _hasher = hasher ?? PinHasher();

  final AppDatabase _db;
  final Clock clock;
  final PinHasher _hasher;
  final PinLockoutPolicy policy;

  Future<AppSetting> _settings() =>
      (_db.select(_db.appSettings)..where((s) => s.id.equals(1))).getSingle();

  Future<PinLockoutData> _lockout() =>
      (_db.select(_db.pinLockout)..where((l) => l.id.equals(1))).getSingle();

  Future<bool> hasPin() async => (await _settings()).pinHash != null;

  Future<void> setPin(String pin) async {
    if (!isValidPin(pin)) throw ArgumentError('PIN must be 4 digits');
    final salt = _hasher.newSalt();
    await (_db.update(_db.appSettings)..where((s) => s.id.equals(1))).write(
      AppSettingsCompanion(
        pinHash: Value(_hasher.hash(pin, salt)),
        pinSalt: Value(salt),
      ),
    );
    await _writeLockout(0, null);
  }

  /// When PIN entry is blocked, the time it opens again; otherwise null.
  Future<DateTime?> lockedUntil() async {
    final l = await _lockout();
    return policy.isLocked(l.lockedUntil, clock()) ? l.lockedUntil : null;
  }

  Future<PinResult> verify(String pin) async {
    final now = clock();
    final lock = await _lockout();
    if (policy.isLocked(lock.lockedUntil, now)) {
      return PinLocked(lock.lockedUntil!);
    }
    final s = await _settings();
    if (s.pinHash == null || s.pinSalt == null) {
      throw StateError('No PIN has been set');
    }
    if (_hasher.verify(pin, s.pinSalt!, s.pinHash!)) {
      await _writeLockout(0, null);
      return const PinOk();
    }
    final next = policy.afterFailure(lock.failedCount, now);
    await _writeLockout(next.failedCount, next.lockedUntil);
    if (next.lockedUntil != null) return PinLocked(next.lockedUntil!);
    return PinWrong(policy.attemptsLeft(next.failedCount));
  }

  /// Changes the PIN when [current] is right (PAR-04).
  Future<PinResult> changePin(String current, String next) async {
    if (!isValidPin(next)) throw ArgumentError('PIN must be 4 digits');
    final result = await verify(current);
    if (result is PinOk) await setPin(next);
    return result;
  }

  Future<void> _writeLockout(int failedCount, DateTime? until) =>
      (_db.update(_db.pinLockout)..where((l) => l.id.equals(1))).write(
        PinLockoutCompanion(
          failedCount: Value(failedCount),
          lockedUntil: Value(until),
        ),
      );
}
