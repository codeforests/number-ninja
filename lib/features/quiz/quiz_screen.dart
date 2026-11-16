import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../topics/topic_map_screen.dart' show TrackSlug;
import '../../ui/kid_background.dart';
import '../../app.dart';
import '../../domain/question.dart';
import '../../domain/quiz.dart';
import '../../ui/layout.dart';
import '../../ui/theme.dart';
import '../../ui/visuals/question_visual.dart';
import '../screen_time/screen_time_controller.dart';
import 'answers/drag_answer.dart';
import 'answers/mcq_answer.dart';
import 'answers/number_answer.dart';
import 'feedback_panel.dart';
import 'quiz_controller.dart';

/// SCR-04: one round of 10 questions in [topicId].
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  /// Holds the screen-time lock while a question is open (TIM-03).
  late final ScreenTimeController _screenTime;
  bool _held = false;

  @override
  void initState() {
    super.initState();
    _screenTime = ref.read(screenTimeProvider)..holdQuestion();
    _held = true;
    Future.microtask(() {
      if (mounted) {
        ref.read(quizControllerProvider.notifier).start(widget.topicId);
      }
    });
  }

  void _release() {
    if (!_held) return;
    _held = false;
    _screenTime.releaseHold();
  }

  @override
  void dispose() {
    // After the frame, so the router isn't refreshed while the tree is
    // being torn down; SCR-05 takes over the hold first.
    if (_held) {
      _held = false;
      Future.microtask(_screenTime.releaseHold);
    }
    super.dispose();
  }

  void _next() {
    final quiz = ref.read(quizControllerProvider).quiz;
    // Time ran out during this question: SCR-07 instead of the next one,
    // except after the last, which shows SCR-05 first (TIM-03).
    if (_screenTime.status?.timeUp == true && quiz != null && !quiz.isLast) {
      _release();
      return;
    }
    final controller = ref.read(quizControllerProvider.notifier);
    controller.next();
    final s = ref.read(quizControllerProvider);
    if (s.quiz?.phase == QuizPhase.done) {
      context.go(Routes.result, extra: s.summary);
    }
  }

  @override
  Widget build(BuildContext context) {
    // A locked topic starts no round: back to the School map (PRC-14).
    ref.listen(quizControllerProvider.select((s) => s.locked), (_, locked) {
      if (locked) context.go(Routes.play(TrackSlug.school));
    });
    final s = ref.watch(quizControllerProvider);
    final quiz = s.quiz;
    return KidBackground(
      scene: KidScene.forTopic(widget.topicId),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.gap),
            child: Column(
              children: [
                _TopBar(quiz: quiz),
                const SizedBox(height: AppSizes.gap),
                Expanded(
                  child: s.error != null
                      ? const Center(
                          child: Text(
                            'Something went wrong. Go home and try again.',
                            style: TextStyle(fontSize: AppText.body),
                          ),
                        )
                      : quiz == null || quiz.phase == QuizPhase.done
                      ? const Center(child: CircularProgressIndicator())
                      : _Body(quiz: quiz, saving: s.saving, onNext: _next),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.quiz});

  final Quiz? quiz;

  @override
  Widget build(BuildContext context) {
    final q = quiz;
    return Row(
      children: [
        SizedBox.square(
          dimension: AppSizes.minTap,
          child: IconButton.filledTonal(
            key: const Key('quit'),
            iconSize: 36,
            onPressed: () => context.go(Routes.home),
            icon: const Icon(Icons.close, semanticLabel: 'Quit'),
          ),
        ),
        Expanded(
          child: Row(
            key: const Key('progress-dots'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (q != null)
                for (var i = 0; i < q.questions.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < q.results.length
                          ? (q.results[i].correct
                                ? AppColors.leaf
                                : AppColors.berry)
                          : AppColors.ninjaLight,
                      border: i == q.index && q.phase == QuizPhase.answering
                          ? Border.all(color: AppColors.ninja, width: 3)
                          : null,
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.minTap),
      ],
    );
  }
}

/// The question and its answer area. Side by side, each half scrolls on
/// its own; stacked, the whole body scrolls. Nothing overlaps (NFR-09).
class _Body extends ConsumerWidget {
  const _Body({required this.quiz, required this.saving, required this.onNext});

  final Quiz quiz;
  final bool saving;
  final VoidCallback onNext;

  /// The smallest box a visual is drawn in.
  static const minVisual = 160.0;

  static const promptStyle = TextStyle(
    fontSize: AppText.heading,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  /// The prompt's laid-out height at [width], as the Text below draws it.
  static double promptHeight(BuildContext context, String text, double width) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(promptStyle),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: width);
    final h = painter.height;
    painter.dispose();
    return h;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = quiz.current;
    final prompt = Text(q.prompt, key: const Key('prompt'), style: promptStyle);
    Widget visualBox(double height) => SizedBox(
      key: const Key('visual-box'),
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gap / 2),
          child: QuestionVisual(q.visual!),
        ),
      ),
    );
    final result = quiz.lastResult;
    final answer = KeyedSubtree(
      key: const Key('answer-area'),
      child: result != null
          ? FeedbackPanel(
              question: q,
              result: result,
              isLast: quiz.isLast,
              onNext: onNext,
            )
          : IgnorePointer(
              ignoring: saving,
              child: _AnswerArea(
                key: ValueKey('answer-${quiz.index}-${q.id}'),
                question: q,
                onSubmit: (given) =>
                    ref.read(quizControllerProvider.notifier).check(given),
              ),
            ),
    );

    if (!sideBySide(MediaQuery.sizeOf(context))) {
      final screen = MediaQuery.sizeOf(context).height;
      return SingleChildScrollView(
        key: const Key('quiz-scroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            prompt,
            if (q.visual != null) ...[
              const SizedBox(height: AppSizes.gap),
              visualBox((screen * 0.35).clamp(minVisual, 400)),
            ],
            const SizedBox(height: AppSizes.gap),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.gap),
                child: answer,
              ),
            ),
          ],
        ),
      );
    }

    final left = LayoutBuilder(
      builder: (context, c) {
        final free =
            c.maxHeight -
            promptHeight(context, q.prompt, c.maxWidth) -
            AppSizes.gap;
        return SingleChildScrollView(
          key: const Key('question-scroll'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              prompt,
              if (q.visual != null) ...[
                const SizedBox(height: AppSizes.gap),
                visualBox(free > minVisual ? free : minVisual),
              ],
            ],
          ),
        );
      },
    );
    final right = LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        key: const Key('answer-scroll'),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Center(
            child: Padding(
              // No side padding: the keypad just fits a 640 dp half.
              padding: const EdgeInsets.symmetric(vertical: AppSizes.gap),
              child: answer,
            ),
          ),
        ),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const SizedBox(width: AppSizes.gap * 2),
        Expanded(child: right),
      ],
    );
  }
}

class _AnswerArea extends StatelessWidget {
  const _AnswerArea({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  final Question question;
  final ValueChanged<Object> onSubmit;

  @override
  Widget build(BuildContext context) => switch (question.format) {
    QuestionFormat.mcq => McqAnswer(
      options: question.options!,
      onSubmit: onSubmit,
    ),
    QuestionFormat.number => NumberAnswer(onSubmit: onSubmit),
    QuestionFormat.drag => DragAnswer(
      items: question.drag!.items,
      slots: question.drag!.slots,
      onSubmit: onSubmit,
    ),
  };
}
