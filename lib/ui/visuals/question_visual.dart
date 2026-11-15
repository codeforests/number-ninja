import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'bar_model_visual.dart';
import 'clock_visual.dart';
import 'coins_visual.dart';
import 'figure_visual.dart';
import 'fraction_visual.dart';
import 'groups_visual.dart';
import 'picture_graph_visual.dart';
import 'ruler_visual.dart';
import 'shapes_visual.dart';

/// Every visual `kind` this app draws (`tool/bank/README.md`).
const visualKinds = {
  'clock',
  'coins',
  'fraction',
  'ruler',
  'shapes',
  'figure',
  'groups',
  'pictureGraph',
  'barModel',
};

/// Draws a question's visual (PRC-10), scaled to the box it is given.
/// An unknown kind draws nothing (and asserts in debug).
class QuestionVisual extends StatelessWidget {
  const QuestionVisual(this.visual, {super.key});

  final Map<String, dynamic> visual;

  @override
  Widget build(BuildContext context) {
    final v = visual;
    List<T> list<T>(String key) => [for (final e in v[key] as List) e as T];
    switch (v['kind']) {
      case 'clock':
        return ClockVisual(h: v['h'] as int, m: v['m'] as int);
      case 'coins':
        return CoinsVisual(cents: list<int>('cents'));
      case 'fraction':
        return FractionVisual(
          parts: v['parts'] as int,
          shaded: v['shaded'] as int,
        );
      case 'ruler':
        return RulerVisual(cm: v['cm'] as int);
      case 'shapes':
        return ShapesVisual(
          items: [
            for (final i in list<Map>('items'))
              (shape: i['shape'] as String, color: i['color'] as String),
          ],
        );
      case 'figure':
        return FigureVisual(name: v['name'] as String);
      case 'groups':
        return GroupsVisual(
          groups: v['groups'] as int,
          each: v['each'] as int,
          icon: v['icon'] as String,
        );
      case 'pictureGraph':
        return PictureGraphVisual(
          title: v['title'] as String,
          scale: v['scale'] as int,
          icon: v['icon'] as String,
          rows: [
            for (final r in list<Map>('rows'))
              (label: r['label'] as String, count: r['count'] as int),
          ],
        );
      case 'barModel':
        return BarModelVisual(
          total: v['total'] as int?,
          bars: [
            for (final b in list<Map>('bars'))
              (
                label: b['label'] as String,
                units: b['units'] as int,
                unitValue: b['unitValue'] as int?,
                known: b['known'] as int?,
              ),
          ],
        );
    }
    assert(false, 'unknown visual kind ${v['kind']}');
    if (kDebugMode) debugPrint('unknown visual kind ${v['kind']}');
    return const SizedBox.shrink();
  }
}
