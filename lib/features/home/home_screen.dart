import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../ui/theme.dart';

/// SCR-02: home. Track cards are placeholders until FEAT-04.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gap * 2),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Number Ninja', style: theme.displaySmall),
                  ),
                  SizedBox(
                    height: AppSizes.minTap,
                    child: OutlinedButton.icon(
                      key: const Key('parent-button'),
                      onPressed: () => context.go(Routes.parent),
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Parent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.gap * 2),
              const Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _TrackCard(
                        title: 'School',
                        subtitle: 'P1 and P2 maths',
                        icon: Icons.school,
                      ),
                    ),
                    SizedBox(width: AppSizes.gap * 2),
                    Expanded(
                      child: _TrackCard(
                        title: 'Olympiad',
                        subtitle: 'Puzzles and patterns',
                        icon: Icons.extension,
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

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Opacity(
      opacity: 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.ninjaLight, width: 3),
        ),
        padding: const EdgeInsets.all(AppSizes.gap * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 96, color: AppColors.ninja),
            const SizedBox(height: AppSizes.gap),
            Text(title, style: theme.headlineSmall),
            Text(subtitle, style: theme.bodyLarge),
            const SizedBox(height: AppSizes.gap),
            Text(
              'Coming soon',
              style: theme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
