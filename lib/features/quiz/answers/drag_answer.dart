import 'package:material_ui/material_ui.dart';

import '../../../ui/theme.dart';

/// [slots] empty boxes and the [items] as chips (PRC-03). Drag a chip onto a
/// box, or tap a chip to fill the first empty box; tap a filled box to send
/// its chip back. Check is enabled when every box is filled.
class DragAnswer extends StatefulWidget {
  const DragAnswer({
    super.key,
    required this.items,
    required this.slots,
    required this.onSubmit,
  });

  final List<String> items;
  final int slots;
  final ValueChanged<List<String>> onSubmit;

  @override
  State<DragAnswer> createState() => _DragAnswerState();
}

class _DragAnswerState extends State<DragAnswer> {
  /// Item index in each slot, or null when empty.
  late List<int?> _filled = List.filled(widget.slots, null);

  @override
  void didUpdateWidget(DragAnswer old) {
    super.didUpdateWidget(old);
    if (old.slots != widget.slots || old.items != widget.items) {
      _filled = List.filled(widget.slots, null);
    }
  }

  bool _used(int item) => _filled.contains(item);

  void _put(int slot, int item) => setState(() {
    final from = _filled.indexOf(item);
    if (from >= 0) _filled[from] = null;
    _filled[slot] = item;
  });

  void _tapChip(int item) {
    final slot = _filled.indexOf(null);
    if (slot >= 0) _put(slot, item);
  }

  void _clear(int slot) => setState(() => _filled[slot] = null);

  @override
  Widget build(BuildContext context) {
    final complete = !_filled.contains(null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSizes.gap,
          runSpacing: AppSizes.gap,
          children: [for (var s = 0; s < widget.slots; s++) _slot(s)],
        ),
        const SizedBox(height: AppSizes.gap * 2),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSizes.gap,
          runSpacing: AppSizes.gap,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              _used(i)
                  ? _ChipBox(
                      key: Key('chip-$i'),
                      text: widget.items[i],
                      ghost: true,
                    )
                  : Draggable<int>(
                      key: Key('chip-$i'),
                      data: i,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _ChipBox(text: widget.items[i]),
                      ),
                      childWhenDragging: _ChipBox(
                        text: widget.items[i],
                        ghost: true,
                      ),
                      child: GestureDetector(
                        onTap: () => _tapChip(i),
                        child: _ChipBox(text: widget.items[i]),
                      ),
                    ),
          ],
        ),
        const SizedBox(height: AppSizes.gap * 2),
        FilledButton(
          key: const Key('check'),
          onPressed: complete
              ? () =>
                    widget.onSubmit([for (final i in _filled) widget.items[i!]])
              : null,
          child: const Text('Check'),
        ),
      ],
    );
  }

  Widget _slot(int s) {
    final item = _filled[s];
    return DragTarget<int>(
      key: Key('slot-$s'),
      onAcceptWithDetails: (d) => _put(s, d.data),
      builder: (context, candidates, _) => GestureDetector(
        onTap: item == null ? null : () => _clear(s),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTap * 1.5,
            minHeight: AppSizes.minTap * 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: candidates.isNotEmpty
                ? AppColors.ninjaLight
                : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(color: AppColors.ninja, width: 3),
          ),
          child: Text(
            item == null ? '' : widget.items[item],
            style: const TextStyle(
              fontSize: AppText.heading,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipBox extends StatelessWidget {
  const _ChipBox({super.key, required this.text, this.ghost = false});

  final String text;
  final bool ghost;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(
      minWidth: AppSizes.minTap * 1.5,
      minHeight: AppSizes.minTap * 1.2,
    ),
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: ghost ? AppColors.paper : AppColors.sun,
      borderRadius: BorderRadius.circular(AppRadii.button),
      border: Border.all(
        color: ghost ? AppColors.ninjaLight : AppColors.sun,
        width: 3,
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: AppText.heading,
        fontWeight: FontWeight.w700,
        color: ghost ? AppColors.ninjaLight : AppColors.ink,
      ),
    ),
  );
}
