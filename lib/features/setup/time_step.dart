import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/usage_repository.dart';
import '../../domain/family.dart';
import '../../domain/screen_time.dart';
import '../../domain/setup.dart';
import '../../providers.dart';
import '../../ui/avatars.dart';
import '../../ui/theme.dart';
import 'children_step.dart' show namedChildren;
import 'setup_controller.dart';
import 'setup_frame.dart';

/// Step 5 (TIM-04, PRC-11, AD-10): each child's daily limit, and one sound
/// switch for every child set up here.
class TimeStep extends ConsumerStatefulWidget {
  const TimeStep({super.key});

  @override
  ConsumerState<TimeStep> createState() => _TimeStepState();
}

class _TimeStepState extends ConsumerState<TimeStep> {
  List<FamilyChild>? _kids;
  final _limits = <int, int>{};
  bool _sound = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final kids = await namedChildren(ref);
    final rows = [for (final c in kids) await db.child(c.id)];
    if (!mounted) return;
    setState(() {
      _kids = kids;
      for (final r in rows) {
        _limits[r.id] = r.dailyLimitMin;
      }
      _sound = rows.isEmpty || rows.first.soundOn;
    });
  }

  UsageRepository _usage(int id) => UsageRepository(
    ref.read(databaseProvider),
    clock: ref.read(clockProvider),
    childId: id,
  );

  Future<void> _next() async {
    setState(() => _busy = true);
    await ref
        .read(setupControllerProvider.notifier)
        .next(
          write: () async {
            for (final e in _limits.entries) {
              final u = _usage(e.key);
              await u.setDailyLimit(e.value);
              await u.setSoundOn(_sound);
            }
          },
        );
  }

  void _step(int id, int by) => setState(
    () => _limits[id] = (_limits[id]! + by).clamp(minDailyLimit, maxDailyLimit),
  );

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(setupControllerProvider.notifier);
    final kids = _kids;
    final theme = Theme.of(context).textTheme;
    return SetupFrame(
      step: SetupStep.time,
      icon: Icons.hourglass_bottom,
      title: 'Daily time and sound',
      subtitle:
          'We suggest 20 minutes a day (you can change it any time). '
          'When the time is up, only your PIN can add more.',
      onBack: _busy ? null : controller.back,
      onNext: kids == null || _busy ? null : _next,
      body: kids == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in kids)
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.gap),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.gap / 2),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSizes.gap,
                        runSpacing: AppSizes.gap / 2,
                        children: [
                          AvatarCircle(c.avatar),
                          Text(c.nickname, style: theme.titleLarge),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.outlined(
                                key: Key('setup-limit-${c.id}-minus'),
                                iconSize: 32,
                                constraints: const BoxConstraints(
                                  minWidth: AppSizes.minTap,
                                  minHeight: AppSizes.minTap,
                                ),
                                tooltip: '5 minutes less',
                                onPressed: _limits[c.id]! <= minDailyLimit
                                    ? null
                                    : () => _step(c.id, -5),
                                icon: const Icon(Icons.remove),
                              ),
                              SizedBox(
                                width: AppSizes.minTap * 1.6,
                                child: Text(
                                  '${_limits[c.id]} min',
                                  key: Key('setup-limit-${c.id}-value'),
                                  textAlign: TextAlign.center,
                                  style: theme.titleLarge,
                                ),
                              ),
                              IconButton.outlined(
                                key: Key('setup-limit-${c.id}-plus'),
                                iconSize: 32,
                                constraints: const BoxConstraints(
                                  minWidth: AppSizes.minTap,
                                  minHeight: AppSizes.minTap,
                                ),
                                tooltip: '5 minutes more',
                                onPressed: _limits[c.id]! >= maxDailyLimit
                                    ? null
                                    : () => _step(c.id, 5),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                SwitchListTile(
                  key: const Key('setup-sound'),
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: AppSizes.minTap,
                  title: const Text('Sound effects', style: setupBodyStyle),
                  subtitle: const Text(
                    'Small sounds for right and wrong answers',
                  ),
                  value: _sound,
                  onChanged: _busy ? null : (v) => setState(() => _sound = v),
                ),
              ],
            ),
    );
  }
}
