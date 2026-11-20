/// First-run setup steps (FEAT-26, SET-01..07). Pure Dart.
library;

/// The setup wizard's steps in order (AD-2). The current one is saved as
/// `app_settings.setup_step` (its [name]); null there means setup is done.
enum SetupStep { welcome, pin, account, children, time, done }

/// The saved step, or null for a finished setup (or an unknown name).
SetupStep? parseStep(String? name) {
  if (name == null) return null;
  for (final s in SetupStep.values) {
    if (s.name == name) return s;
  }
  return null;
}

/// The step after [step]. A family brought back from the account skips the
/// children and time steps (AD-7). [SetupStep.done] stays put.
SetupStep nextStep(SetupStep step, {bool restored = false}) {
  if (step == SetupStep.account && restored) return SetupStep.done;
  final i = step.index + 1;
  return i < SetupStep.values.length ? SetupStep.values[i] : step;
}

/// The step before [step]; [SetupStep.welcome] stays put.
SetupStep backStep(SetupStep step) =>
    step.index == 0 ? step : SetupStep.values[step.index - 1];

/// Which progress dot [step] lights (0-based, one dot per step).
int dotIndex(SetupStep step) => step.index;

/// Number of progress dots.
const setupDots = 6;
