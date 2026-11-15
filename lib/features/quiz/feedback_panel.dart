import 'package:material_ui/material_ui.dart';

import '../../domain/question.dart';
import '../../domain/quiz.dart';
import '../../ui/theme.dart';

/// Shown after Check in place of the answer buttons (PRC-05).
class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({
    super.key,
    required this.question,
    required this.result,
    required this.isLast,
    required this.onNext,
  });

  final Question question;
  final AnswerResult result;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final right = result.correct;
    final color = right ? AppColors.leaf : AppColors.berry;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              right ? Icons.check_circle : Icons.cancel,
              color: color,
              size: AppText.title * 1.5,
            ),
            const SizedBox(width: AppSizes.gap),
            Text(
              right ? 'Right!' : 'Not quite',
              key: const Key('feedback-title'),
              style: TextStyle(
                fontSize: AppText.title,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        if (!right) ...[
          const SizedBox(height: AppSizes.gap),
          Text(
            'The answer is ${correctAnswerText(question)}',
            key: const Key('feedback-answer'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppText.heading,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSizes.gap / 2),
          Text(
            question.explanation,
            key: const Key('feedback-explanation'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppText.body,
              color: AppColors.ink,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.gap * 2),
        FilledButton(
          key: const Key('next'),
          onPressed: onNext,
          child: Text(isLast ? 'See results' : 'Next'),
        ),
      ],
    );
  }
}
