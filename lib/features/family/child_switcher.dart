import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/family.dart';
import '../../providers.dart';
import '../../ui/avatars.dart';
import '../../ui/layout.dart';
import '../../ui/theme.dart';

/// The parent switcher (FEAT-25, FAM-05): in the app bar of SCR-09, SCR-11
/// and SCR-16, it shows the child the parent area acts on and changes her.
/// Data providers watch the current child, so the screen reloads by itself.
/// Nothing shows with one child. In `features/` rather than `lib/ui`
/// (AD-15): it reads providers.
class ChildSwitcher extends ConsumerWidget {
  const ChildSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kids = ref.watch(childrenProvider).value;
    if (kids == null || kids.length < 2) return const SizedBox.shrink();
    final current = ref.watch(currentChildProvider);
    final i = kids.indexWhere((c) => c.id == current);
    final shown = i < 0 ? kids.first : kids[i];
    final narrow = compact(MediaQuery.sizeOf(context));
    return PopupMenuButton<int>(
      key: const Key('parent-child-switch'),
      tooltip: 'Change child',
      initialValue: shown.id,
      onSelected: (id) => ref.read(currentChildProvider.notifier).select(id),
      itemBuilder: (_) => [
        for (final (n, c) in kids.indexed)
          PopupMenuItem(
            key: Key('parent-child-${c.id}'),
            value: c.id,
            child: Row(
              children: [
                AvatarCircle(c.avatar, size: AppSizes.avatarSmall * 0.8),
                const SizedBox(width: AppSizes.gap / 2),
                Text(displayName(c.nickname, n)),
              ],
            ),
          ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap / 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarCircle(shown.avatar, size: AppSizes.avatarSmall * 0.8),
              if (!narrow) ...[
                const SizedBox(width: AppSizes.gap / 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.minTap * 3,
                  ),
                  child: Text(
                    displayName(shown.nickname, i < 0 ? 0 : i),
                    key: const Key('parent-child-name'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
