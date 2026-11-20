import 'package:material_ui/material_ui.dart';

import '../../domain/setup.dart';
import '../../ui/layout.dart';
import '../../ui/theme.dart';

/// Body text on setup steps (AD-13): larger than other parent screens.
const setupBodyStyle = TextStyle(fontSize: AppText.setupBody);

/// One setup step's page (SCR-19, AD-13): progress dots, an icon, title and
/// subtitle, the step's [body], and Back beside a wide primary button pinned
/// at the bottom. Landscape tablets put the heading on the left.
class SetupFrame extends StatelessWidget {
  const SetupFrame({
    super.key,
    required this.step,
    required this.icon,
    required this.title,
    required this.body,
    this.subtitle,
    this.nextLabel = 'Next',
    this.nextKey = const Key('setup-next'),
    this.onNext,
    this.onBack,
    this.showActions = true,
  });

  final SetupStep step;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget body;
  final String nextLabel;
  final Key nextKey;

  /// Null greys the primary button out.
  final VoidCallback? onNext;

  /// Null hides Back (Welcome, or while busy).
  final VoidCallback? onBack;

  /// False hides both buttons (while bringing the family back).
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);
    final wide = sideBySide(size);
    final heading = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: wide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (!compact(size) || wide) ...[
          SetupIcon(icon),
          const SizedBox(height: AppSizes.gap),
        ],
        Text(
          title,
          key: const Key('setup-title'),
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: theme.headlineMedium,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.gap / 2),
          Text(
            subtitle!,
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: setupBodyStyle.copyWith(color: AppColors.muted),
          ),
        ],
      ],
    );
    final content = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.gap),
                  child: heading,
                ),
              ),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.gap),
                  child: body,
                ),
              ),
            ],
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.gap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                const SizedBox(height: AppSizes.gap * 1.5),
                body,
              ],
            ),
          );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.gap,
            vertical: AppSizes.gap / 2,
          ),
          child: Column(
            children: [
              SetupDots(step: step),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.minTap * 16,
                    ),
                    child: content,
                  ),
                ),
              ),
              if (showActions)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.minTap * 12,
                  ),
                  child: Row(
                    children: [
                      if (onBack != null) ...[
                        SizedBox(
                          height: AppSizes.minTap,
                          child: TextButton.icon(
                            key: const Key('setup-back'),
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: AppSizes.gap),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: AppSizes.minTap,
                          child: FilledButton(
                            key: nextKey,
                            onPressed: onNext,
                            child: Text(
                              nextLabel,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A large icon on a theme-coloured circle (AD-9: no image assets).
class SetupIcon extends StatelessWidget {
  const SetupIcon(this.icon, {super.key, this.color = AppColors.ninja});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: AppSizes.setupIcon,
    height: AppSizes.setupIcon,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Icon(icon, size: AppSizes.setupIcon * 0.55, color: AppColors.card),
  );
}

/// One dot per step; the current one is filled (`setup-dot-<i>`).
class SetupDots extends StatelessWidget {
  const SetupDots({super.key, required this.step});

  final SetupStep step;

  @override
  Widget build(BuildContext context) {
    final at = dotIndex(step);
    return Semantics(
      label: 'Step ${at + 1} of $setupDots',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.gap / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < setupDots; i++)
              Container(
                key: Key('setup-dot-$i'),
                width: AppSizes.setupDot,
                height: AppSizes.setupDot,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= at ? AppColors.ninja : AppColors.card,
                  border: Border.all(color: AppColors.stepBorder, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
