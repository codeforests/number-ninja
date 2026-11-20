import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/badge_repository.dart';
import 'data/bank_store.dart';
import 'data/bank_updater.dart';
import 'data/child_repository.dart';
import 'data/crash_reporter.dart';
import 'data/crash_repository.dart';
import 'data/database.dart';
import 'data/pin_repository.dart';
import 'data/profile_repository.dart';
import 'data/revision_repository.dart';
import 'data/round_repository.dart';
import 'data/setup_repository.dart';
import 'data/sound_player.dart';
import 'data/sync/account_repository.dart';
import 'data/sync/server_client.dart';
import 'data/sync/server_config.dart';
import 'data/sync/sync_controller.dart';
import 'data/sync/sync_service.dart';
import 'data/stats_repository.dart';
import 'data/topic_lock_repository.dart';
import 'data/usage_repository.dart';
import 'domain/question.dart';
import 'domain/clock.dart';
import 'domain/family.dart';
import 'domain/profile.dart';
import 'domain/progress.dart';
import 'domain/revision.dart';
import 'domain/setup.dart';
import 'domain/topic_lock.dart';
import 'domain/topics.dart';

/// Overridden in main() and in tests.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Downloaded banks and the bundled fallback (FEAT-15 D8); tests override.
final bankStoreProvider = Provider<BankStore>(
  (ref) => BankStore(
    ref.watch(databaseProvider),
    bundle: rootBundle,
    dir: () async =>
        Directory('${(await getApplicationSupportDirectory()).path}/banks'),
  ),
);

/// The bank in use: the newest good download, else the bundled one
/// (BNK-09). Re-read only at launch and when [BankPending.apply] or
/// "Check now" invalidates it, never during a round.
final activeBankProvider = FutureProvider<ActiveBank>(
  (ref) => ref.watch(bankStoreProvider).loadActive(),
);

/// The question bank rounds are built from (BNK-01, FEAT-15).
final bankProvider = FutureProvider<QuestionBank>(
  (ref) async => (await ref.watch(activeBankProvider.future)).bank,
);

