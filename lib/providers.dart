import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'data/badge_repository.dart';
import 'data/database.dart';
import 'data/pin_repository.dart';
import 'data/profile_repository.dart';
import 'data/question_bank_loader.dart';
import 'data/round_repository.dart';
import 'data/sound_player.dart';
import 'data/stats_repository.dart';
import 'data/usage_repository.dart';
import 'domain/question.dart';
import 'domain/clock.dart';
import 'domain/profile.dart';
import 'domain/progress.dart';

/// Overridden in main() and in tests.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// The bundled question bank (BNK-01), loaded once.
final bankProvider = FutureProvider<QuestionBank>(
  (ref) => loadBank(rootBundle),
);

final clockProvider = Provider<Clock>((ref) => systemClock);

final pinRepositoryProvider = Provider<PinRepository>(
  (ref) => PinRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Daily screen-time usage and limit (TIM-01..05).
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The saved child profile, or null before the parent sets one (PRO-01).
final childProfileProvider = StreamProvider<ChildProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).watch(),
);

final usageRepositoryProvider = Provider<UsageRepository>(
  (ref) => UsageRepository(ref.watch(databaseProvider)),
);

/// One per app opening, so its play session is shared by every round.
/// Sound effects with the parent's on/off switch (PRC-11).
final soundEffectsProvider = Provider<SoundEffects>((ref) {
  final usage = ref.watch(usageRepositoryProvider);
  return SoundEffects(ref.watch(soundPlayerProvider), usage.soundOn);
});

final roundRepositoryProvider = Provider<RoundRepository>(
  (ref) => RoundRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Dashboard stats and progress reset (PAR-05..10). Needs the bank.
final statsRepositoryProvider = FutureProvider<StatsRepository>(
  (ref) async => StatsRepository(
    ref.watch(databaseProvider),
    await ref.watch(bankProvider.future),
    clock: ref.watch(clockProvider),
  ),
);

/// Awards and lists badges (BDG-01..03). Needs the bank, via stats.
final badgeRepositoryProvider = FutureProvider<BadgeRepository>(
  (ref) async => BadgeRepository(
    ref.watch(databaseProvider),
    await ref.watch(statsRepositoryProvider.future),
    clock: ref.watch(clockProvider),
  ),
);

/// Earned badge ids with their dates. Auto-disposed, so SCR-02 and SCR-06
/// re-read it after every round.
final earnedBadgesProvider = FutureProvider.autoDispose<Map<String, DateTime>>(
  (ref) async => (await ref.watch(badgeRepositoryProvider.future)).earned(),
);

/// Best stars and level per topic played (PRC-07). Auto-disposed, so a
/// screen that shows it again re-reads it after every round.
final topicProgressProvider =
    FutureProvider.autoDispose<Map<String, TopicProgress>>(
      (ref) => ref.watch(roundRepositoryProvider).progress(),
    );

/// Whether a PIN exists, and whether the parent area is unlocked.
/// The router listens to it. Unlocking lasts 5 minutes, in memory only.
class AppSession extends ChangeNotifier {
  AppSession({
    required this._hasPin,
    this._profilePending = false,
    required this.clock,
  });

  static const unlockFor = Duration(minutes: 5);

  final Clock clock;
  bool _hasPin;
  bool _profilePending;
  DateTime? _unlockedAt;

  bool get hasPin => _hasPin;

  /// The child profile must be set before play (PRO-02).
  bool get profilePending => _profilePending;

  bool get parentUnlocked =>
      _unlockedAt != null && clock().difference(_unlockedAt!) < unlockFor;

  void pinCreated() {
    _hasPin = true;
    notifyListeners();
  }

  void profileSaved() {
    _profilePending = false;
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
