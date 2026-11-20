import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/profile_repository.dart';
import '../../domain/family.dart';
import '../../domain/profile.dart';
import '../../domain/setup.dart';
import '../../providers.dart';
import '../../ui/avatars.dart';
import '../../ui/theme.dart';
import '../parent/children_screen.dart' show familyChanged;
import '../profile/child_form.dart';
import 'setup_controller.dart';
import 'setup_frame.dart';

/// The children named so far (child 1 stays blank until the first is
/// added, FEAT-25 AD-2).
Future<List<FamilyChild>> namedChildren(WidgetRef ref) async => [
  for (final c in await ref.read(childRepositoryProvider).all())
    if (c.nickname.isNotEmpty) c,
];

/// Step 4 (SET-05, FAM-01, AD-8): add up to 4 children with the SCR-12
/// fields; at least one is needed to go on.
class ChildrenStep extends ConsumerStatefulWidget {
  const ChildrenStep({super.key});

  @override
  ConsumerState<ChildrenStep> createState() => _ChildrenStepState();
}

class _ChildrenStepState extends ConsumerState<ChildrenStep> {
  List<FamilyChild>? _kids;

  /// The form is open: editing that child, or 0 while adding one.
  int? _editing;
  ChildProfile? _initial;
  String _avatar = ChildProfile.defaultAvatar;
  ChildProfile? _draft;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload(openIfEmpty: true);
  }

  ProfileRepository _profiles(int id) => ProfileRepository(
    ref.read(databaseProvider),
    clock: ref.read(clockProvider),
    childId: id,
  );

  Future<void> _reload({bool openIfEmpty = false}) async {
    final kids = await namedChildren(ref);
    if (!mounted) return;
    setState(() {
      _kids = kids;
      _busy = false;
    });
    if (openIfEmpty && kids.isEmpty) _open(0);
  }

  Future<void> _open(int id) async {
    final kids = await ref.read(childRepositoryProvider).all();
    final p = id == 0 ? null : await _profiles(id).load();
    if (!mounted) return;
    setState(() {
      _editing = id;
      _initial = p;
      _draft = p;
      _error = null;
      _avatar =
          p?.avatar ??
          nextAvatar(
            kids.where((c) => c.nickname.isNotEmpty).map((c) => c.avatar),
          );
    });
  }

  Future<void> _save() async {
    final p = _draft;
    if (p == null) return;
    setState(() => _busy = true);
    try {
      final all = await ref.read(childRepositoryProvider).all();
      final blank = all.where((c) => c.nickname.isEmpty).firstOrNull;
      if (_editing != 0) {
        await _profiles(_editing!).save(p);
      } else if (blank != null) {
        // The first child fills the blank child 1 (FEAT-25 AD-2).
        await _profiles(blank.id).save(p);
      } else {
        await ref.read(childRepositoryProvider).add(p);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not save. Try again.';
        });
      }
      return;
    }
    if (!mounted) return;
    await familyChanged(ref);
    setState(() => _editing = null);
    await _reload();
  }

  Future<void> _remove(int id) async {
    setState(() => _busy = true);
    final repo = ref.read(childRepositoryProvider);
    // No PIN: it's the parent's own fresh setup (AD-8). The last child
    // can't go, so she is emptied instead.
    if ((await repo.all()).length <= 1) {
      await repo.blank(id);
    } else {
      await repo.remove(id);
    }
    if (!mounted) return;
    await familyChanged(ref);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(setupControllerProvider.notifier);
    final kids = _kids;
    final editing = _editing != null;
    final Widget body;
    if (kids == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (editing) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChildForm(
            key: ValueKey('setup-form-$_editing'),
            initial: _initial,
            avatar: _avatar,
            foldLevels: true,
            onChanged: (p) => setState(() => _draft = p),
          ),
          if (_error != null)
            Text(
              _error!,
              key: const Key('profile-error'),
              style: setupBodyStyle.copyWith(color: AppColors.berry),
            ),
          const SizedBox(height: AppSizes.gap),
          Wrap(
            spacing: AppSizes.gap,
            runSpacing: AppSizes.gap,
            children: [
              SizedBox(
                height: AppSizes.minTap,
                child: FilledButton(
                  key: const Key('setup-save-child'),
                  onPressed: _draft != null && !_busy ? _save : null,
                  child: const Text('Save child'),
                ),
              ),
              if (kids.isNotEmpty)
                SizedBox(
                  height: AppSizes.minTap,
                  child: TextButton(
                    key: const Key('setup-cancel-child'),
                    onPressed: () => setState(() => _editing = null),
                    child: const Text('Cancel'),
                  ),
                ),
            ],
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in kids)
            Card(
              key: Key('setup-child-${c.id}'),
              margin: const EdgeInsets.only(bottom: AppSizes.gap),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.gap / 2),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSizes.gap,
                  runSpacing: AppSizes.gap / 2,
                  children: [
                    AvatarCircle(c.avatar, size: AppSizes.minTap),
                    Text(
                      '${c.nickname} · P${c.schoolYear}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(
                      height: AppSizes.minTap,
                      child: OutlinedButton(
                        key: Key('setup-edit-${c.id}'),
                        onPressed: _busy ? null : () => _open(c.id),
                        child: const Text('Edit'),
                      ),
                    ),
                    SizedBox(
                      height: AppSizes.minTap,
                      child: TextButton(
                        key: Key('setup-remove-${c.id}'),
                        onPressed: _busy ? null : () => _remove(c.id),
                        child: const Text('Remove'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (kids.length < maxChildren)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                height: AppSizes.minTap,
                child: OutlinedButton.icon(
                  key: const Key('setup-add-child'),
                  onPressed: _busy ? null : () => _open(0),
                  icon: const Icon(Icons.person_add),
                  label: Text(
                    kids.isEmpty ? 'Add a child' : 'Add another child',
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return SetupFrame(
      step: SetupStep.children,
      icon: Icons.face,
      title: editing
          ? (_editing == 0 ? 'Add a child' : 'Edit child')
          : 'Your children',
      subtitle:
          'Add each child who will play (up to $maxChildren). '
          'You can change this later in the parent area.',
      onBack: _busy || editing ? null : controller.back,
      onNext: !editing && !_busy && (kids?.isNotEmpty ?? false)
          ? () => controller.next()
          : null,
      body: body,
    );
  }
}
