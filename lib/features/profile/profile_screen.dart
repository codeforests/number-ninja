import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/profile_repository.dart';
import '../../domain/family.dart';
import '../../domain/profile.dart';
import '../../providers.dart';
import 'child_form.dart';
import '../parent/children_screen.dart';
import '../../ui/theme.dart';

/// SCR-12: child profile (PRO-01), opened from SCR-11 and going back
/// there (first run is the setup Children step since FEAT-26).
/// FEAT-25: [child] is `?child=` from SCR-18, a child id or `new` (add a
/// child, FAM-01), and the screen goes back to SCR-18; null edits the
/// current child.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.child});

  final String? child;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ChildProfile? _initial;
  ChildProfile? _draft;
  String _avatar = ChildProfile.defaultAvatar;

  /// The child edited, or null while adding one.
  int? _childId;
  int _siblings = 0;
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _adding => widget.child == 'new';

  String get _back => widget.child == null ? Routes.parent : Routes.children;

  ProfileRepository _repo(int id) => ProfileRepository(
    ref.read(databaseProvider),
    clock: ref.read(clockProvider),
    childId: id,
  );

  Future<void> _load() async {
    final kids = await ref.read(childRepositoryProvider).all();
    final asked = int.tryParse(widget.child ?? '');
    final id = _adding
        ? null
        : kids.any((c) => c.id == asked)
        ? asked
        : ref.read(currentChildProvider);
    final p = id == null ? null : await _repo(id).load();
    if (!mounted) return;
    setState(() {
      _childId = id;
      _siblings = kids.length;
      _avatar = id == null
          ? nextAvatar(kids.map((c) => c.avatar))
          : kids
                .firstWhere(
                  (c) => c.id == id,
                  orElse: () => const FamilyChild(
                    id: 0,
                    nickname: '',
                    schoolYear: 1,
                    avatar: ChildProfile.defaultAvatar,
                  ),
                )
                .avatar;
      _initial = p;
      _draft = p;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final profile = _draft!;
    try {
      final id = _childId;
      if (id == null) {
        await ref.read(childRepositoryProvider).add(profile);
      } else {
        await _repo(id).save(profile);
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
    if (!mounted) return;
    context.go(_back);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('back-parent'),
          tooltip: 'Back',
          onPressed: () => context.go(_back),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(_adding ? 'Add a child' : 'Child profile'),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.gap * 1.5),
              children: [
                ChildForm(
                  initial: _initial,
                  avatar: _avatar,
                  onChanged: (p) => setState(() => _draft = p),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.gap),
                    child: Text(
                      _error!,
                      key: const Key('profile-error'),
                      style: theme.bodyLarge?.copyWith(color: AppColors.berry),
                    ),
                  ),
                const SizedBox(height: AppSizes.gap * 1.5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: AppSizes.minTap,
                    child: FilledButton(
                      key: const Key('profile-save'),
                      onPressed: _draft != null && !_busy ? _save : null,
                      child: const Text('Save'),
                    ),
                  ),
                ),
                if (_childId != null && _siblings > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.gap * 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: AppSizes.minTap,
                        child: OutlinedButton.icon(
                          key: const Key('remove-child'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                          onPressed: () =>
                              context.go(Routes.removeChild(_childId!)),
                          icon: const Icon(Icons.person_remove),
                          label: const Text('Remove this child'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
