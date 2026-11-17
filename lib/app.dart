import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/revision/revision_start_screen.dart';
import 'features/badges/badge_shelf_screen.dart';
import 'features/home/home_screen.dart';
import 'features/quiz/quiz_controller.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/topics/topic_map_screen.dart';
import 'features/quiz/result_screen.dart';
import 'domain/stats.dart';
import 'features/parent/account_screen.dart';
import 'features/parent/change_pin_screen.dart';
import 'features/parent/dashboard_screen.dart';
import 'features/parent/parent_screen.dart';
import 'features/parent/pin_entry_screen.dart';
import 'features/parent/reset_screen.dart';
import 'features/parent/topic_detail_screen.dart';
import 'features/parent/topic_locks_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/screen_time/lock_screen.dart';
import 'features/screen_time/screen_time_controller.dart';
import 'features/setup/setup_pin_screen.dart';
import 'providers.dart';
import 'ui/theme.dart';

abstract final class Routes {
  static const setup = '/setup'; // SCR-01
  static const setupProfile = '/setup/profile'; // SCR-12, first run
  static const profile = '/parent/profile'; // SCR-12 from SCR-11
  static const topicLocks = '/parent/topics'; // SCR-15
  static const account = '/parent/account'; // SCR-13
  static const home = '/'; // SCR-02
  static const pinEntry = '/parent/pin'; // SCR-08
  static const parent = '/parent'; // SCR-11
  static const changePin = '/parent/change-pin'; // SCR-11 (change PIN)
  static const dashboard = '/parent/dashboard'; // SCR-09, `?p=7|30|all`
  static const reset = '/parent/reset'; // SCR-11 (reset progress, PAR-10)
  static String dashboardFor(StatsPeriod p) => '$dashboard?p=${p.query}';
  static String topicDetail(String topicId, StatsPeriod p) =>
      '/parent/topic/$topicId?p=${p.query}'; // SCR-10
  static String play(String track) => '/play/$track'; // SCR-03
  static String quiz(String topicId) => '/quiz/$topicId'; // SCR-04
  static String revise(String scopeId) => '/revise/$scopeId'; // SCR-14
  static String reviseQuiz(String scopeId) =>
      '/revise/$scopeId/quiz'; // SCR-04, revision round
  static const result = '/result'; // SCR-05, the RoundSummary as extra
  static const locked = '/locked'; // SCR-07
  static const badges = '/badges'; // SCR-06

  /// The routes whose time counts as screen time (TIM-01). SCR-07 itself
  /// doesn't, so extra time a parent grants isn't used up on the lock.
  static bool counts(String location) =>
      location == home ||
      location.startsWith('/play/') ||
      location.startsWith('/quiz/') ||
      location.startsWith('/revise/') ||
      location == result ||
      location == badges;
}

/// Where a location should go instead, or null to stay (design: Routing).
/// [locked] is [ScreenTimeController.locked]; `/parent*` is never locked.
String? redirectFor(AppSession session, bool locked, String location) {
  if (!session.hasPin) return location == Routes.setup ? null : Routes.setup;
  if (session.profilePending) {
    return location == Routes.setupProfile ? null : Routes.setupProfile;
  }
  if (location == Routes.setup || location == Routes.setupProfile) {
    return Routes.home;
  }
  final isParent = location.startsWith(Routes.parent);
  if (isParent && location != Routes.pinEntry && !session.parentUnlocked) {
    return Routes.pinEntry;
  }
  if (locked && Routes.counts(location)) return Routes.locked;
  if (!locked && location == Routes.locked) return Routes.home;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(appSessionProvider);
  final screenTime = ref.watch(screenTimeProvider);
  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: Listenable.merge([session, screenTime.lockedListenable]),
    redirect: (context, state) =>
        redirectFor(session, screenTime.locked, state.matchedLocation),
    routes: [
      GoRoute(
        path: Routes.setup,
        builder: (context, state) => const SetupPinScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(firstRun: true),
          ),
        ],
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/play/:track',
        builder: (context, state) =>
            TopicMapScreen(track: state.pathParameters['track']!),
      ),
      GoRoute(
        path: '/quiz/:topicId',
        builder: (context, state) =>
            QuizScreen(topicId: state.pathParameters['topicId']!),
      ),
      GoRoute(
        path: '/revise/:scopeId',
        builder: (context, state) =>
            RevisionStartScreen(scopeId: state.pathParameters['scopeId']!),
        routes: [
          GoRoute(
            path: 'quiz',
            builder: (context, state) => QuizScreen(
              topicId: state.pathParameters['scopeId']!,
              revision: true,
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.result,
        redirect: (context, state) =>
            state.extra is RoundSummary ? null : Routes.home,
        builder: (context, state) =>
            ResultScreen(summary: state.extra! as RoundSummary),
      ),
      GoRoute(
        path: Routes.badges,
        builder: (context, state) => const BadgeShelfScreen(),
      ),
      GoRoute(
        path: Routes.locked,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: Routes.parent,
        builder: (context, state) => const ParentScreen(),
        routes: [
          GoRoute(
            path: 'pin',
            builder: (context, state) => const PinEntryScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(firstRun: false),
          ),
          GoRoute(
            path: 'topics',
            builder: (context, state) => const TopicLocksScreen(),
          ),
          GoRoute(
            path: 'account',
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: 'change-pin',
            builder: (context, state) => const ChangePinScreen(),
          ),
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => DashboardScreen(
              period: StatsPeriod.fromQuery(state.uri.queryParameters['p']),
            ),
          ),
          GoRoute(
            path: 'topic/:topicId',
            builder: (context, state) => TopicDetailScreen(
              topicId: state.pathParameters['topicId']!,
              period: StatsPeriod.fromQuery(state.uri.queryParameters['p']),
            ),
          ),
          GoRoute(
            path: 'reset',
            builder: (context, state) => const ResetScreen(),
          ),
        ],
      ),
    ],
  );
  void onRoute() => screenTime.setChildRoute(
    Routes.counts(router.routerDelegate.currentConfiguration.uri.path),
  );
  router.routerDelegate.addListener(onRoute);
  ref.onDispose(() {
    router.routerDelegate.removeListener(onRoute);
    router.dispose();
  });
  return router;
});

class NumberNinjaApp extends ConsumerStatefulWidget {
  const NumberNinjaApp({super.key});

  @override
  ConsumerState<NumberNinjaApp> createState() => _NumberNinjaAppState();
}

class _NumberNinjaAppState extends ConsumerState<NumberNinjaApp> {
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<void>? _warnings;
  AppLifecycleListener? _lifecycle;

  @override
  void initState() {
    super.initState();
    // Sync runs while signed in (FEAT-14): keep it alive, and sync on resume.
    ref.listenManual(syncProvider, (_, _) {});
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.read(syncProvider.notifier).requestSync();
        ref.read(bankCheckProvider)();
      },
    );
    // FEAT-15 (BNK-08): look for a newer bank at launch, at most daily.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(bankCheckProvider)(),
    );
    _warnings = ref.read(screenTimeProvider).warnings.listen((_) {
      _messenger.currentState?.showSnackBar(
        const SnackBar(
          key: Key('time-warning'),
          duration: Duration(seconds: 6),
          content: Text(
            '2 minutes left! Finish this question.',
            style: TextStyle(fontSize: AppText.body),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _warnings?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Number Ninja',
      scaffoldMessengerKey: _messenger,
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
