import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/badge_repository.dart';
import 'data/database.dart';
import 'data/pin_repository.dart';
import 'data/profile_repository.dart';
import 'data/question_bank_loader.dart';
import 'data/revision_repository.dart';
import 'data/round_repository.dart';
import 'data/sound_player.dart';
import 'data/sync/account_repository.dart';
import 'data/sync/server_client.dart';
import 'data/sync/server_config.dart';
import 'data/stats_repository.dart';
import 'data/topic_lock_repository.dart';
import 'data/usage_repository.dart';
import 'domain/question.dart';
import 'domain/clock.dart';
import 'domain/profile.dart';
import 'domain/progress.dart';
import 'domain/revision.dart';
import 'domain/topic_lock.dart';
import 'domain/topics.dart';

/// Overridden in main() and in tests.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// The bundled question bank (BNK-01), loaded once.
final bankProvider = FutureProvider<QuestionBank>(
  (ref) => loadBank(rootBundle),
);

final clockProvider = Provider<Clock>((ref) => systemClock);

/// The sync server (FEAT-12). Built with `--dart-define=SERVER_URL`; tests
/// override [serverClientProvider] with a fake.
final serverConfigProvider = Provider<ServerConfig>(
  (ref) => ServerConfig.fromEnvironment(),
);

final serverClientProvider = Provider<ServerClient>(
  (ref) => PocketBaseServerClient(ref.watch(serverConfigProvider)),
);

/// Opens and closes the browser tab for Google sign-in (FEAT-13); tests
/// override it.
class SignInBrowser {
  const SignInBrowser();

  Future<void> open(Uri url) async {
    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  }

  Future<void> close() async {
    try {
      if (await supportsCloseForLaunchMode(LaunchMode.inAppBrowserView)) {
        await closeInAppWebView();
      }
    } on Object {
      // The parent closes the tab.
    }
  }
}

final signInBrowserProvider = Provider<SignInBrowser>(
  (ref) => const SignInBrowser(),
);

/// The parent's account (FEAT-13); FEAT-14 watches it to sync.
final accountProvider = NotifierProvider<AccountRepository, AccountState>(
  () => AccountRepository(serverClientProvider),
);

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
/// Not a stream (pending drift timers in widget tests): SCR-12 invalidates
/// it after a save.
final childProfileProvider = FutureProvider.autoDispose<ChildProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).load(),
);

final usageRepositoryProvider = Provider<UsageRepository>(
  (ref) => UsageRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
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

/// The revision rules (REV-06, ADR-06). Tests and a later AI planner
/// override it.
final revisionPlannerProvider = Provider<RevisionPlanner>(
  (ref) => const RuleRevisionPlanner(),
);

final revisionRepositoryProvider = FutureProvider<RevisionRepository>(
  (ref) async => RevisionRepository(
    await ref.watch(statsRepositoryProvider.future),
    ref.watch(roundRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// What the planner works from (REV-01, REV-02), read fresh by each screen
/// that shows it; the quiz invalidates it after a round.
final revisionHistoryProvider = FutureProvider.autoDispose<RevisionHistory>(
  (ref) async => (await ref.watch(revisionRepositoryProvider.future)).history(),
);

/// Whether to offer a revision round of a scope id (REV-03): a topic id
/// on SCR-05, [mixedScopeId] on SCR-02. False until the history is read.
final revisionOffersProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, scopeId) async => ref
      .watch(revisionPlannerProvider)
      .offers(
        await ref.watch(revisionHistoryProvider.future),
        RevisionScope.fromId(scopeId),
      ),
);

/// Topics the parent opened by hand (PRC-14).
final topicLockRepositoryProvider = Provider<TopicLockRepository>(
  (ref) => TopicLockRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Lock state of every topic (PRC-12..14), worked out on each read.
/// SCR-15 invalidates it after the parent opens or locks a topic.
final topicLocksProvider = FutureProvider.autoDispose<Map<String, TopicLock>>(
  (ref) async => topicLocks(
    topics: topics,
    rounds: await ref.watch(roundRepositoryProvider).finishedRounds(),
    schoolYear: (await ref.watch(profileRepositoryProvider).load())?.schoolYear,
    opened: await ref.watch(topicLockRepositoryProvider).opened(),
  ),
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
