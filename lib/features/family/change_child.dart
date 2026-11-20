import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/child_repository.dart';
import '../../providers.dart';

/// Whether SCR-17 shows by itself (cold launch, leaving the parent area):
/// with 2+ children, unless "Ask for PIN to change child" is on (AD-4).
Future<bool> pickerShows(ChildRepository repo) async =>
    (await repo.all()).length >= 2 && !await repo.switchNeedsPin();

/// The home chip and SCR-07's "Change child" (FEAT-25 AD-4): SCR-17, after
/// the PIN when the parent asked for it.
Future<void> changeChild(BuildContext context, WidgetRef ref) async {
  final needsPin = await ref.read(childRepositoryProvider).switchNeedsPin();
  if (!context.mounted) return;
  if (needsPin) {
    context.go(Routes.pinForChild);
    return;
  }
  ref.read(appSessionProvider).chooseChild();
  context.go(Routes.who);
}

/// SCR-11 "Done": locks the parent area and goes home, through SCR-17 when
/// it shows by itself (AD-4).
Future<void> leaveParentArea(BuildContext context, WidgetRef ref) async {
  final session = ref.read(appSessionProvider);
  final choose = await pickerShows(ref.read(childRepositoryProvider));
  session.lockParent();
  if (choose) session.chooseChild();
  if (context.mounted) context.go(choose ? Routes.who : Routes.home);
}
