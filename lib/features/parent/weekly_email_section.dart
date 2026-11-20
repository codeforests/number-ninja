import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/sync/server_client.dart';
import '../../domain/plus.dart';
import '../../providers.dart';
import 'plus_screen.dart';

/// SCR-13's "Weekly progress email" switch (FEAT-31 WE-12): on only with
/// Plus and a verified email; writes the device's time zone when turned on
/// and refreshes it when it changed (WE-4).
class WeeklyEmailSection extends ConsumerStatefulWidget {
  const WeeklyEmailSection({super.key, required this.email});

  final String email;

  @override
  ConsumerState<WeeklyEmailSection> createState() => _WeeklyEmailState();
}

class _WeeklyEmailState extends ConsumerState<WeeklyEmailSection> {
  bool? _value;
  bool _busy = false;
  String? _error;
  bool _tzChecked = false;

  int get _tz => ref.read(tzOffsetProvider).inMinutes;

  Future<void> _set(bool on) async {
    setState(() {
      _value = on;
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(serverClientProvider)
          .setWeeklyEmail(on: on, tzMinutes: on ? _tz : null);
    } on Object {
      if (!mounted) return;
      setState(() {
        _value = null;
        _error = "Couldn't reach BrainBubblz. Try again when online.";
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _refreshTz(WeeklyEmailSetting s) {
    if (_tzChecked) return;
    _tzChecked = true;
    if (s.on && s.tzMinutes != _tz) {
      ref
          .read(serverClientProvider)
          .setWeeklyEmail(on: true, tzMinutes: _tz)
          .ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plus = ref.watch(plusProvider);
    final setting = ref.watch(weeklyEmailProvider);
    final scheme = Theme.of(context).colorScheme;
    final s = setting.value;
    if (s != null && plus) _refreshTz(s);

    final String subtitle;
    var enabled = false;
    if (setting.hasError) {
      subtitle = 'Connect to the internet to change this.';
    } else if (s != null && !s.verified) {
      subtitle = 'Verify your email first to get weekly emails.';
    } else {
      subtitle =
          "Every Monday morning, a short summary of each child's week, "
          'sent to ${widget.email}.';
      enabled = s != null && plus && !_busy;
    }
    final value = plus && s != null && s.verified && (_value ?? s.on);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          key: const Key('weekly-email'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Weekly progress email'),
          subtitle: Text(subtitle, key: const Key('weekly-email-note')),
          value: value,
          onChanged: enabled ? _set : null,
        ),
        if (_error != null)
          Text(
            _error!,
            key: const Key('weekly-email-error'),
            style: TextStyle(color: scheme.error),
          ),
        if (!plus && s != null && s.verified)
          const PlusCard(
            feature: PlusFeature.weeklyEmail,
            text: 'The weekly progress email comes with BrainBubblz Plus.',
          ),
      ],
    );
  }
}
