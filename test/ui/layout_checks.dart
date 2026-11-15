import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Child-screen sizes in dp for NFR-09 (AC-6): phone and small tablet in
/// both orientations, and the 12-inch tablet.
const layoutSizes = <Size>[
  Size(640, 360),
  Size(360, 640),
  Size(960, 600),
  Size(600, 960),
  Size(1280, 800),
  Size(800, 1280),
];

/// The extra case: the landscape tablet at text scale 1.3.
const scaledSize = Size(1280, 800);
const scaledText = 1.3;

/// [dp] as the physical size the harness takes (device pixel ratio 2).
Size physical(Size dp) => dp * 2;

/// Sets the text scale for the rest of the test.
void setTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// No layout exception (e.g. a RenderFlex overflow) was thrown, the keyed
/// widgets that are on screen don't overlap pairwise, and each lies within
/// the screen's width (NFR-09).
void expectNoOverlap(WidgetTester tester, List<String> keys) {
  expect(tester.takeException(), isNull);
  final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
  final rects = <String, Rect>{
    for (final k in keys)
      if (find.byKey(Key(k)).evaluate().isNotEmpty)
        k: tester.getRect(find.byKey(Key(k))),
  };
  for (final MapEntry(key: k, value: r) in rects.entries) {
    expect(r.left, greaterThanOrEqualTo(-0.5), reason: '$k starts off screen');
    expect(r.right, lessThanOrEqualTo(width + 0.5), reason: '$k is too wide');
  }
  final list = rects.entries.toList();
  for (var i = 0; i < list.length; i++) {
    for (var j = i + 1; j < list.length; j++) {
      final overlap = list[i].value.intersect(list[j].value);
      expect(
        overlap.width > 0.5 && overlap.height > 0.5,
        isFalse,
        reason:
            '${list[i].key} ${list[i].value} overlaps '
            '${list[j].key} ${list[j].value}',
      );
    }
  }
}
