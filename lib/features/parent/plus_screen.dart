import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/purchase_service.dart';
import '../../domain/plus.dart';
import '../../providers.dart';
import '../../ui/theme.dart';
import 'stats_view.dart';

/// What Plus adds, as SCR-20 lists it (PD-1).
const plusAdds = [
  'Revision rounds that practise her weak spots and recent mistakes',
  'PDF reports, the day-by-day view and weekly trends',
  'New questions from BrainBubblz as they come out',
  'Up to 4 children on one account',
];

/// SCR-20 BrainBubblz Plus, inside the PIN-protected parent area (FEAT-30
/// PD-9): status, what Plus adds, "Check again" and the buy area from
/// [PurchaseService] (PD-10).
class PlusScreen extends ConsumerStatefulWidget {
  const PlusScreen({super.key});

  @override
  ConsumerState<PlusScreen> createState() => _PlusScreenState();
}

class _PlusScreenState extends ConsumerState<PlusScreen> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    await ref.read(plusControllerProvider.notifier).check();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(accountProvider.select((s) => s.signedIn));
    final plus = ref.watch(plusProvider);
    final cache = ref.watch(plusCacheProvider).value;
    final now = ref.watch(clockProvider)();
    final line = plusStatusLine(cache, now);
    // A test may turn Plus on without a cache row.
    final status = plus && !plusActive(cache, now)
        ? 'You have BrainBubblz Plus.'
        : line.status;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          key: const Key('back-parent'),
          tooltip: 'Back',
          onPressed: () => context.go(Routes.parent),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('BrainBubblz Plus'),
      ),
      body: ListView(
        key: const Key('plus-screen'),
        padding: const EdgeInsets.all(AppSizes.gap),
        children: [
          StatsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!signedIn) ...[
                  const Text(
                    'Sign in to use Plus.',
                    key: Key('plus-status'),
                    style: StatsText.heading,
                  ),
                  const SizedBox(height: AppSizes.gap / 2),
                  const Text(
                    'Plus belongs to your BrainBubblz account, so it works '
                    'on every tablet you sign in on.',
                    style: StatsText.muted,
                  ),
                  const SizedBox(height: AppSizes.gap),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      key: const Key('plus-sign-in'),
                      onPressed: () => context.go(Routes.account),
                      child: const Text('Sign in'),
                    ),
                  ),
                ] else ...[
                  Text(
                    status,
                    key: const Key('plus-status'),
                    style: StatsText.heading,
                  ),
                  if (line.checked != null)
                    Text(
                      line.checked!,
                      key: const Key('plus-checked'),
                      style: StatsText.muted,
                    ),
                  const SizedBox(height: AppSizes.gap),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      key: const Key('plus-check'),
                      onPressed: _checking ? null : _check,
                      icon: const Icon(Icons.refresh),
                      label: Text(_checking ? 'Checking…' : 'Check again'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gap),
          const Text('What Plus adds', style: StatsText.heading),
          const SizedBox(height: AppSizes.gap / 2),
          StatsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in plusAdds)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.gap / 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.leaf),
                        const SizedBox(width: AppSizes.gap / 2),
                        Expanded(child: Text(item, style: StatsText.body)),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSizes.gap / 2),
                const Text(
                  'Losing Plus never deletes anything: her progress, badges '
                  'and children stay, and come back when Plus does.',
                  style: StatsText.muted,
                ),
              ],
            ),
          ),
          if (signedIn && !plus) ...[
            const SizedBox(height: AppSizes.gap),
            const _BuyArea(),
          ],
        ],
      ),
    );
  }
}

/// The buy area (PD-10): "coming soon" until FEAT-35 adds a store.
class _BuyArea extends ConsumerWidget {
  const _BuyArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(purchaseServiceProvider);
    if (!store.available) {
      return const StatsCard(
        child: Text(
          'Buying Plus in the app is coming soon.',
          key: Key('plus-coming-soon'),
          style: StatsText.body,
        ),
      );
    }
    return FutureBuilder<List<PlusOffer>>(
      future: store.offers(),
      builder: (context, snap) => StatsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final o in snap.data ?? const <PlusOffer>[])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.gap / 4),
                child: FilledButton(
                  key: Key('plus-buy-${o.id}'),
                  onPressed: () async {
                    final out = await store.buy(o);
                    if (out == PurchaseOutcome.bought) {
                      await ref.read(plusControllerProvider.notifier).check();
                    }
                  },
                  child: Text('${o.title}, ${o.price}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A parent-side card where a Plus feature would be (PD-9): says the
/// feature comes with Plus and opens SCR-20. Only inside the PIN area.
class PlusCard extends StatelessWidget {
  const PlusCard({super.key, required this.feature, required this.text});

  final PlusFeature feature;
  final String text;

  @override
  Widget build(BuildContext context) => StatsCard(
    key: Key('plus-card-${feature.name}'),
    child: InkWell(
      onTap: () => context.go(Routes.plus),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTap),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: AppColors.sun),
            const SizedBox(width: AppSizes.gap / 2),
            Expanded(child: Text(text, style: StatsText.body)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}
