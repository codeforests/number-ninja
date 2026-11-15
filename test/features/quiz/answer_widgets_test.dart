import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/features/quiz/answers/drag_answer.dart';
import 'package:number_ninja/features/quiz/answers/mcq_answer.dart';
import 'package:number_ninja/features/quiz/answers/number_answer.dart';
import 'package:number_ninja/ui/theme.dart';

/// AC-2 interactions on each answer widget alone.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: Center(child: SizedBox(width: 600, child: child)),
        ),
      ),
    );
  }

  testWidgets('MCQ: tapping an option submits it', (tester) async {
    final got = <String>[];
    await pump(
      tester,
      McqAnswer(options: const ['1/3', '1/5', 'Equal'], onSubmit: got.add),
    );
    expect(find.byType(FilledButton), findsNWidgets(3));
    await tester.tap(find.byKey(const Key('option-2')));
    expect(got, ['Equal']);
  });

  testWidgets('number: keypad with . and backspace, Check submits', (
    tester,
  ) async {
    final got = <String>[];
    await pump(tester, NumberAnswer(onSubmit: got.add));
    bool checkEnabled() =>
        tester.widget<FilledButton>(find.byKey(const Key('check'))).enabled;
    String display() => tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const Key('number-display')),
            matching: find.byType(Text),
          ),
        )
        .data!;

    expect(checkEnabled(), isFalse);
    for (final k in ['3', 'dot', '6', '9', 'back', 'dot', '0']) {
      await tester.tap(find.byKey(Key('key-$k')));
      await tester.pump();
    }
    expect(display(), '3.60'); // a second '.' is ignored
    expect(checkEnabled(), isTrue);
    await tester.tap(find.byKey(const Key('check')));
    expect(got, ['3.60']);
  });

  testWidgets('number: at most 6 characters', (tester) async {
    final got = <String>[];
    await pump(tester, NumberAnswer(onSubmit: got.add));
    for (var i = 0; i < 8; i++) {
      await tester.tap(find.byKey(const Key('key-7')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('check')));
    expect(got, ['777777']);
  });

  testWidgets('drag: dragging chips onto boxes fills them', (tester) async {
    final got = <List<String>>[];
    await pump(
      tester,
      DragAnswer(items: const ['30', '10', '20'], slots: 2, onSubmit: got.add),
    );
    bool checkEnabled() =>
        tester.widget<FilledButton>(find.byKey(const Key('check'))).enabled;

    await tester.drag(
      find.byKey(const Key('chip-1')),
      tester.getCenter(find.byKey(const Key('slot-0'))) -
          tester.getCenter(find.byKey(const Key('chip-1'))),
    );
    await tester.pumpAndSettle();
    expect(checkEnabled(), isFalse);
    await tester.drag(
      find.byKey(const Key('chip-0')),
      tester.getCenter(find.byKey(const Key('slot-1'))) -
          tester.getCenter(find.byKey(const Key('chip-0'))),
    );
    await tester.pumpAndSettle();
    expect(checkEnabled(), isTrue);
    await tester.tap(find.byKey(const Key('check')));
    expect(got.single, ['10', '30']);
  });

  testWidgets('drag: tapping chips fills the first empty box; tapping a '
      'filled box returns its chip', (tester) async {
    final got = <List<String>>[];
    await pump(
      tester,
      DragAnswer(
        items: const ['5', '5', '7'], // duplicates are separate chips
        slots: 3,
        onSubmit: got.add,
      ),
    );
    Future<void> tap(String key) async {
      await tester.tap(find.byKey(Key(key)));
      await tester.pump();
    }

    await tap('chip-2');
    await tap('chip-0');
    await tap('slot-0'); // sends '7' back
    expect(
      find.descendant(
        of: find.byKey(const Key('slot-0')),
        matching: find.text('7'),
      ),
      findsNothing,
    );
    await tap('chip-1'); // fills slot 0 again
    await tap('chip-2'); // '7' is back and tappable
    await tap('check');
    expect(got.single, ['5', '5', '7']);
  });
}
