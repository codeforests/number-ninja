import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../ui/kid_background.dart';
import '../../app.dart';
import '../../ui/theme.dart';

/// SCR-07: the day's screen time is used up (TIM-02). Only a parent can
/// add time, through the PIN; Android back stays here.
class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
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
                    const Icon(
                      Icons.bedtime,
                      size: 120,
                      color: AppColors.ninja,
                    ),
                    const SizedBox(height: AppSizes.gap),
                    Text(
                      "Time's up for today!",
                      key: const Key('lock-title'),
                      style: theme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.gap / 2),
                    Text(
                      'Come back tomorrow for more maths.',
                      style: theme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.gap * 2),
                    SizedBox(
                      height: AppSizes.minTap,
                      child: OutlinedButton.icon(
                        key: const Key('lock-parent'),
                        onPressed: () => context.go(Routes.pinEntry),
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Parent'),
                      ),
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
