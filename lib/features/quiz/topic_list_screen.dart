import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/topics.dart';
import '../../ui/theme.dart';

/// SCR-03 placeholder until FEAT-04: plain tiles with topic names.
/// [track] is `school` (P1 and P2) or `olympiad`.
class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key, required this.track});

  final String track;

  @override
  Widget build(BuildContext context) {
    final olympiad = track == 'olympiad';
    final list = [
      for (final t in topics)
        if ((t.track == Track.olympiad) == olympiad) t,
    ];
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gap * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox.square(
                    dimension: AppSizes.minTap,
                    child: IconButton.filledTonal(
                      key: const Key('back'),
                      iconSize: 36,
                      onPressed: () => context.go(Routes.home),
                      icon: const Icon(Icons.arrow_back, semanticLabel: 'Back'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.gap),
                  Text(
                    olympiad ? 'Olympiad' : 'School',
                    style: theme.displaySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.gap * 2),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppSizes.gap,
                    runSpacing: AppSizes.gap,
                    children: [
                      for (final t in list)
                        SizedBox(
                          width: 280,
                          height: AppSizes.minTap * 1.5,
                          child: FilledButton.tonal(
                            key: Key('topic-${t.id}'),
                            onPressed: () => context.go(Routes.quiz(t.id)),
                            child: Text(t.name, textAlign: TextAlign.center),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
