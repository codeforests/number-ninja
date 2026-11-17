import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/profile.dart';
import '../../domain/topics.dart';
import '../../providers.dart';
import '../../ui/theme.dart';

/// SCR-12: child profile (PRO-01). [firstRun] is the step after SCR-01
/// (PRO-02); otherwise it is opened from SCR-11 and goes back there.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.firstRun});

  final bool firstRun;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nickname = TextEditingController();
  int? _year;
  int? _schoolStart;
  int? _olympiadStart;
  bool _loaded = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nickname.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(profileRepositoryProvider).load();
    if (!mounted) return;
    setState(() {
      if (p != null) {
        _nickname.text = p.nickname;
        _year = p.schoolYear;
        _schoolStart = p.schoolStartLevel;
        _olympiadStart = p.olympiadStartLevel;
      }
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  bool get _valid => _year != null && nicknameError(_nickname.text) == null;

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(profileRepositoryProvider)
          .save(
            ChildProfile(
              nickname: _nickname.text.trim(),
              schoolYear: _year!,
              schoolStartLevel: _schoolStart,
              olympiadStartLevel: _olympiadStart,
            ),
          );
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
    ref.invalidate(childProfileProvider);
    ref.read(appSessionProvider).profileSaved();
    context.go(widget.firstRun ? Routes.home : Routes.parent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final nickError = _nickname.text.isEmpty
        ? null
        : nicknameError(_nickname.text);
    final draft = _year == null
        ? null
        : ChildProfile(
            nickname: '',
            schoolYear: _year!,
            schoolStartLevel: _schoolStart,
            olympiadStartLevel: _olympiadStart,
          );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.firstRun
            ? null
            : IconButton(
                key: const Key('back-parent'),
                tooltip: 'Back',
                onPressed: () => context.go(Routes.parent),
                icon: const Icon(Icons.arrow_back),
              ),
        title: const Text('Child profile'),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.gap * 1.5),
              children: [
                if (widget.firstRun)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.gap),
                    child: Text(
                      'Tell BrainBubblz a little about your child, so each '
                      'topic starts at the right level. You can change this '
                      'later in the parent area.',
                      style: theme.bodyLarge,
                    ),
                  ),
                TextField(
                  key: const Key('profile-nickname'),
                  controller: _nickname,
                  maxLength: maxNicknameLength,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nickname',
                    helperText: 'A nickname, not her real name',
                    errorText: nickError,
                  ),
                ),
                const SizedBox(height: AppSizes.gap),
                Text('School year', style: theme.titleMedium),
                const SizedBox(height: AppSizes.gap / 2),
                Wrap(
                  spacing: AppSizes.gap / 2,
                  runSpacing: AppSizes.gap / 2,
                  children: [
                    for (final y in schoolYears)
                      _Choice(
                        key: Key('year-$y'),
                        label: 'P$y',
                        selected: _year == y,
                        onTap: () => setState(() => _year = y),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.gap * 1.5),
                Text('Starting level', style: theme.titleMedium),
                Text(
                  'Where a topic she has never played starts. After her first '
                  'round the level follows her stars.',
                  style: theme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSizes.gap / 2),
                _StartRow(
                  name: 'school',
                  label: 'School',
                  value: _schoolStart,
                  onChanged: (v) => setState(() => _schoolStart = v),
                ),
                const SizedBox(height: AppSizes.gap / 2),
                _StartRow(
                  name: 'olympiad',
                  label: 'Olympiad',
                  value: _olympiadStart,
                  onChanged: (v) => setState(() => _olympiadStart = v),
                ),
                if (draft != null) ...[
                  const SizedBox(height: AppSizes.gap / 2),
                  Text(
                    _summary(draft),
                    key: const Key('profile-summary'),
                    style: theme.bodyMedium,
                  ),
                ],
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
                      onPressed: _valid && !_busy ? _save : null,
                      child: Text(widget.firstRun ? 'Save and start' : 'Save'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// What the choices mean for her own school year's topics.
  static String _summary(ChildProfile p) {
    final ownYear = topics.where((t) => topicYear(t) == p.schoolYear);
    final parts = <String>[
      if (ownYear.isNotEmpty)
        'P${p.schoolYear} topics start at level ${startLevel(p, ownYear.first)}',
      for (final y in [1, 2])
        if (y < p.schoolYear)
          'P$y topics at level '
              '${startLevel(p, topics.firstWhere((t) => topicYear(t) == y))}',
      'Olympiad at level '
          '${startLevel(p, topics.firstWhere((t) => t.track == Track.olympiad))}',
    ];
    return '${parts.join(', ')}.';
  }
}

/// "Automatic" or level 1–3 for one track.
class _StartRow extends StatelessWidget {
  const _StartRow({
    required this.name,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String name;
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.gap / 2,
      runSpacing: AppSizes.gap / 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: AppSizes.minTap * 2,
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        _Choice(
          key: Key('start-$name-auto'),
          label: 'Automatic',
          selected: value == null,
          onTap: () => onChanged(null),
        ),
        for (final l in [1, 2, 3])
          _Choice(
            key: Key('start-$name-$l'),
            label: 'Level $l',
            selected: value == l,
            onTap: () => onChanged(l),
          ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = Size(AppSizes.minTap, AppSizes.minTap);
    final child = Text(label);
    return Semantics(
      selected: selected,
      child: selected
          ? FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: size),
              onPressed: onTap,
              icon: const Icon(Icons.check),
              label: child,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: size),
              onPressed: onTap,
              child: child,
            ),
    );
  }
}
