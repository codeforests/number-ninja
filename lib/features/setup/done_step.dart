import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/family.dart';
import '../../domain/setup.dart';
import '../../providers.dart';
import '../../ui/avatars.dart';
import '../../ui/theme.dart';
import '../family/change_child.dart' show pickerShows;
import '../home/home_screen.dart' show ParentButton;
import '../parent/children_screen.dart' show familyChanged;
import 'children_step.dart' show namedChildren;
import 'setup_controller.dart';
import 'setup_frame.dart';

/// "Mia", "Mia and Leo", "Mia, Leo and Ava".
String namesText(List<String> names) => names.length <= 1
    ? names.join()
    : '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';

/// Step 6 (SET-06, AD-11): where the parent area is, then Start playing.
class DoneStep extends ConsumerStatefulWidget {
  const DoneStep({super.key});

  @override
  ConsumerState<DoneStep> createState() => _DoneStepState();
}

class _DoneStepState extends ConsumerState<DoneStep> {
  List<FamilyChild>? _kids;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    namedChildren(ref).then((k) {
      if (mounted) setState(() => _kids = k);
    });
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    await ref.read(setupControllerProvider.notifier).finish();
    await familyChanged(ref);
    final choose = await pickerShows(ref.read(childRepositoryProvider));
    final session = ref.read(appSessionProvider);
    if (choose) session.chooseChild();
    // The router now leaves /setup: SCR-17 with 2+ children, else home.
    session.setupFinished();
  }

  @override
  Widget build(BuildContext context) {
    final kids = _kids ?? const [];
    final names = namesText([for (final c in kids) c.nickname]);
    return SetupFrame(
      step: SetupStep.done,
      icon: Icons.celebration,
      title: "You're set!",
      subtitle: names.isEmpty ? null : 'BrainBubblz is ready for $names.',
      nextKey: const Key('setup-start'),
      nextLabel: 'Start playing',
      onBack: _busy ? null : ref.read(setupControllerProvider.notifier).back,
      onNext: _kids == null || _busy ? null : _start,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            key: const Key('setup-done-children'),
            spacing: AppSizes.gap,
            runSpacing: AppSizes.gap,
            alignment: WrapAlignment.center,
            children: [
              for (final c in kids)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarCircle(c.avatar, size: AppSizes.avatarLarge),
                    Text(c.nickname, style: setupBodyStyle),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSizes.gap * 1.5),
          Card(
            key: const Key('setup-parent-button-hint'),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.gap),
              child: Column(
                children: [
                  ExcludeSemantics(
                    child: IgnorePointer(child: ParentButton(onPressed: () {})),
                  ),
                  const SizedBox(height: AppSizes.gap),
                  const Text(
                    'To change settings or see progress, tap this button on '
                    'the home screen and enter your PIN.',
                    textAlign: TextAlign.center,
                    style: setupBodyStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
