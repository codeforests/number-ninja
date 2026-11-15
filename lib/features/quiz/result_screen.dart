import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../ui/badge_icons.dart';
import '../../ui/theme.dart';
import '../screen_time/screen_time_controller.dart';
import 'quiz_controller.dart';

/// A round's answering time as `m:ss`, rounded down to the second (PRC-06).
String formatMinSec(int ms) {
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// SCR-05: the end of a round, with score, time and 0–3 stars (PRC-06),
/// and "Level up!" when the topic steps up (PRC-09). A step down shows
/// nothing.
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.summary});

  final RoundSummary summary;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  /// If time ran out on the last question, SCR-05 still shows until a
  /// button is tapped (TIM-03).
  late final ScreenTimeController _screenTime;
  bool _held = false;

  RoundSummary get summary => widget.summary;

  @override
  void initState() {
    super.initState();
    _screenTime = ref.read(screenTimeProvider)..holdQuestion();
    _held = true;
  }

  @override
  void dispose() {
    if (_held) {
      _held = false;
      Future.microtask(_screenTime.releaseHold);
    }
    super.dispose();
  }

  void _go(String location) {
    if (_held) {
      _held = false;
      _screenTime.releaseHold();
    }
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.gap * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shrinks on a narrow phone instead of overflowing (NFR-09).
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    key: const Key('result-stars'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Icon(
                          i < summary.stars ? Icons.star : Icons.star_border,
                          key: Key('star-$i'),
                          size: AppSizes.minTap * 2,
                          color: i < summary.stars
                              ? AppColors.sun
                              : AppColors.muted,
                        ),
                    ],
                  ),
                ),
                if (summary.levelUp) ...[
                  const SizedBox(height: AppSizes.gap),
                  Text(
                    'Level up! Now level ${summary.nextLevel}',
                    key: const Key('level-up'),
                    style: theme.headlineSmall?.copyWith(
                      color: AppColors.sun,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (summary.newBadges.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.gap * 2),
                  _NewBadges(summary),
                ],
                const SizedBox(height: AppSizes.gap * 2),
                Text(
                  '${summary.score} / ${summary.total}',
                  key: const Key('result-score'),
                  style: theme.displaySmall,
                ),
                const SizedBox(height: AppSizes.gap),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: AppText.heading,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: AppSizes.gap / 2),
                    Text(
                      formatMinSec(summary.durationMs),
                      key: const Key('result-time'),
                      style: theme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.gap * 3),
                Wrap(
                  spacing: AppSizes.gap * 2,
                  runSpacing: AppSizes.gap,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      key: const Key('play-again'),
                      onPressed: () => _go(Routes.quiz(summary.topicId)),
                      child: const Text('Play again'),
                    ),
                    FilledButton.tonal(
                      key: const Key('home'),
                      onPressed: () => _go(Routes.home),
                      child: const Text('Home'),
                    ),
                    if (summary.newBadges.isNotEmpty)
                      FilledButton.tonal(
                        key: const Key('see-badges'),
                        onPressed: () => _go(Routes.badges),
                        child: const Text('My badges'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The badges a round earned, popping in (BDG-02).
class _NewBadges extends StatelessWidget {
  const _NewBadges(this.summary);

  final RoundSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final many = summary.newBadges.length > 1;
    return Column(
      children: [
        Text(
          many ? 'New badges!' : 'New badge!',
          key: const Key('new-badges'),
          style: theme.headlineSmall?.copyWith(
            color: AppColors.ninja,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.gap),
        Wrap(
          spacing: AppSizes.gap * 2,
          runSpacing: AppSizes.gap,
          alignment: WrapAlignment.center,
          children: [
            for (final b in summary.newBadges)
              TweenAnimationBuilder<double>(
                key: Key('new-badge-${b.id}'),
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.badgePop,
                curve: Curves.elasticOut,
                builder: (context, t, child) =>
                    Transform.scale(scale: t, child: child),
                child: SizedBox(
                  width: AppSizes.badge * 1.6,
                  child: Column(
                    children: [
                      BadgeIcon(b.id),
                      const SizedBox(height: AppSizes.gap / 2),
                      Text(
                        b.name,
                        textAlign: TextAlign.center,
                        style: theme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
