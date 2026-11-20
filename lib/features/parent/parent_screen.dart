import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/bank_store.dart';
import '../../data/sync/server_client.dart';
import '../../domain/screen_time.dart';
import '../../providers.dart';
import '../family/change_child.dart';
import '../family/child_switcher.dart';
import '../../domain/family.dart';
import '../../ui/layout.dart';
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
          const ChildSwitcher(),
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.gap),
            child: FilledButton(
              key: const Key('parent-done'),
              // The child-sized default is too big for a phone's app bar
              // (FEAT-19).
              style: compact(MediaQuery.sizeOf(context))
                  ? FilledButton.styleFrom(
                      minimumSize: const Size(AppSizes.minTap * 1.5, 48),
                    )
                  : null,
              onPressed: () => leaveParentArea(context, ref),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.gap),
        children: [
          const _PlusTile(),
          const _ProfileTile(),
          const _ChildrenTile(),
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
          const _ExportTile(),
          const Divider(height: AppSizes.gap * 2),
          const _ScreenTimeSection(),
          const Divider(height: AppSizes.gap * 2),
          const _SoundSection(),
          const _SwitchPinSection(),
          const Divider(height: AppSizes.gap * 2),
          const _AccountTile(),
          const _ServerSection(),
          const _BankTile(),
          const _CrashReportsTile(),
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

/// "Ask for PIN to change child" (FEAT-25 AD-4), only with 2+ children.
/// Device-only, like the PIN.
class _SwitchPinSection extends ConsumerStatefulWidget {
  const _SwitchPinSection();

  @override
  ConsumerState<_SwitchPinSection> createState() => _SwitchPinSectionState();
}

class _SwitchPinSectionState extends ConsumerState<_SwitchPinSection> {
  bool? _on;

  @override
  void initState() {
    super.initState();
    ref.read(childRepositoryProvider).switchNeedsPin().then((on) {
      if (mounted) setState(() => _on = on);
    });
  }

  Future<void> _set(bool on) async {
    setState(() => _on = on);
    await ref.read(childRepositoryProvider).setSwitchNeedsPin(on);
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(childrenProvider).value?.length ?? 0;
    if (count < 2) return const SizedBox.shrink();
    return SwitchListTile(
      key: const Key('switch-needs-pin'),
      secondary: const Icon(Icons.switch_account),
      title: const Text('Ask for PIN to change child'),
      subtitle: const Text('Otherwise each child picks herself or himself'),
      value: _on ?? false,
      onChanged: _on == null ? null : _set,
    );
  }
}

/// "Send crash reports" (FEAT-24 AD-2, CRS-05): on by default, this device
/// only; off deletes unsent reports.
class _CrashReportsTile extends ConsumerStatefulWidget {
  const _CrashReportsTile();

  @override
  ConsumerState<_CrashReportsTile> createState() => _CrashReportsTileState();
}

class _CrashReportsTileState extends ConsumerState<_CrashReportsTile> {
  bool? _on;

  @override
  void initState() {
    super.initState();
    ref.read(crashRepositoryProvider).enabled().then((on) {
      if (mounted) setState(() => _on = on);
    });
  }

  Future<void> _set(bool on) async {
    setState(() => _on = on);
    await ref.read(crashRepositoryProvider).setEnabled(on);
  }

  @override
  Widget build(BuildContext context) => SwitchListTile(
    key: const Key('crash-reports-switch'),
    secondary: const Icon(Icons.bug_report_outlined),
    title: const Text('Send crash reports'),
    subtitle: const Text(
      'Helps us fix problems. No names or account details are sent.',
    ),
    value: _on ?? true,
    onChanged: _on == null ? null : _set,
  );
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

/// Opens SCR-18, where the parent adds, edits and removes children
/// (FEAT-25, FAM-01).
/// PDF export (FEAT-07); needs Plus, else opens SCR-20 (FEAT-30 PD-1).
class _ExportTile extends ConsumerWidget {
  const _ExportTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plus = ref.watch(plusProvider);
    return ListTile(
      key: const Key('export-report'),
      minTileHeight: AppSizes.minTap,
      leading: const Icon(Icons.picture_as_pdf),
      title: const Text('Export PDF report'),
      subtitle: Text(
        plus ? 'Share or save a summary' : 'PDF reports come with Plus',
        key: const Key('export-subtitle'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => plus ? showExportSheet(context) : context.go(Routes.plus),
    );
  }
}

/// Opens SCR-20 (FEAT-30 PD-9).
class _PlusTile extends ConsumerWidget {
  const _PlusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plus = ref.watch(plusProvider);
    return ListTile(
      key: const Key('open-plus'),
      minTileHeight: AppSizes.minTap,
      leading: const Icon(Icons.workspace_premium, color: AppColors.sun),
      title: const Text('BrainBubblz Plus'),
      subtitle: Text(
        plus ? 'Plus is on' : 'Free plan: see what Plus adds',
        key: const Key('plus-subtitle'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.plus),
    );
  }
}

class _ChildrenTile extends ConsumerWidget {
  const _ChildrenTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kids = ref.watch(childrenProvider).value ?? const <FamilyChild>[];
    return ListTile(
      key: const Key('open-children'),
      minTileHeight: AppSizes.minTap,
      leading: const Icon(Icons.groups),
      title: const Text('Children'),
      subtitle: Text(
        kids.length < 2
            ? 'Add a brother or sister'
            : [for (final (i, c) in kids.indexed) displayName(c.nickname, i)]
                  .join(', '),
        key: const Key('children-subtitle'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.children),
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

/// Opens SCR-13 (FEAT-13); shows the signed-in email. Reading the account
/// state is local only (NFR-11).
class _AccountTile extends ConsumerWidget {
  const _AccountTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider).account;
    return ListTile(
      key: const Key('account-row'),
      minTileHeight: AppSizes.minTap,
      leading: const Icon(Icons.account_circle_outlined),
      title: const Text('Account'),
      subtitle: Text(
        account?.email ?? 'Not signed in',
        key: const Key('account-row-subtitle'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.account),
    );
  }
}

/// FEAT-12: the sync server's hostname and a check the parent starts. No
/// network call until "Check" is tapped (NFR-11).
class _ServerSection extends ConsumerStatefulWidget {
  const _ServerSection();

  @override
  ConsumerState<_ServerSection> createState() => _ServerSectionState();
}

class _ServerSectionState extends ConsumerState<_ServerSection> {
  ServerHealth? _health;
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    final health = await ref.read(serverClientProvider).health();
    if (mounted) {
      setState(() {
        _health = health;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(serverClientProvider).config;
    final scheme = Theme.of(context).colorScheme;
    final status = switch (_health) {
      ServerHealth.ok => ('Connected', AppColors.leaf),
      ServerHealth.unreachable => (
        "Can't reach the server. Practice still works offline.",
        scheme.error,
      ),
      ServerHealth.notConfigured || null => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          key: const Key('server-row'),
          minTileHeight: AppSizes.minTap,
          leading: const Icon(Icons.cloud_outlined),
          title: const Text('Server'),
          subtitle: Text(
            // The address stays out of sight (Ken, 2026-11-17).
            config.isConfigured ? 'Set up' : 'Not set up',
            key: const Key('server-host'),
          ),
          trailing: config.isConfigured
              ? OutlinedButton(
                  key: const Key('server-check'),
                  onPressed: _checking ? null : _check,
                  child: Text(_checking ? 'Checking…' : 'Check'),
                )
              : null,
        ),
        if (status != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap),
            child: Text(
              status.$1,
              key: const Key('server-status'),
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: status.$2),
            ),
          ),
      ],
    );
  }
}

/// "Version 2 (downloaded) · checked today, 9:12 am · up to date" (BNK-12).
String bankStatusText(ActiveBank active, BankCheckState check, DateTime now) {
  final source = active.source == BankSource.bundled
      ? 'built in'
      : 'downloaded';
  final parts = ['Version ${active.bank.version} ($source)'];
  final at = check.checkedAt;
  if (at == null) {
    parts.add('not checked yet');
  } else {
    final today = DateTime(now.year, now.month, now.day);
    final when = switch (today
        .difference(DateTime(at.year, at.month, at.day))
        .inDays) {
      0 => 'today',
      1 => 'yesterday',
      _ => DateFormat('d MMM').format(at),
    };
    parts.add(
      'checked $when, ${DateFormat('h:mm a').format(at).toLowerCase()}',
    );
  }
  final note = check.note;
  if (note != null && note.isNotEmpty) parts.add(note);
  return parts.join(' · ');
}

/// FEAT-15 (BNK-12): the bank in use, the last check and "Check now".
class _BankTile extends ConsumerStatefulWidget {
  const _BankTile();

  @override
  ConsumerState<_BankTile> createState() => _BankTileState();
}

class _BankTileState extends ConsumerState<_BankTile> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    await ref.read(bankCheckProvider)(force: true, now: true);
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final configured = ref.watch(serverClientProvider).config.isConfigured;
    final plus = ref.watch(plusProvider);
    final status = ref.watch(bankStatusProvider);
    final text = switch (status) {
      AsyncData(value: (final active, final check)) => bankStatusText(
        active,
        check,
        ref.watch(clockProvider)(),
      ),
      AsyncError() => "Can't read the question bank",
      _ => '…',
    };
    return ListTile(
      key: const Key('bank-tile'),
      minTileHeight: AppSizes.minTap,
      leading: const Icon(Icons.library_books_outlined),
      title: const Text('Question bank'),
      subtitle: Text(
        plus ? text : '$text. Question updates come with Plus',
        key: const Key('bank-status'),
      ),
      // Bank updates need Plus (FEAT-30 PD-11): free opens SCR-20.
      onTap: plus ? null : () => context.go(Routes.plus),
      trailing: configured && plus
          ? OutlinedButton(
              key: const Key('bank-check-now'),
              onPressed: _checking ? null : _check,
              child: Text(_checking ? 'Checking…' : 'Check now'),
            )
          : null,
    );
  }
}
