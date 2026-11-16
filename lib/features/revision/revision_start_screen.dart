import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/revision.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/kid_background.dart';
import '../../ui/theme.dart';
import '../topics/topic_map_screen.dart' show TrackSlug;

/// The plan shown on SCR-14 and played by its Go button.
final revisionPreviewProvider = FutureProvider.autoDispose
    .family<({int mistakes, List<String> typeLabels, bool empty}), String>((
      ref,
      scopeId,
    ) async {
      final history = await ref.watch(revisionHistoryProvider.future);
      final planner = ref.watch(revisionPlannerProvider);
      final scope = RevisionScope.fromId(scopeId);
      final topicId = scope is TopicScope ? scope.topicId : null;
      final bank = await ref.watch(bankProvider.future);
      final offered = planner.offers(history, scope);
      final empty =
          !offered ||
          planner.plan(history, bank, scope, _previewRandom).isEmpty;
      return (
        mistakes: planner.mistakes(history, topicId: topicId).length,
        typeLabels: [
          for (final w in planner.weakTypes(history, topicId: topicId))
            typeLabel(w.typeId),
        ],
        empty: empty,
      );
    });

/// The preview only asks whether a plan has questions; order doesn't matter.
final _previewRandom = Random(0);

/// SCR-14: what a revision round of [scopeId] (a topic id or
/// [mixedScopeId]) will practise, and Go (REV-03).
class RevisionStartScreen extends ConsumerWidget {
  const RevisionStartScreen({super.key, required this.scopeId});

  final String scopeId;

  /// "Tricky kinds: a, b, c and 2 more".
  static String trickyText(List<String> labels) {
    final shown = labels.take(3).join(', ');
    final more = labels.length - 3;
    return 'Tricky kinds: $shown${more > 0 ? ' and $more more' : ''}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final topic = topicsById[scopeId];
    final mixed = scopeId == mixedScopeId;
    final back = mixed || topic == null
        ? Routes.home
        : Routes.play(
            topic.track == Track.olympiad
                ? TrackSlug.olympiad
                : TrackSlug.school,
          );
    final preview = ref.watch(revisionPreviewProvider(scopeId));
    final p = preview.value;
    return KidBackground(
      scene: KidScene.forTopic(scopeId),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                        key: const Key('back-home'),
                        iconSize: 36,
                        onPressed: () => context.go(back),
                        icon: const Icon(
                          Icons.arrow_back,
                          semanticLabel: 'Back',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.gap),
                    Expanded(
                      child: Text(
                        mixed ? 'Mixed revision' : topic?.name ?? 'Revision',
                        key: const Key('revise-title'),
                        style: theme.displaySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.gap * 2),
                Expanded(
                  child: p == null
                      ? Center(
                          child: preview.hasError
                              ? const Text('Nothing to revise right now')
                              : const CircularProgressIndicator(),
                        )
                      : SingleChildScrollView(
                          child: _Body(scopeId: scopeId, preview: p),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.scopeId, required this.preview});

  final String scopeId;
  final ({int mistakes, List<String> typeLabels, bool empty}) preview;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: AppText.body, color: AppColors.ink);
    if (preview.empty) {
      return Column(
        children: [
          const Text(
            'Nothing to revise right now',
            key: Key('revise-nothing'),
            style: style,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.gap * 2),
          FilledButton.tonal(
            key: const Key('home'),
            onPressed: () => context.go(Routes.home),
            child: const Text('Home'),
          ),
        ],
      );
    }
    final n = preview.mistakes;
    return Column(
      children: [
        const Text(
          "Let's practise the tricky ones!",
          style: TextStyle(
            fontSize: AppText.heading,
            fontWeight: FontWeight.w600,
            color: AppColors.revision,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.gap * 2),
        if (n > 0)
          Text(
            '$n ${n == 1 ? 'question' : 'questions'} to try again',
            key: const Key('revise-mistakes'),
            style: style,
            textAlign: TextAlign.center,
          ),
        if (preview.typeLabels.isNotEmpty) ...[
          const SizedBox(height: AppSizes.gap),
          Text(
            RevisionStartScreen.trickyText(preview.typeLabels),
            key: const Key('revise-types'),
            style: style,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSizes.gap * 3),
        FilledButton(
          key: const Key('revise-go'),
          onPressed: () => context.go(Routes.reviseQuiz(scopeId)),
          child: const Text('Go!'),
        ),
      ],
    );
  }
}
