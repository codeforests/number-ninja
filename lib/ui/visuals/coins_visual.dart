import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'visual_frame.dart';

/// Singapore coins, biggest first.
class CoinsVisual extends StatelessWidget {
  const CoinsVisual({super.key, required this.cents});

  final List<int> cents;

  static double _diameter(int c) => switch (c) {
    5 => 64,
    10 => 72,
    20 => 80,
    50 => 90,
    _ => 100,
  };

  @override
  Widget build(BuildContext context) {
    final sorted = [...cents]..sort((a, b) => b.compareTo(a));
    final width = sorted.fold(0.0, (s, c) => s + _diameter(c) + 12);
    return VisualFrame(
      width: width < 120 ? 120 : width,
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final c in sorted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _Coin(c, _diameter(c)),
            ),
        ],
      ),
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin(this.cents, this.size);

  final int cents;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gold = cents == 5 || cents >= 100;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gold ? AppColors.coinGold : AppColors.coinSilver,
        border: Border.all(color: AppColors.muted, width: 3),
      ),
      child: Text(
        cents >= 100 ? '\$${cents ~/ 100}' : '$cents¢',
        style: visualText,
      ),
    );
  }
}
