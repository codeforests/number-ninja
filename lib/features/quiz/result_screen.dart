import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../ui/theme.dart';
import 'quiz_controller.dart';

/// SCR-05: the end of a round. Minimal until FEAT-03 T7 adds time, stars and
/// Play again.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.summary});

  final RoundSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${summary.score} / ${summary.total}',
              key: const Key('result-score'),
              style: theme.displaySmall,
            ),
            const SizedBox(height: AppSizes.gap * 2),
            FilledButton(
              key: const Key('home'),
              onPressed: () => context.go(Routes.home),
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}
