import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/bank_validator.dart';
import 'package:number_ninja/domain/topics.dart';

import '../../tool/bank/bank.dart';
import '../../tool/bank/generator.dart';

void main() {
  test('fnv1a is the published 32-bit FNV-1a', () {
    expect(fnv1a(''), 0x811c9dc5);
    expect(fnv1a('a'), 0xe40c292c);
    expect(fnv1a('foobar'), 0xbf9cf968);
  });

  test('building twice gives the same text (AC-3)', () {
    expect(encodeBank(buildFor('p1')), encodeBank(buildFor('p1')));
  });

  test('an extra template leaves every other question unchanged (AC-4)', () {
    final before = buildBank(allTemplates, handwritten: allHandwritten);
    final dummy = Template(
      'p1.place',
      'dummy',
      5,
      (r, level) => Draft.number(
        'Dummy ${r.nextInt(1000000)}?',
        1,
        explanation: 'Dummy.',
      ),
    );
    final after = buildBank([
      dummy,
      ...allTemplates,
    ], handwritten: allHandwritten);
    final old = {for (final q in after.questions) q.id: q.toJson()};
    for (final q in before.questions) {
      expect(old[q.id], q.toJson(), reason: q.id);
    }
    expect(after.questions.length, before.questions.length + 5);
  });

  test('a template that cannot find new questions fails loudly', () {
    final stuck = Template(
      'p1.place',
      'stuck',
      2,
      (r, level) => Draft.number('Same?', 1, explanation: 'Same.'),
    );
    expect(() => runTemplate(stuck), throwsStateError);
  });

  test('a template can throw away a draw with retry()', () {
    var calls = 0;
    final t = Template('p1.place', 'retry', 1, (r, level) {
      if (calls++ == 0) retry();
      return Draft.number('Q?', 1, explanation: 'E.');
    });
    expect(runTemplate(t).single.id, 'p1.place.retry.001');
  });

  test('drag items never start in the answer order', () {
    final d = Draft.drag(
      Random(1),
      'Order',
      [1, 2],
      const [],
      explanation: 'E.',
    );
    expect(d.drag!.items, isNot(['1', '2']));
  });

  for (final track in ['p1']) {
    test('$track topics: valid, at least 40 each, all levels', () {
      final bank = buildFor(track);
      final mine = [
        for (final t in topics)
          if (t.id.startsWith(track)) t,
      ];
      expect(validateBank(bank, topicList: mine), isEmpty);
      for (final t in mine) {
        expect(bank.byTopic[t.id]!.length, greaterThanOrEqualTo(40));
      }
    });
  }
}
