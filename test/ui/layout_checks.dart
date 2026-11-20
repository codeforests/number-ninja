import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/ui/theme.dart';
import 'package:number_ninja/ui/visuals/question_visual.dart';

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
/// widgets that are on screen don't overlap pairwise where they show, and each lies within
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
  // What shows: a widget inside a scroll view is clipped to it (FEAT-19's
  // phone layout scrolls the question above a pinned answer area).
  Rect visible(String k, Rect r) {
    final scroll = find.ancestor(
      of: find.byKey(Key(k)),
      matching: find.byType(Scrollable),
    );
    return scroll.evaluate().isEmpty
        ? r
        : r.intersect(tester.getRect(scroll.first));
  }

  final list = [
    for (final MapEntry(key: k, value: r) in rects.entries)
      MapEntry(k, visible(k, r)),
  ];
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

/// NFR-03 on the screen as it is: every tap target at least 64 × 64 dp and
/// every laid-out text at least 20 sp, outside drawn visuals (which scale
/// their own labels to fit) and icon glyphs. Needs semantics on.
Future<void> expectChildSizes(WidgetTester tester) async {
  await expectLater(
    tester,
    meetsGuideline(
      const MinimumTapTargetGuideline(
        size: Size(AppSizes.minTap, AppSizes.minTap),
        link: 'NFR-03',
      ),
    ),
  );
  final skip = {
    ...find.byType(QuestionVisual).evaluate(),
    ...find.byType(Icon).evaluate(),
  };
  bool skipped(Element e) {
    var found = false;
    e.visitAncestorElements((a) {
      found = skip.contains(a);
      return !found;
    });
    return found;
  }

  final paragraphs = tester.allElements.where(
    (e) => e.renderObject is RenderParagraph && !skipped(e),
  );
  expect(paragraphs, isNotEmpty);
  for (final e in paragraphs) {
    final p = e.renderObject! as RenderParagraph;
    p.text.visitChildren((span) {
      final size = span.style?.fontSize ?? 14;
      expect(
        p.textScaler.scale(size),
        greaterThanOrEqualTo(AppText.small),
        reason: '"${span.toPlainText()}" is $size sp',
      );
      return true;
    });
  }
}

/// [key] lies wholly on screen and a tap at its centre reaches it, so it
/// can be used without scrolling.
void expectInView(WidgetTester tester, String key) {
  final f = find.byKey(Key(key));
  expect(f, findsOneWidget, reason: '$key missing');
  final view =
      Offset.zero & (tester.view.physicalSize / tester.view.devicePixelRatio);
  final r = tester.getRect(f);
  expect(
    view.contains(r.topLeft) && view.contains(r.bottomRight - Offset(1, 1)),
    isTrue,
    reason: '$key at $r is not inside $view',
  );
  final hits = tester.hitTestOnBinding(r.center).path.map((e) => e.target);
  final box = tester.renderObject(f);
  expect(hits.contains(box), isTrue, reason: '$key is covered or clipped');
}
