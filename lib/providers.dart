import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'data/database.dart';
import 'data/pin_repository.dart';
import 'domain/clock.dart';

/// Overridden in main() and in tests.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final clockProvider = Provider<Clock>((ref) => systemClock);

final pinRepositoryProvider = Provider<PinRepository>(
  (ref) => PinRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Whether a PIN exists, and whether the parent area is unlocked.
/// The router listens to it. Unlocking lasts 5 minutes, in memory only.
class AppSession extends ChangeNotifier {
  AppSession({required this._hasPin, required this.clock});

  static const unlockFor = Duration(minutes: 5);

  final Clock clock;
  bool _hasPin;
  DateTime? _unlockedAt;

  bool get hasPin => _hasPin;

  bool get parentUnlocked =>
      _unlockedAt != null && clock().difference(_unlockedAt!) < unlockFor;

  void pinCreated() {
    _hasPin = true;
    notifyListeners();
  }

  void unlockParent() {
    _unlockedAt = clock();
    notifyListeners();
  }

  void lockParent() {
    _unlockedAt = null;
    notifyListeners();
  }
}

/// Overridden in main() and in tests with the loaded PIN state.
final appSessionProvider = Provider<AppSession>(
  (ref) => throw UnimplementedError('appSessionProvider must be overridden'),
);
