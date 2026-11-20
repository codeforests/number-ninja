import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/revision/revision_start_screen.dart';
import 'features/badges/badge_shelf_screen.dart';
import 'features/family/who_screen.dart';
import 'features/home/home_screen.dart';
import 'features/quiz/quiz_controller.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/topics/topic_map_screen.dart';
import 'features/quiz/result_screen.dart';
import 'domain/stats.dart';
import 'features/parent/account_screen.dart';
import 'features/parent/plus_screen.dart';
import 'features/parent/change_pin_screen.dart';
import 'features/parent/dashboard_screen.dart';
import 'features/parent/day_screen.dart';
import 'features/parent/parent_screen.dart';
import 'features/parent/pin_entry_screen.dart';
import 'features/parent/reset_screen.dart';
import 'features/parent/topic_detail_screen.dart';
import 'features/parent/topic_locks_screen.dart';
import 'features/parent/children_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/screen_time/lock_screen.dart';
import 'features/screen_time/screen_time_controller.dart';
import 'features/setup/setup_screen.dart';
import 'providers.dart';
import 'ui/theme.dart';

abstract final class Routes {
  static const setup = '/setup'; // SCR-19, first-run setup (FEAT-26)
  static const profile = '/parent/profile'; // SCR-12 from SCR-11
  static const children = '/parent/children'; // SCR-18, FEAT-25
  static const newChild = '$profile?child=new'; // SCR-12, add a child
  static String childProfile(int id) => '$profile?child=$id'; // SCR-12
  static String removeChild(int id) =>
      '/parent/remove-child?child=$id'; // SCR-12 remove, PIN confirm
  static const topicLocks = '/parent/topics'; // SCR-15
  static const account = '/parent/account'; // SCR-13
  static const plus = '/parent/plus'; // SCR-20, FEAT-30
  static const home = '/'; // SCR-02
  static const pinEntry = '/parent/pin'; // SCR-08
  static const parent = '/parent'; // SCR-11
  static const changePin = '/parent/change-pin'; // SCR-11 (change PIN)
  static const dashboard = '/parent/dashboard'; // SCR-09, `?p=7|30|all`
  static const reset = '/parent/reset'; // SCR-11 (reset progress, PAR-10)
  static const dayToday = '/parent/day'; // SCR-16, today
  static String day(String day) => '$dayToday?d=$day'; // SCR-16
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
  static const who = '/who'; // SCR-17, FEAT-25

  /// SCR-08 for changing child when the parent asked for the PIN (AD-4).
  static const pinForChild = '$pinEntry?next=who';

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
  if (session.inSetup) return location == Routes.setup ? null : Routes.setup;
  if (location == Routes.setup) return Routes.home;
  final isParent = location.startsWith(Routes.parent);
  if (isParent && location != Routes.pinEntry && !session.parentUnlocked) {
    return Routes.pinEntry;
  }
  // FEAT-25 AD-4: pick the child first; the parent area stays reachable.
  if (session.choosingChild && !isParent && location != Routes.who) {
    return Routes.who;
  }
  if (!session.choosingChild && location == Routes.who) return Routes.home;
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
        builder: (context, state) => const SetupScreen(),
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
      GoRoute(path: Routes.who, builder: (context, state) => const WhoScreen()),
      GoRoute(
        path: Routes.parent,
        builder: (context, state) => const ParentScreen(),
        routes: [
          GoRoute(
            path: 'pin',
            builder: (context, state) => PinEntryScreen(
              forChildChange: state.uri.queryParameters['next'] == 'who',
            ),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) =>
                ProfileScreen(child: state.uri.queryParameters['child']),
          ),
          GoRoute(
            path: 'children',
            builder: (context, state) => const ChildrenScreen(),
          ),
          GoRoute(
            path: 'remove-child',
            builder: (context, state) => RemoveChildScreen(
              childId:
                  int.tryParse(state.uri.queryParameters['child'] ?? '') ?? 0,
            ),
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
            path: 'plus',
            builder: (context, state) => const PlusScreen(),
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
            path: 'day',
            builder: (context, state) =>
                DayScreen(day: state.uri.queryParameters['d']),
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
  final crash = ref.read(crashReporterProvider);
  void onRoute() {
    final match = router.routerDelegate.currentConfiguration;
    screenTime.setChildRoute(Routes.counts(match.uri.path));
    // The pattern, never the ids or query (FEAT-24 AD-6).
    crash.screen = match.fullPath;
  }

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
    // FEAT-30 (PD-5): the Plus cache follows the account and each sync.
    ref.listenManual(plusControllerProvider, (_, _) {});
    // FEAT-24: saved errors need the database; send them at launch/resume.
    ref
        .read(crashReporterProvider)
        .attach(
          repo: ref.read(crashRepositoryProvider),
          context: ref.read(crashContextProvider),
        );
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.read(syncProvider.notifier).requestSync();
        ref.read(bankCheckProvider)();
        ref.read(crashSendProvider)();
      },
    );
    // FEAT-15 (BNK-08): look for a newer bank at launch, at most daily.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bankCheckProvider)();
      ref.read(crashSendProvider)();
    });
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
      title: 'BrainBubblz',
      scaffoldMessengerKey: _messenger,
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
