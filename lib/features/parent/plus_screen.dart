import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app.dart';
import '../../data/purchase_service.dart';
import '../../data/sync/server_client.dart';
import '../../domain/report.dart' show reportDate;
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
/// [PurchaseService] (PD-10), and "Have an invitation code?" (FEAT-36
/// IC-8).
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

  Future<void> _redeem() async {
    final until = await showDialog<DateTime>(
      context: context,
      builder: (_) => const _InviteDialog(),
    );
    if (until == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('invite-done'),
        content: Text(
          'Plus until ${reportDate(until.toLocal())}, from an invitation. '
          'Enjoy!',
        ),
      ),
    );
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
    // IC-8: free, or Plus from an invitation (never on top of a gift or a
    // store subscription).
    final invited = plusActive(cache, now) && cache!.source == 'invite';
    final showInvite =
        signedIn && ref.watch(inviteCodesAllowedProvider) && (!plus || invited);
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
          if (showInvite) ...[
            const SizedBox(height: AppSizes.gap),
            StatsCard(
              child: InkWell(
                key: const Key('plus-invite'),
                onTap: _redeem,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSizes.minTap),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, color: AppColors.sun),
                      const SizedBox(width: AppSizes.gap / 2),
                      Expanded(
                        child: Text(
                          invited
                              ? 'Have another invitation code?'
                              : 'Have an invitation code?',
                          style: StatsText.body,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

/// What each refusal says (IC-8).
const inviteFailureText = {
  InviteFailure.notFound:
      "We couldn't find that code. Check the letters and try again.",
  InviteFailure.expired: 'This code has expired.',
  InviteFailure.usedUp:
      'This code has been used by as many families as it allows.',
  InviteFailure.alreadyUsed: "You've already used this code.",
  InviteFailure.alreadyPlus:
      'You already have Plus, so keep this code for another family.',
  InviteFailure.unverified: 'Please verify your email first (see Account).',
  InviteFailure.tooMany: 'Too many tries. Wait a minute and try again.',
  InviteFailure.offline:
      "Couldn't reach BrainBubblz. Check the internet and try again.",
};

/// Asks for a code and redeems it (IC-8). Pops with the new Plus end date;
/// a refusal stays in the dialog.
class _InviteDialog extends ConsumerStatefulWidget {
  const _InviteDialog();

  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _field = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _use() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final code = normaliseInviteCode(_field.text);
    final result = await ref.read(serverClientProvider).redeemInvite(code);
    final e = result.entitlement;
    final accountId = ref.read(accountProvider).account?.id;
    if (e != null && accountId != null) {
      await ref.read(plusRepositoryProvider).storeEntitlement(accountId, e);
      await ref.read(plusControllerProvider.notifier).check();
      if (mounted) Navigator.of(context).pop(e.until ?? DateTime.now());
      return;
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = inviteFailureText[result.failure ?? InviteFailure.offline];
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = !_sending && inviteCodeComplete(_field.text);
    return AlertDialog(
      title: const Text('Invitation code'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Type the code a friend gave you. It gives your family '
              'BrainBubblz Plus.',
              style: StatsText.body,
            ),
            const SizedBox(height: AppSizes.gap / 2),
            TextField(
              key: const Key('invite-field'),
              controller: _field,
              autofocus: true,
              enabled: !_sending,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(hintText: 'ABCD-EFGH'),
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => ready ? _use() : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSizes.gap / 2),
              Text(
                _error!,
                key: const Key('invite-error'),
                style: StatsText.body.copyWith(color: AppColors.berry),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('invite-cancel'),
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('invite-use'),
          onPressed: ready ? _use : null,
          child: Text(_sending ? 'Checking…' : 'Use code'),
        ),
      ],
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
