import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../domain/family.dart';
import '../../providers.dart';
import '../../ui/avatars.dart';
import '../../ui/kid_background.dart';
import '../../ui/theme.dart';
import '../screen_time/screen_time_controller.dart';

/// SCR-17 "Who's playing?" (FEAT-25, FAM-02): one big card per child.
/// Picking one makes her the current child and goes home.
class WhoScreen extends ConsumerWidget {
  const WhoScreen({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref, int id) async {
    await ref.read(currentChildProvider.notifier).select(id);
    // Her own minutes and lock before home shows (FAM-04).
    await ref.read(screenTimeProvider).settled;
    ref.read(appSessionProvider).childChosen();
    if (context.mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final children = ref.watch(childrenProvider).value ?? const [];
    return PopScope(
      canPop: false,
      child: KidBackground(
        scene: KidScene.home,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.gap * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Who's playing?",
                      key: const Key('who-title'),
                      style: theme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.gap * 2),
                    Wrap(
                      spacing: AppSizes.gap * 2,
                      runSpacing: AppSizes.gap * 2,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final (i, c) in children.indexed)
                          _ChildCard(
                            child: c,
                            name: displayName(c.nickname, i),
                            onTap: () => _pick(context, ref, c.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.name,
    required this.onTap,
  });

  final FamilyChild child;
  final String name;
  final VoidCallback onTap;

  static const width = 200.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        color: AppColors.card,
        child: InkWell(
          key: Key('who-${child.id}'),
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.gap * 1.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarCircle(child.avatar, size: AppSizes.avatarLarge),
                const SizedBox(height: AppSizes.gap),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
