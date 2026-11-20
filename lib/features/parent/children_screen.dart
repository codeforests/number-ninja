import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/pin_repository.dart';
import '../../domain/family.dart';
import '../../providers.dart';
import '../../ui/avatars.dart';
import '../../ui/pin_pad.dart';
import '../../ui/screen_frame.dart';
import '../../ui/theme.dart';

/// SCR-18 Children (FEAT-25, FAM-01): every child, each opening SCR-12 for
/// her, and "Add child" while there are fewer than [maxChildren] (AD-1).
class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final kids = ref.watch(childrenProvider).value;
    final current = ref.watch(currentChildProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('back-parent'),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.parent),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Children'),
      ),
      body: kids == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.gap),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.gap),
                  child: Text(
                    'Up to $maxChildren children. Each has her or his own '
                    'levels, badges, progress and screen time.',
                    style: theme.bodyLarge,
                  ),
                ),
                for (final (i, c) in kids.indexed)
                  ListTile(
                    key: Key('child-${c.id}'),
                    minTileHeight: AppSizes.minTap,
                    leading: AvatarCircle(c.avatar),
                    title: Text(displayName(c.nickname, i)),
                    subtitle: Text(
                      'P${c.schoolYear}'
                      '${c.id == current ? ' · playing now' : ''}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(Routes.childProfile(c.id)),
                  ),
                if (kids.length < maxChildren)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.gap),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: AppSizes.minTap,
                        child: FilledButton.icon(
                          key: const Key('add-child'),
                          onPressed: () => context.go(Routes.newChild),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add child'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// After a child was added, removed or renamed: reloads the family and, if
/// the current child is gone, follows [ChildRepository.current] (AD-10).
Future<void> familyChanged(WidgetRef ref) async {
  final repo = ref.read(childRepositoryProvider);
  final now = await repo.current();
  if (now != ref.read(currentChildProvider)) {
    await ref.read(currentChildProvider.notifier).select(now);
  }
  ref.invalidate(childrenProvider);
  ref.invalidate(childProfileProvider);
}

/// SCR-12 "Remove child" confirm (FEAT-25 AD-10): the PIN confirms it, as
/// for a reset (PAR-10). A wrong PIN deletes nothing and counts towards the
/// PAR-03 lockout.
class RemoveChildScreen extends ConsumerStatefulWidget {
  const RemoveChildScreen({super.key, required this.childId});

  final int childId;

  @override
  ConsumerState<RemoveChildScreen> createState() => _RemoveChildState();
}

class _RemoveChildState extends ConsumerState<RemoveChildScreen> {
  String? _error;
  bool _busy = false;

  Future<void> _onPin(String pin) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(pinRepositoryProvider).verify(pin);
    if (!mounted) return;
    switch (result) {
      case PinOk():
        try {
          await ref.read(childRepositoryProvider).remove(widget.childId);
        } on StateError {
          // The last child stays (SCR-12 hides the button then).
        }
        await familyChanged(ref);
        if (ref.read(syncAccountProvider) != null) {
          // The server and her other tablets follow at the next sync.
          ref.read(syncProvider.notifier).requestSync();
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Child removed')));
        context.go(Routes.children);
      case PinWrong(:final attemptsLeft):
        setState(() {
          _busy = false;
          _error = 'Wrong PIN. $attemptsLeft tries left.';
        });
      case PinLocked():
        ref.read(appSessionProvider).lockParent();
        context.go(Routes.pinEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final kids = ref.watch(childrenProvider).value ?? const <FamilyChild>[];
    final i = kids.indexWhere((c) => c.id == widget.childId);
    final name = i < 0 ? 'this child' : displayName(kids[i].nickname, i);
    final signedIn = ref.watch(syncAccountProvider) != null;
    return ScreenFrame(
      title: 'Remove $name',
      message: _error ?? 'Enter the PIN to remove.',
      messageIsError: _error != null,
      leading: IconButton(
        key: const Key('back-profile'),
        iconSize: 40,
        tooltip: 'Cancel',
        onPressed: () => context.go(Routes.childProfile(widget.childId)),
        icon: const Icon(Icons.arrow_back),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.minTap * 8),
            child: Text(
              'This deletes $name and every answer, round, star and badge of '
              'hers. Her brothers and sisters keep theirs.'
              '${signedIn ? ' Her other tablets remove her at their next sync.' : ''}',
              key: const Key('remove-warning'),
              textAlign: TextAlign.center,
              style: theme.bodyLarge?.copyWith(color: AppColors.berry),
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          PinPad(onCompleted: _onPin, enabled: !_busy && i >= 0),
        ],
      ),
    );
  }
}
