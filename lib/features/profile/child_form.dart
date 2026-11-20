import 'package:material_ui/material_ui.dart';

import '../../domain/family.dart';
import '../../domain/profile.dart';
import '../../domain/topics.dart';
import '../../ui/avatars.dart';
import '../../ui/theme.dart';

/// The SCR-12 child fields (nickname, picture, school year, starting
/// levels), shared by SCR-12 and the setup Children step (FEAT-26 AD-8).
/// [onChanged] gets the profile whenever it is valid, else null. With
/// [foldLevels] the starting levels sit under a closed "More options".
class ChildForm extends StatefulWidget {
  const ChildForm({
    super.key,
    this.initial,
    required this.avatar,
    required this.onChanged,
    this.foldLevels = false,
  });

  final ChildProfile? initial;
  final String avatar;
  final ValueChanged<ChildProfile?> onChanged;
  final bool foldLevels;

  @override
  State<ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends State<ChildForm> {
  final _nickname = TextEditingController();
  int? _year;
  int? _schoolStart;
  int? _olympiadStart;
  late String _avatar;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _avatar = p?.avatar ?? widget.avatar;
    if (p != null) {
      _nickname.text = p.nickname;
      _year = p.schoolYear;
      _schoolStart = p.schoolStartLevel;
      _olympiadStart = p.olympiadStartLevel;
    }
    _nickname.addListener(() => _set(() {}));
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  void _set(VoidCallback change) {
    setState(change);
    final valid = _year != null && nicknameError(_nickname.text) == null;
    widget.onChanged(
      valid
          ? ChildProfile(
              nickname: _nickname.text.trim(),
              schoolYear: _year!,
              schoolStartLevel: _schoolStart,
              olympiadStartLevel: _olympiadStart,
              avatar: _avatar,
            )
          : null,
    );
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
    final levels = <Widget>[
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
        onChanged: (v) => _set(() => _schoolStart = v),
      ),
      const SizedBox(height: AppSizes.gap / 2),
      _StartRow(
        name: 'olympiad',
        label: 'Olympiad',
        value: _olympiadStart,
        onChanged: (v) => _set(() => _olympiadStart = v),
      ),
      if (draft != null) ...[
        const SizedBox(height: AppSizes.gap / 2),
        Text(
          _summary(draft),
          key: const Key('profile-summary'),
          style: theme.bodyMedium,
        ),
      ],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        Text('Picture', style: theme.titleMedium),
        const SizedBox(height: AppSizes.gap / 2),
        Wrap(
          spacing: AppSizes.gap / 2,
          runSpacing: AppSizes.gap / 2,
          children: [
            for (final a in avatarIds)
              _AvatarChoice(
                id: a,
                selected: _avatar == a,
                onTap: () => _set(() => _avatar = a),
              ),
          ],
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
                onTap: () => _set(() => _year = y),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.gap * 1.5),
        if (widget.foldLevels)
          ExpansionTile(
            key: const Key('child-more-options'),
            tilePadding: EdgeInsets.zero,
            minTileHeight: AppSizes.minTap,
            title: Text('More options', style: theme.titleMedium),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.only(bottom: AppSizes.gap),
            children: levels,
          )
        else
          ...levels,
      ],
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

/// One built-in avatar to pick (FEAT-25 AD-7), ringed when chosen.
class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = Theme.of(context).colorScheme.primary;
    return Semantics(
      selected: selected,
      button: true,
      label: 'Picture $id',
      child: InkWell(
        key: Key('avatar-$id'),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: AppSizes.minTap,
          height: AppSizes.minTap,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? ring : Colors.transparent,
              width: 4,
            ),
          ),
          child: AvatarCircle(id, size: AppSizes.minTap - 14),
        ),
      ),
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
