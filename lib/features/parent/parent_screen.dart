import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../providers.dart';
import '../../ui/theme.dart';

/// SCR-11: parent area. FEAT-01 has Change PIN only; FEAT-05..07 add more.
class ParentScreen extends ConsumerWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent area'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.gap),
            child: FilledButton(
              key: const Key('parent-done'),
              onPressed: () {
                ref.read(appSessionProvider).lockParent();
                context.go(Routes.home);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.gap),
        children: [
          ListTile(
            key: const Key('change-pin'),
            minTileHeight: AppSizes.minTap,
            leading: const Icon(Icons.password),
            title: const Text('Change PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.changePin),
          ),
        ],
      ),
    );
  }
}
