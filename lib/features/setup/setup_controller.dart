import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/setup.dart';
import '../../providers.dart';

/// The live setup step (SCR-19, FEAT-26). Every move is saved first, in one
/// transaction with the step's own [write] (AD-3), so a kill resumes here.
class SetupController extends Notifier<SetupStep> {
  @override
  SetupStep build() => ref.read(appSessionProvider).setupStep ?? SetupStep.done;

  Future<void> go(SetupStep to, {Future<void> Function()? write}) async {
    await ref.read(setupRepositoryProvider).advance(to, write: write);
    if (ref.mounted) state = to;
  }

  /// The next step; a family brought back from the account skips the
  /// children and time steps (AD-7).
  Future<void> next({bool restored = false, Future<void> Function()? write}) =>
      go(nextStep(state, restored: restored), write: write);

  Future<void> back() => go(backStep(state));

  /// "Start playing" (AD-11): setup is done for good.
  Future<void> finish() => ref.read(setupRepositoryProvider).finish();
}

final setupControllerProvider = NotifierProvider<SetupController, SetupStep>(
  SetupController.new,
);
