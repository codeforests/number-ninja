import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/setup.dart';
import '../../ui/theme.dart';
import 'setup_controller.dart';
import 'setup_frame.dart';

/// Step 1 (SET-01): what BrainBubblz does, in three cards.
class WelcomeStep extends ConsumerWidget {
  const WelcomeStep({super.key});

  static const cards = [
    (
      Icons.timer_outlined,
      AppColors.trackP1,
      'Short daily practice',
      'Quick rounds of school and Olympiad maths at the right level.',
    ),
    (
      Icons.insights,
      AppColors.leaf,
      'You see the progress',
      'Accuracy and speed for every topic, behind your parent PIN.',
    ),
    (
      Icons.lock_clock,
      AppColors.sun,
      'Screen time you control',
      'A daily time limit that only your PIN can change.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    return SetupFrame(
      step: SetupStep.welcome,
      icon: Icons.waving_hand,
      title: 'Welcome to BrainBubblz',
      subtitle: "Let's set things up for your child. It takes about 2 minutes.",
      nextLabel: 'Get started',
      onNext: () => ref.read(setupControllerProvider.notifier).next(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (icon, color, title, text)) in cards.indexed)
            Card(
              key: Key('setup-welcome-card-$i'),
              margin: const EdgeInsets.only(bottom: AppSizes.gap),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.gap),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: AppSizes.minTap / 2,
                      backgroundColor: color,
                      child: Icon(
                        icon,
                        size: AppSizes.minTap / 2,
                        color: AppColors.card,
                      ),
                    ),
                    const SizedBox(width: AppSizes.gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: theme.titleLarge),
                          Text(text, style: setupBodyStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
