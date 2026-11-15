import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/home/home_screen.dart';
import 'features/quiz/quiz_controller.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/quiz/result_screen.dart';
import 'features/quiz/topic_list_screen.dart';
import 'features/parent/change_pin_screen.dart';
import 'features/parent/parent_screen.dart';
import 'features/parent/pin_entry_screen.dart';
import 'features/setup/setup_pin_screen.dart';
import 'providers.dart';
import 'ui/theme.dart';

abstract final class Routes {
  static const setup = '/setup'; // SCR-01
  static const home = '/'; // SCR-02
  static const pinEntry = '/parent/pin'; // SCR-08
  static const parent = '/parent'; // SCR-11
  static const changePin = '/parent/change-pin'; // SCR-11 (change PIN)
  static String play(String track) => '/play/$track'; // SCR-03 placeholder
  static String quiz(String topicId) => '/quiz/$topicId'; // SCR-04
  static const result = '/result'; // SCR-05, the RoundSummary as extra
}

/// Where a location should go instead, or null to stay (design: Routing).
String? redirectFor(AppSession session, String location) {
  if (!session.hasPin) return location == Routes.setup ? null : Routes.setup;
  if (location == Routes.setup) return Routes.home;
  final isParent = location.startsWith(Routes.parent);
  if (isParent && location != Routes.pinEntry && !session.parentUnlocked) {
    return Routes.pinEntry;
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(appSessionProvider);
  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: session,
    redirect: (context, state) => redirectFor(session, state.matchedLocation),
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
            TopicListScreen(track: state.pathParameters['track']!),
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
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class NumberNinjaApp extends ConsumerWidget {
  const NumberNinjaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Number Ninja',
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
