import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../ui/theme.dart';
import 'quiz_controller.dart';

/// A round's answering time as `m:ss`, rounded down to the second (PRC-06).
String formatMinSec(int ms) {
  final s = ms ~/ 1000;
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// SCR-05: the end of a round, with score, time and 0–3 stars (PRC-06).
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.summary});

  final RoundSummary summary;

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
                Row(
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
                      onPressed: () => context.go(Routes.quiz(summary.topicId)),
                      child: const Text('Play again'),
                    ),
                    FilledButton.tonal(
                      key: const Key('home'),
                      onPressed: () => context.go(Routes.home),
                      child: const Text('Home'),
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
