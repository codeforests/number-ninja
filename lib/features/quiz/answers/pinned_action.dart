import 'package:material_ui/material_ui.dart';

/// [content] above [action] (Check or Next). Given a bounded height (the
/// phone layout, FEAT-19), the content scrolls on its own and [action]
/// stays in view; unbounded (the tablet, inside a scroll view), both sit at
/// their natural size.
class PinnedAction extends StatelessWidget {
  const PinnedAction({
    super.key,
    required this.content,
    required this.action,
    required this.gap,
  });

  final Widget content;
  final Widget action;
  final double gap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (box.hasBoundedHeight)
          Flexible(child: SingleChildScrollView(child: content))
        else
          content,
        SizedBox(height: gap),
        action,
      ],
    ),
  );
}