/// Checks the server for a newer bank (FEAT-15 D9).
final bankUpdaterProvider = Provider<BankUpdater>(
  (ref) => BankUpdater(
    client: ref.watch(serverClientProvider),
    store: ref.watch(bankStoreProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// True while a downloaded bank waits for the next round (BNK-09).
class BankPending extends Notifier<bool> {
  @override
  bool build() => false;

  void set() => state = true;

  /// Switches to the downloaded bank if one waits; called before a round
  /// is built, so a round never changes bank halfway.
  void apply() {
    if (!state) return;
    state = false;
    ref.invalidate(activeBankProvider);
  }
}

final bankPendingProvider = NotifierProvider<BankPending, bool>(
  BankPending.new,
);

/// Version, source and last check for SCR-11 (BNK-12).
final bankStatusProvider = FutureProvider<(ActiveBank, BankCheckState)>(
  (ref) async => (
    await ref.watch(activeBankProvider.future),
    await ref.watch(bankStoreProvider).checkState(),
  ),
);

/// Runs a bank check (launch, resume, "Check now"). A download waits for
/// the next round, unless [now] (the parent area, where no round runs).
Future<BankCheck> checkBank(Ref ref, {bool force = false, bool now = false}) {
  return ref.read(bankUpdaterProvider).check(force: force).then((r) {
    if (r == BankCheck.skipped) return r;
    if (r == BankCheck.downloaded) {
      if (now) {
        ref.invalidate(activeBankProvider);
      } else {
        ref.read(bankPendingProvider.notifier).set();
      }
    }
    ref.invalidate(bankStatusProvider);
    return r;
  });
}

/// Starts [checkBank] from a widget.
final bankCheckProvider =
    Provider<Future<BankCheck> Function({bool force, bool now})>(
      (ref) =>
          ({bool force = false, bool now = false}) =>
              checkBank(ref, force: force, now: now),
    );

final clockProvider = Provider<Clock>((ref) => systemClock);

/// Crash reports (FEAT-24). `main()` overrides the reporter with the one it
/// installed; tests make their own.
final crashReporterProvider = Provider<CrashReporter>(
  (ref) => CrashReporter(clock: ref.watch(clockProvider)),
);

final crashRepositoryProvider = Provider<CrashRepository>(
  (ref) => CrashRepository(ref.watch(databaseProvider)),
);

/// Names and email to scrub and the bank in use, read when an error is saved
/// (AD-7).
final crashContextProvider = Provider<Future<CrashContext> Function()>(
  (ref) => () async {
    final names = [
      for (final c in await ref.read(childRepositoryProvider).all()) c.nickname,
    ];
    var bank = 0;
    try {
      bank = (await ref.read(bankProvider.future)).version;
    } on Object {
      // The bank itself may be what failed.
    }
    return CrashContext(
      names: names,
      email: ref.read(accountProvider).account?.email,
      bankVersion: bank,
    );
  },
);

/// Sends unsent crash reports (AD-9): at launch and on resume.
final crashSendProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => ref
          .read(crashReporterProvider)
          .sendPending(ref.read(serverClientProvider)),
);

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

  /// Android hands the `brainbubblz://signin/...` link to this channel
  /// (`SignInReturnActivity`).
  static const _channel = MethodChannel('brainbubblz/sign_in');

  /// Opens [url] in a Custom Tab and completes with the link Google's sign-in
  /// sends back into the app. The caller's timeout ends a sign-in the parent
  /// abandons.
  Future<Uri> open(Uri url) async {
    final back = Completer<Uri>();
    _channel.setMethodCallHandler((call) async {
      final link = call.arguments;
      if (call.method == 'returned' && link is String && !back.isCompleted) {
        back.complete(Uri.parse(link));
      }
    });
    await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    return back.future;
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

/// The account id to sync for: signed in with a server set, else null.
final syncAccountProvider = Provider<String?>(
  (ref) => ref.watch(serverConfigProvider).isConfigured
      ? ref.watch(accountProvider.select((s) => s.account?.id))
      : null,
);

final syncTimersProvider = Provider<SyncTimers>(
  (ref) => const RealSyncTimers(),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    db: ref.watch(databaseProvider),
    client: ref.watch(serverClientProvider),
    clock: ref.watch(clockProvider),
    forgetSession: ref.watch(roundRepositoryProvider).forgetSession,
  ),
);

/// Bumped when a sync changed local data; data providers below watch it.
final syncDataVersionProvider = NotifierProvider<SyncDataVersion, int>(
  SyncDataVersion.new,
);

/// Progress sync (FEAT-14, SYN-01..07). `app.dart` keeps it alive.
final syncProvider = NotifierProvider<SyncController, SyncStatus>(
  () => SyncController(
    account: syncAccountProvider,
    service: syncServiceProvider,
    timers: syncTimersProvider,
    dataVersion: syncDataVersionProvider,
    onExpired: (ref) =>
        unawaited(ref.read(accountProvider.notifier).sessionExpired()),
  ),
);

/// The family's children (FEAT-25).
final childRepositoryProvider = Provider<ChildRepository>(
  (ref) => ChildRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The children in the order they were added (FEAT-25). Not a stream (see
/// [childProfileProvider]); invalidate after a change.
final childrenProvider = FutureProvider.autoDispose<List<FamilyChild>>((ref) {
  ref.watch(syncDataVersionProvider);
  return ref.watch(childRepositoryProvider).all();
});

/// The child playing now (FEAT-25 AD-3): every per-child repository
/// provider watches it, so changing it reloads her data.
class CurrentChild extends Notifier<int> {
  @override
  int build() {
    // A sync may remove the current child (FEAT-25 AD-10): follow
    // ChildRepository.current then.
    ref.listen(syncDataVersionProvider, (_, _) async {
      final now = await ref.read(childRepositoryProvider).current();
      if (ref.mounted && now != state) state = now;
    });
    return ref.read(startChildProvider);
  }

  /// Makes [id] the child playing now and saves it for the next launch.
  Future<void> select(int id) async {
    await ref.read(childRepositoryProvider).setCurrent(id);
    state = id;
  }
}

/// The child playing at launch (FEAT-25 AD-3), loaded in main();
/// [currentChildProvider] holds the current one after that.
final startChildProvider = Provider<int>((ref) => 1);

final currentChildProvider = NotifierProvider<CurrentChild, int>(
  CurrentChild.new,
);

final setupRepositoryProvider = Provider<SetupRepository>(
  (ref) => SetupRepository(ref.watch(databaseProvider)),
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
    childId: ref.watch(currentChildProvider),
  ),
);

/// The saved child profile, or null before the parent sets one (PRO-01).
/// Not a stream (pending drift timers in widget tests): SCR-12 invalidates
/// it after a save.
final childProfileProvider = FutureProvider.autoDispose<ChildProfile?>((ref) {
  ref.watch(syncDataVersionProvider);
  return ref.watch(profileRepositoryProvider).load();
});

final usageRepositoryProvider = Provider<UsageRepository>(
  (ref) => UsageRepository(
    ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    childId: ref.watch(currentChildProvider),
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
    childId: ref.watch(currentChildProvider),
  ),
);

/// Dashboard stats and progress reset (PAR-05..10). Needs the bank.
final statsRepositoryProvider = FutureProvider<StatsRepository>(
  (ref) async => StatsRepository(
    ref.watch(databaseProvider),
    await ref.watch(bankProvider.future),
    clock: ref.watch(clockProvider),
    childId: ref.watch(currentChildProvider),
  ),
);

/// Awards and lists badges (BDG-01..03). Needs the bank, via stats.
final badgeRepositoryProvider = FutureProvider<BadgeRepository>(
  (ref) async => BadgeRepository(
    ref.watch(databaseProvider),
    await ref.watch(statsRepositoryProvider.future),
    clock: ref.watch(clockProvider),
    childId: ref.watch(currentChildProvider),
  ),
);

/// Earned badge ids with their dates. Auto-disposed, so SCR-02 and SCR-06
/// re-read it after every round.
final earnedBadgesProvider = FutureProvider.autoDispose<Map<String, DateTime>>((
  ref,
) async {
  ref.watch(syncDataVersionProvider);
  return (await ref.watch(badgeRepositoryProvider.future)).earned();
});

/// Best stars and level per topic played (PRC-07). Auto-disposed, so a
/// screen that shows it again re-reads it after every round.
final topicProgressProvider =
    FutureProvider.autoDispose<Map<String, TopicProgress>>((ref) {
      ref.watch(syncDataVersionProvider);
      return ref.watch(roundRepositoryProvider).progress();
    });

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
final revisionHistoryProvider = FutureProvider.autoDispose<RevisionHistory>((
  ref,
) async {
  ref.watch(syncDataVersionProvider);
  return (await ref.watch(revisionRepositoryProvider.future)).history();
});

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
    childId: ref.watch(currentChildProvider),
  ),
);

/// Lock state of every topic (PRC-12..14), worked out on each read.
/// SCR-15 invalidates it after the parent opens or locks a topic.
final topicLocksProvider = FutureProvider.autoDispose<Map<String, TopicLock>>((
  ref,
) async {
  ref.watch(syncDataVersionProvider);
  return topicLocks(
    topics: topics,
    rounds: await ref.watch(roundRepositoryProvider).finishedRounds(),
    schoolYear: (await ref.watch(profileRepositoryProvider).load())?.schoolYear,
    opened: await ref.watch(topicLockRepositoryProvider).opened(),
  );
});

/// Whether a PIN exists, and whether the parent area is unlocked.
/// The router listens to it. Unlocking lasts 5 minutes, in memory only.
class AppSession extends ChangeNotifier {
  AppSession({
    SetupStep? setupStep,
    bool pinSet = false,
    required this.clock,
    this._choosingChild = false,
  }) : _setupStep = setupStep,
       _setupUnlocked = setupStep == null || !pinSet;

  static const unlockFor = Duration(minutes: 5);

  final Clock clock;
  SetupStep? _setupStep;
  bool _setupUnlocked;
  bool _choosingChild;
  DateTime? _unlockedAt;

  /// SCR-17 must pick the child before play (FEAT-25 AD-4).
  bool get choosingChild => _choosingChild;

  void chooseChild() {
    if (_choosingChild) return;
    _choosingChild = true;
    notifyListeners();
  }

  void childChosen() {
    if (!_choosingChild) return;
    _choosingChild = false;
    notifyListeners();
  }

  /// First-run setup isn't finished (FEAT-26 AD-1): every route is /setup.
  bool get inSetup => _setupStep != null;

  /// The step setup started this launch at; the wizard keeps the live one.
  SetupStep? get setupStep => _setupStep;

  /// Resuming setup once a PIN is set needs the PIN first (AD-4), so a
  /// child who restarts the app can't finish the parent's setup.
  bool get setupUnlocked => _setupUnlocked;

  void unlockSetup() {
    _setupUnlocked = true;
    notifyListeners();
  }

  void setupFinished() {
    _setupStep = null;
    notifyListeners();
  }

  bool get parentUnlocked =>
      _unlockedAt != null && clock().difference(_unlockedAt!) < unlockFor;

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
