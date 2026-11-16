import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/screen_time.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import '../screen_time/screen_time_controller.dart';
import 'report_export.dart';

/// SCR-11: parent area: Progress (FEAT-06), screen time (FEAT-05), Change
/// PIN and reset progress; FEAT-07 adds more.
class ParentScreen extends ConsumerWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent area'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.gap),
            child: FilledButton(
              key: const Key('parent-done'),
              onPressed: () {
                ref.read(appSessionProvider).lockParent();
                context.go(Routes.home);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.gap),
        children: [
          const _ProfileTile(),
          const _TopicLocksTile(),
          const Divider(height: AppSizes.gap * 2),
          ListTile(
            key: const Key('open-dashboard'),
            minTileHeight: AppSizes.minTap,
            leading: const Icon(Icons.insights),
            title: const Text('Progress'),
            subtitle: const Text('Accuracy, speed and trends per topic'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.dashboard),
          ),
          ListTile(
            key: const Key('export-report'),
            minTileHeight: AppSizes.minTap,
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export PDF report'),
            subtitle: const Text('Share or save a summary'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showExportSheet(context),
          ),
          const Divider(height: AppSizes.gap * 2),
          const _ScreenTimeSection(),
          const Divider(height: AppSizes.gap * 2),
          const _SoundSection(),
          const Divider(height: AppSizes.gap * 2),
          ListTile(
            key: const Key('change-pin'),
            minTileHeight: AppSizes.minTap,
            leading: const Icon(Icons.password),
            title: const Text('Change PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.changePin),
          ),
          const Divider(height: AppSizes.gap * 2),
          ListTile(
            key: const Key('reset-progress'),
            minTileHeight: AppSizes.minTap,
            iconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
            leading: const Icon(Icons.delete_forever),
            title: const Text('Reset all progress'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.reset),
          ),
        ],
      ),
    );
  }
}

/// Today's use, the daily limit (5–120 in steps of 5, D5) and extra time
/// for today (TIM-04). Each tap saves at once.
class _ScreenTimeSection extends ConsumerWidget {
  const _ScreenTimeSection();

  static const step = 5;
  static const extras = [5, 10, 15, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenTime = ref.watch(screenTimeProvider);
    final theme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: screenTime,
      builder: (context, _) {
        final s = screenTime.status;
        if (s == null) return const SizedBox.shrink();
        final limit = s.limitMinutes;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Screen time', style: theme.headlineSmall),
              const SizedBox(height: AppSizes.gap / 2),
              Text(
                'Today: ${s.usedSeconds ~/ 60} min used, '
                '${s.minutesLeft} min left',
                key: const Key('today-usage'),
                style: theme.bodyLarge,
              ),
              const SizedBox(height: AppSizes.gap),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSizes.gap,
                runSpacing: AppSizes.gap / 2,
                children: [
                  Text('Daily limit', style: theme.bodyLarge),
                  IconButton.outlined(
                    key: const Key('limit-minus'),
                    constraints: const BoxConstraints.tightFor(
                      width: AppSizes.minTap,
                      height: AppSizes.minTap,
                    ),
                    tooltip: 'Less time',
                    onPressed: limit <= minDailyLimit
                        ? null
                        : () => screenTime.setDailyLimit(limit - step),
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$limit min',
                    key: const Key('limit-value'),
                    style: theme.bodyLarge,
                  ),
                  IconButton.outlined(
                    key: const Key('limit-plus'),
                    constraints: const BoxConstraints.tightFor(
                      width: AppSizes.minTap,
                      height: AppSizes.minTap,
                    ),
                    tooltip: 'More time',
                    onPressed: limit >= maxDailyLimit
                        ? null
                        : () => screenTime.setDailyLimit(limit + step),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.gap),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSizes.gap,
                runSpacing: AppSizes.gap / 2,
                children: [
                  Text('Extra time today', style: theme.bodyLarge),
                  for (final m in extras)
                    SizedBox(
                      height: AppSizes.minTap,
                      child: OutlinedButton(
                        key: Key('extra-$m'),
                        onPressed: () => screenTime.grantExtra(m),
                        child: Text('+$m min'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The sound effects switch (PRC-11).
class _SoundSection extends ConsumerStatefulWidget {
  const _SoundSection();

  @override
  ConsumerState<_SoundSection> createState() => _SoundSectionState();
}

class _SoundSectionState extends ConsumerState<_SoundSection> {
  bool? _on;

  @override
  void initState() {
    super.initState();
    ref.read(usageRepositoryProvider).soundOn().then((on) {
      if (mounted) setState(() => _on = on);
    });
  }

  Future<void> _set(bool on) async {
    setState(() => _on = on);
    await ref.read(usageRepositoryProvider).setSoundOn(on);
  }

  @override
  Widget build(BuildContext context) {
    final on = _on;
    return SwitchListTile(
      key: const Key('sound-switch'),
      secondary: Icon(on == false ? Icons.volume_off : Icons.volume_up),
      title: const Text('Sound effects'),
      subtitle: const Text('Short sounds for answers and finished rounds'),
      value: on ?? true,
      onChanged: on == null ? null : _set,
    );
  }
}

/// Opens SCR-12; shows the nickname and year (PRO-01, PRO-02).
class _ProfileTile extends ConsumerWidget {
  const _ProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(childProfileProvider).value;
    return ListTile(
      key: const Key('open-profile'),
      minTileHeight: AppSizes.minTap,
      leading: const Icon(Icons.face),
      title: const Text('Child profile'),
      subtitle: Text(
        p == null ? 'Not set yet' : '${p.nickname} · P${p.schoolYear}',
        key: const Key('profile-subtitle'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.profile),
    );
  }
}

/// Opens SCR-15, where the parent can open a locked School topic (PRC-14).
class _TopicLocksTile extends StatelessWidget {
  const _TopicLocksTile();

  @override
  Widget build(BuildContext context) => ListTile(
    key: const Key('open-topic-locks'),
    minTileHeight: AppSizes.minTap,
    leading: const Icon(Icons.lock_open),
    title: const Text('School topics'),
    subtitle: const Text('See which topics are locked and open any of them'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.go(Routes.topicLocks),
  );
}
