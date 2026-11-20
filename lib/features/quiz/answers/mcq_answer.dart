import 'package:material_ui/material_ui.dart';

import '../../../ui/layout.dart';
import '../../../ui/theme.dart';

/// Options as a 2×2 grid of big buttons; tapping one submits it (PRC-03).
class McqAnswer extends StatelessWidget {
  const McqAnswer({super.key, required this.options, required this.onSubmit});

  final List<String> options;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    // Less side padding and a size smaller text on a phone, so a word like
    // "mangoes" fits on one line (FEAT-19).
    final small = compact(MediaQuery.sizeOf(context));
    final rows = [
      for (var i = 0; i < options.length; i += 2)
        [for (var j = i; j < i + 2 && j < options.length; j++) j],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.gap / 2),
            child: Row(
              children: [
                for (final i in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.gap / 2,
                      ),
                      child: FilledButton.tonal(
                        key: Key('option-$i'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            AppSizes.minTap * 1.5,
                          ),
                          padding: small
                              ? const EdgeInsets.symmetric(
                                  horizontal: AppSizes.gap / 2,
                                )
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadii.button,
                            ),
                          ),
                        ),
                        onPressed: () => onSubmit(options[i]),
                        child: Text(
                          options[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: small ? AppText.body : AppText.heading,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (row.length == 1) const Spacer(),
              ],
            ),
          ),
      ],
    );
  }
}
