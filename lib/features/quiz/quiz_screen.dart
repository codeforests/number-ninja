import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/question.dart';
import '../../domain/quiz.dart';
import '../../ui/theme.dart';
import '../../ui/visuals/question_visual.dart';
import 'answers/drag_answer.dart';
import 'answers/mcq_answer.dart';
import 'answers/number_answer.dart';
import 'feedback_panel.dart';
import 'quiz_controller.dart';

/// SCR-04: one round of 10 questions in [topicId].
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.topicId});

  /// Under this width the two halves stack (portrait).
  static const wideLayout = 900.0;

  final String topicId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(quizControllerProvider.notifier).start(widget.topicId);
      }
    });
  }

  void _next() {
    final controller = ref.read(quizControllerProvider.notifier);
    controller.next();
    final s = ref.read(quizControllerProvider);
    if (s.quiz?.phase == QuizPhase.done) {
      context.go(Routes.result, extra: s.summary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(quizControllerProvider);
    final quiz = s.quiz;
    return Scaffold(
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

class _Body extends ConsumerWidget {
  const _Body({required this.quiz, required this.saving, required this.onNext});

  final Quiz quiz;
  final bool saving;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = quiz.current;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          q.prompt,
          key: const Key('prompt'),
          style: const TextStyle(
            fontSize: AppText.heading,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        if (q.visual != null) ...[
          const SizedBox(height: AppSizes.gap),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.gap / 2),
                child: QuestionVisual(q.visual!),
              ),
            ),
          ),
        ],
      ],
    );
    final result = quiz.lastResult;
    final right = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.gap),
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
      ),
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= QuizScreen.wideLayout
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: left),
                const SizedBox(width: AppSizes.gap * 2),
                Expanded(child: right),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: left),
                const SizedBox(height: AppSizes.gap),
                right,
              ],
            ),
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
