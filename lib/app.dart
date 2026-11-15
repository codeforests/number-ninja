import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/home/home_screen.dart';
import 'features/quiz/quiz_controller.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/topics/topic_map_screen.dart';
import 'features/quiz/result_screen.dart';
import 'domain/stats.dart';
import 'features/parent/change_pin_screen.dart';
import 'features/parent/dashboard_screen.dart';
import 'features/parent/parent_screen.dart';
import 'features/parent/pin_entry_screen.dart';
import 'features/screen_time/lock_screen.dart';
import 'features/screen_time/screen_time_controller.dart';
import 'features/setup/setup_pin_screen.dart';
import 'providers.dart';
import 'ui/theme.dart';

abstract final class Routes {
  static const setup = '/setup'; // SCR-01
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
  static const result = '/result'; // SCR-05, the RoundSummary as extra
  static const locked = '/locked'; // SCR-07

  /// The routes whose time counts as screen time (TIM-01). SCR-07 itself
  /// doesn't, so extra time a parent grants isn't used up on the lock.
  static bool counts(String location) =>
      location == home ||
      location.startsWith('/play/') ||
      location.startsWith('/quiz/') ||
      location == result;
}

/// Where a location should go instead, or null to stay (design: Routing).
/// [locked] is [ScreenTimeController.locked]; `/parent*` is never locked.
String? redirectFor(AppSession session, bool locked, String location) {
  if (!session.hasPin) return location == Routes.setup ? null : Routes.setup;
  if (location == Routes.setup) return Routes.home;
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
        path: Routes.result,
        redirect: (context, state) =>
            state.extra is RoundSummary ? null : Routes.home,
        builder: (context, state) =>
            ResultScreen(summary: state.extra! as RoundSummary),
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
            path: 'change-pin',
            builder: (context, state) => const ChangePinScreen(),
          ),
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => DashboardScreen(
              period: StatsPeriod.fromQuery(state.uri.queryParameters['p']),
            ),
          ),
          // T6: topic detail and reset routes.
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

  @override
  void initState() {
    super.initState();
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
