import 'dart:math';

import 'generator.dart';
import 'helpers.dart';

/// Olympiad templates, 4 topics (design §2). `oly.logic` and `oly.counting`
/// also have hand-written questions in handwritten.dart. Template names and
/// their order of random draws are frozen once a bank ships (BNK-05).
final olyTemplates = <Template>[
  // oly.patterns: number and shape patterns.
  Template('oly.patterns', 'next', 12, (r, level) {
    final (seq, rule) = numberPattern(r, level, 6);
    return Draft.number(
      'What number comes next? ${seq.take(5).join(', ')}, ___',
      seq[5],
      explanation: '$rule The next number is ${seq[5]}.',
    );
  }),
  Template('oly.patterns', 'missing', 12, (r, level) {
    final (seq, rule) = numberPattern(r, level, 5);
    final gap = rint(r, 1, 3);
    final shown = [for (var k = 0; k < 5; k++) k == gap ? '___' : '${seq[k]}'];
    return Draft.number(
      'Find the missing number: ${shown.join(', ')}',
      seq[gap],
      explanation: '$rule The missing number is ${seq[gap]}.',
    );
  }),
  Template('oly.patterns', 'drag', 12, (r, level) {
    final (seq, rule) = numberPattern(r, level, 6);
    final gaps = [rint(r, 1, 2), rint(r, 4, 5)];
    final shown = [
      for (var k = 0; k < 6; k++) gaps.contains(k) ? '___' : '${seq[k]}',
    ];
    final ans = [for (final g in gaps) seq[g]];
    return Draft.drag(
      r,
      'Drag the missing numbers into the pattern: ${shown.join(', ')}',
      ans,
      [ans[0] + 1, ans[1] + 2, ans[1] - 1, ans[0] * 2],
      explanation: '$rule The pattern is ${seq.join(', ')}.',
    );
  }),
  Template('oly.patterns', 'nth-shape', 12, (r, level) {
    final unit = pickN(r, shapeNames, level == 1 ? 2 : 3);
    final n = rint(r, level == 1 ? 7 : 10, level == 3 ? 40 : 20);
    final ans = unit[(n - 1) % unit.length];
    final rem = n % unit.length;
    return Draft.mcq(
      r,
      'The pattern ${unit.join(', ')} repeats over and over. '
      'What is shape number $n?',
      ans,
      [...unit, ...shapeNames],
      explanation:
          'The pattern repeats every ${unit.length} shapes. '
          '${n ~/ unit.length} full repeats make '
          '${n ~/ unit.length * unit.length} shapes, so shape $n is '
          '${rem == 0 ? 'the last one of a repeat' : 'number $rem of the next repeat'}: '
          '$ans.',
    );
  }),
  Template('oly.patterns', 'growing', 12, (r, level) {
    final c = pick(r, const [
      ('row', 'dots'),
      ('step', 'blocks'),
      ('tower', 'cubes'),
    ]);
    final first = rint(r, 1, 4), add = rint(r, 2, level == 1 ? 3 : 5);
    final n = rint(r, level == 1 ? 5 : 8, level == 3 ? 20 : 12);
    final v = first + (n - 1) * add;
    return Draft.number(
      '${cap(c.$1)} 1 has $first ${c.$2}, ${c.$1} 2 has ${first + add} '
      '${c.$2} and ${c.$1} 3 has ${first + 2 * add} ${c.$2}. The pattern '
      'goes on. How many ${c.$2} does ${c.$1} $n have?',
      v,
      check: '$first+($n-1)*$add',
      explanation:
          'Each ${c.$1} has $add more ${c.$2}. From ${c.$1} 1 to ${c.$1} $n '
          'there are ${n - 1} steps: $first + ${n - 1} × $add = $v.',
    );
  }),

  // oly.logic: ordering, ages, balances, legs.
  Template('oly.logic', 'order', 12, (r, level) {
    final n = level == 1 ? 3 : 4;
    final ppl = pickN(r, names, n); // tallest first
    final adj = pick(r, const [
      ('taller', 'tallest', 'shortest'),
      ('older', 'oldest', 'youngest'),
      ('faster', 'fastest', 'slowest'),
    ]);
    final clues = [
      for (var k = 0; k < n - 1; k++)
        '${ppl[k]} is ${adj.$1} than ${ppl[k + 1]}.',
    ];
    if (level == 3) clues.shuffle(r);
    final top = r.nextBool();
    final ans = top ? ppl.first : ppl.last;
    return Draft.mcq(
      r,
      '${clues.join(' ')} Who is the ${top ? adj.$2 : adj.$3}?',
      ans,
      ppl,
      explanation:
          'Put them in order, from ${adj.$2} to ${adj.$3}: ${ppl.join(', ')}. '
          '$ans is the ${top ? adj.$2 : adj.$3}.',
    );
  }),
  Template('oly.logic', 'ages', 12, (r, level) {
    final (name, he) = child(r);
    final sib = pick(r, const ['sister', 'brother', 'cousin']);
    if (level == 3) {
      final young = rint(r, 3, 9), gap = rint(r, 2, 6);
      final total = young * 2 + gap;
      return Draft.number(
        '$name and ${his(he)} $sib are $total years old altogether. '
        '$name is $gap years older than ${his(he)} $sib. '
        'How old is $name?',
        young + gap,
        check: '($total+$gap)/2',
        explanation:
            'Take away the difference: $total − $gap = ${total - gap}, '
            'which is two times the $sib\'s age, so the $sib is $young. '
            '$name is $young + $gap = ${young + gap}.',
      );
    }
    final age = rint(r, 5, 9), gap = rint(r, 2, 6), later = rint(r, 2, 5);
    final older = r.nextBool();
    final sAge = older ? age + gap : age - gap;
    if (sAge < 1) retry();
    if (level == 1) {
      return Draft.number(
        '$name is $age years old. ${his(he, cap: true)} $sib is $gap years '
        '${older ? 'older' : 'younger'}. How old is ${his(he)} $sib?',
        sAge,
        check: '$age${older ? '+' : '-'}$gap',
        explanation: '$age ${older ? '+' : '−'} $gap = $sAge.',
      );
    }
    return Draft.number(
      '$name is $age years old. ${his(he, cap: true)} $sib is $gap years '
      '${older ? 'older' : 'younger'}. How old will the $sib be in '
      '$later years?',
      sAge + later,
      check: '$age${older ? '+' : '-'}$gap+$later',
      explanation:
          'Now the $sib is $sAge. In $later years: $sAge + $later = '
          '${sAge + later}.',
    );
  }),
  Template('oly.logic', 'balance', 12, (r, level) {
    final things = pickN(r, const [
      ('apples', 'apple'),
      ('melons', 'melon'),
      ('plums', 'plum'),
      ('pears', 'pear'),
      ('lemons', 'lemon'),
    ], 3);
    final a = rint(r, 2, 3); // a of thing0 = 1 of thing1
    final b = rint(r, 2, level == 1 ? 3 : 5); // 1 of thing1 = b of thing2
    final k = level == 1 ? 1 : rint(r, 2, 3);
    final ask = a * k;
    final ans = k * b;
    return Draft.number(
      '$a ${things[0].$1} weigh the same as 1 ${things[1].$2}. '
      '1 ${things[1].$2} weighs the same as $b ${things[2].$1}. '
      'How many ${things[2].$1} weigh the same as $ask ${things[0].$1}?',
      ans,
      check: '$ask/$a*$b',
      explanation:
          '$ask ${things[0].$1} weigh the same as ${plural(k, things[1].$2)}. '
          '${plural(k, things[1].$2)} ${k == 1 ? 'weighs' : 'weigh'} the same '
          'as $k × $b = $ans '
          '${things[2].$1}.',
    );
  }),
  Template('oly.logic', 'legs', 12, (r, level) {
    final c = pick(r, const [
      ('chickens', 2, 'cows', 4, 'animals'),
      ('bicycles', 2, 'tricycles', 3, 'cycles'),
      ('ducks', 2, 'goats', 4, 'animals'),
    ]);
    final many = c.$1 == 'bicycles' ? 'wheels' : 'legs';
    final total = rint(r, 4, level == 1 ? 6 : 12);
    final big = rint(r, 1, total - 1);
    final legs = big * c.$4 + (total - big) * c.$2;
    return Draft.number(
      'There are some ${c.$1} and ${c.$3}. There are $total ${c.$5} and '
      '$legs $many in all. How many ${c.$3} are there?',
      big,
      check: '($legs-$total*${c.$2})/(${c.$4}-${c.$2})',
      explanation:
          'If all $total were ${c.$1}, there would be ${total * c.$2} $many. '
          'There are ${legs - total * c.$2} more. Each of the ${c.$3} adds '
          '${c.$4 - c.$2}, so there are ${legs - total * c.$2} ÷ '
          '${c.$4 - c.$2} = $big ${c.$3}.',
    );
  }),

  // oly.counting: handshakes, rectangles, digits, outfits, numbers.
  Template('oly.counting', 'handshakes', 12, (r, level) {
    final n = rint(r, 3, level == 1 ? 5 : 10);
    final c = pick(r, const [
      ('children', 'shakes hands once with every other child', 'handshakes'),
      ('teams', 'plays one game against every other team', 'games'),
      ('friends', 'sends one card to every other friend', 'cards'),
    ]);
    final cards = c.$3 == 'cards';
    final ans = cards ? n * (n - 1) : n * (n - 1) ~/ 2;
    return Draft.number(
      'There are $n ${c.$1}. Each one ${c.$2}. '
      'How many ${c.$3} are there in all?',
      ans,
      check: cards ? '$n*($n-1)' : '$n*($n-1)/2',
      explanation: cards
          ? 'Each of the $n sends ${n - 1} cards: $n × ${n - 1} = $ans.'
          : 'Each of the $n meets ${n - 1} others: $n × ${n - 1} = '
                '${n * (n - 1)}. Each ${c.$3 == 'games' ? 'game' : 'handshake'} '
                'is counted twice, so ${n * (n - 1)} ÷ 2 = $ans.',
    );
  }),
  Template('oly.counting', 'rectangles', 10, (r, level) {
    if (level == 3) {
      final n = rint(r, 2, 5);
      final terms = [for (var k = n; k >= 1; k--) k * k];
      return Draft.number(
        'A big square is made of $n by $n small squares. '
        'How many squares of any size can you find?',
        terms.fold<int>(0, (a, b) => a + b),
        check: terms.join('+'),
        explanation:
            'Count each size: ${[for (var k = 1; k <= n; k++) '${(n - k + 1) * (n - k + 1)} of size $k'].join(', ')}. '
            'Total: ${terms.reversed.join(' + ')} = ${terms.fold<int>(0, (a, b) => a + b)}.',
      );
    }
    final n = level == 1 ? rint(r, 2, 6) : rint(r, 7, 12);
    final ans = n * (n + 1) ~/ 2;
    return Draft.number(
      'A strip is made of $n squares in a row. How many rectangles can you '
      'find? (Squares count as rectangles too.)',
      ans,
      check: [for (var k = n; k >= 1; k--) '$k'].join('+'),
      explanation:
          'Count by length: $n of length 1, ${n - 1} of length 2, and so on '
          'down to 1 of length $n. ${[for (var k = n; k >= 1; k--) '$k'].join(' + ')} = $ans.',
    );
  }),
  Template('oly.counting', 'digits', 12, (r, level) {
    final last = switch (level) {
      1 => rint(r, 10, 30),
      2 => rint(r, 31, 99),
      _ => rint(r, 100, 150),
    };
    final ans = last < 100 ? 9 + (last - 9) * 2 : 9 + 180 + (last - 99) * 3;
    return Draft.number(
      'A book has $last pages, numbered 1 to $last. '
      'How many digits are printed to number all the pages?',
      ans,
      check: last < 100 ? '9+($last-9)*2' : '9+90*2+($last-99)*3',
      explanation: last < 100
          ? 'Pages 1 to 9 use 9 digits. Pages 10 to $last are ${last - 9} '
                'pages with 2 digits each: ${(last - 9) * 2}. '
                '9 + ${(last - 9) * 2} = $ans.'
          : 'Pages 1 to 9 use 9 digits, pages 10 to 99 use 90 × 2 = 180, and '
                'pages 100 to $last use ${last - 99} × 3 = ${(last - 99) * 3}. '
                'Total: $ans.',
    );
  }),
  Template('oly.counting', 'outfits', 12, (r, level) {
    final (name, he) = child(r);
    final c = pick(r, const [
      ('T-shirts', 'pairs of shorts', 'caps', 'outfits'),
      ('kinds of bread', 'kinds of filling', 'kinds of drink', 'meals'),
      ('ice cream flavours', 'kinds of cone', 'toppings', 'ice creams'),
    ]);
    final a = rint(r, 2, 5), b = rint(r, 2, 4), k = rint(r, 2, 3);
    if (level == 3) {
      return Draft.number(
        '$name has $a ${c.$1}, $b ${c.$2} and $k ${c.$3}. ${cap(he)} picks '
        'one of each. How many different ${c.$4} can $he make?',
        a * b * k,
        check: '$a*$b*$k',
        explanation: '$a × $b × $k = ${a * b * k}.',
      );
    }
    return Draft.number(
      '$name has $a ${c.$1} and $b ${c.$2}. ${cap(he)} picks one of each. '
      'How many different ${c.$4} can $he make?',
      a * b,
      check: '$a*$b',
      explanation:
          'Each of the $a ${c.$1} goes with each of the $b ${c.$2}: '
          '$a × $b = ${a * b}.',
    );
  }),
  Template('oly.counting', 'make-numbers', 10, (r, level) {
    final zero = level == 3;
    final n = level == 1 ? 3 : 4;
    final ds = zero
        ? [0, ...distinct(r, n - 1, 1, 9)..sort()]
        : (distinct(r, n, 1, 9)..sort());
    final ans = zero ? (n - 1) * (n - 1) : n * (n - 1);
    return Draft.number(
      'How many different 2-digit numbers can you make with the digits '
      '${ds.join(', ')}? Each number uses two different digits.',
      ans,
      check: zero ? '($n-1)*($n-1)' : '$n*($n-1)',
      explanation: zero
          ? 'The tens digit can be any of the ${n - 1} digits except 0. The '
                'ones digit can then be any of the ${n - 1} digits left. '
                '${n - 1} × ${n - 1} = $ans.'
          : 'There are $n choices for the tens digit and ${n - 1} for the ones '
                'digit: $n × ${n - 1} = $ans.',
    );
  }),

  // oly.models: bar models.
  Template('oly.models', 'times-total', 12, (r, level) {
    final two = pickN(r, names, 2);
    final k = rint(r, 2, level == 1 ? 3 : 5);
    final unit = rint(r, 3, level == 3 ? 30 : 15);
    final total = unit * (k + 1);
    final thing = pick(r, const ['stickers', 'marbles', 'stamps', 'beads']);
    return Draft.number(
      '${two[0]} and ${two[1]} have $total $thing altogether. ${two[0]} has '
      '$k times as many $thing as ${two[1]}. How many $thing does '
      '${two[1]} have?',
      unit,
      check: '$total/($k+1)',
      visual: {
        'kind': 'barModel',
        'bars': [
          {'label': two[0], 'units': k},
          {'label': two[1], 'units': 1},
        ],
        'total': total,
      },
      explanation:
          'Draw ${two[1]} as 1 unit and ${two[0]} as $k units: ${k + 1} '
          'units in all. ${k + 1} units = $total, so 1 unit = $total ÷ '
          '${k + 1} = $unit.',
    );
  }),
  Template('oly.models', 'more-total', 12, (r, level) {
    final two = pickN(r, names, 2);
    final small = rint(r, 10, level == 1 ? 40 : 200);
    final more = rint(r, 5, level == 1 ? 20 : 90);
    final total = small * 2 + more;
    final askBig = level == 3;
    return Draft.number(
      '${two[0]} has $more more beads than ${two[1]}. They have $total '
      'beads altogether. How many beads does '
      '${askBig ? two[0] : two[1]} have?',
      askBig ? small + more : small,
      check: askBig ? '($total-$more)/2+$more' : '($total-$more)/2',
      visual: {
        'kind': 'barModel',
        'bars': [
          {'label': two[0], 'units': 1, 'known': more},
          {'label': two[1], 'units': 1},
        ],
        'total': total,
      },
      explanation:
          'Take away the extra $more: $total − $more = ${total - more}. '
          'That is 2 equal units, so 1 unit = $small.'
          '${askBig ? ' ${two[0]} has $small + $more = ${small + more}.' : ''}',
    );
  }),
  Template('oly.models', 'times-diff', 12, (r, level) {
    final k = rint(r, 2, level == 1 ? 3 : 6);
    final unit = rint(r, 3, level == 3 ? 25 : 12);
    final diff = unit * (k - 1);
    final askRed = level == 3;
    return Draft.number(
      'A box has $k times as many red pens as blue pens. There are $diff '
      'more red pens than blue pens. How many ${askRed ? 'red' : 'blue'} '
      'pens are there?',
      askRed ? unit * k : unit,
      check: askRed ? '$diff/($k-1)*$k' : '$diff/($k-1)',
      visual: {
        'kind': 'barModel',
        'bars': [
          {'label': 'red', 'units': k},
          {'label': 'blue', 'units': 1},
        ],
      },
      explanation:
          'Red is $k units and blue is 1 unit, so the difference is '
          '${plural(k - 1, 'unit')}. ${plural(k - 1, 'unit')} = $diff, so '
          '1 unit = $unit.'
          '${askRed ? ' Red pens: $k × $unit = ${unit * k}.' : ''}',
    );
  }),
  Template('oly.models', 'label', 12, (r, level) {
    final two = pickN(r, names, 2);
    final k = rint(r, 2, level == 1 ? 3 : 5);
    final unit = rint(r, 4, level == 3 ? 25 : 12);
    return Draft.drag(
      r,
      '${two[0]} has $k times as many cards as ${two[1]}. ${two[1]} has '
      '$unit cards. Drag the numbers into the boxes: ${two[0]} has ___ '
      'cards, and they have ___ cards altogether.',
      [unit * k, unit * (k + 1)],
      [unit * (k - 1), unit + k, unit * (k + 2)],
      visual: {
        'kind': 'barModel',
        'bars': [
          {'label': two[0], 'units': k, 'unitValue': unit},
          {'label': two[1], 'units': 1, 'unitValue': unit},
        ],
      },
      explanation:
          '1 unit = $unit. ${two[0]} has $k units: $k × $unit = ${unit * k}. '
          'Altogether ${k + 1} units: ${k + 1} × $unit = ${unit * (k + 1)}.',
    );
  }),
  Template('oly.models', 'same', 12, (r, level) {
    final two = pickN(r, names, 2);
    final half = rint(r, 2, level == 1 ? 10 : 40);
    final b = rint(r, 5, level == 3 ? 200 : 60);
    final a = b + half * 2;
    return Draft.number(
      '${two[0]} has $a sweets and ${two[1]} has $b sweets. How many sweets '
      'must ${two[0]} give ${two[1]} so that they have the same number?',
      half,
      check: '($a-$b)/2',
      visual: {
        'kind': 'barModel',
        'bars': [
          {'label': two[0], 'units': 1, 'known': a - b},
          {'label': two[1], 'units': 1},
        ],
      },
      explanation:
          '${two[0]} has ${a - b} more. Giving half of the difference makes '
          'them equal: ${a - b} ÷ 2 = $half.',
    );
  }),
];

/// `his` or `her` for the pronoun [he].
String his(String he, {bool cap = false}) {
  final w = he == 'he' ? 'his' : 'her';
  return cap ? w[0].toUpperCase() + w.substring(1) : w;
}

/// The first [n] terms of a pattern suited to [level], and its rule.
(List<int>, String) numberPattern(Random r, int level, int n) {
  switch (level == 3 ? rint(r, 0, 2) : (level == 2 ? rint(r, 0, 1) : 0)) {
    case 0 when level == 1:
      final a = rint(r, 1, 20), d = rint(r, 2, 9);
      final up = r.nextBool() || a - d * n < 0;
      final s = [
        for (var k = 0; k < n; k++) up ? a + k * d : a + (n - 1) * d - k * d,
      ];
      return (s, '${up ? 'Add' : 'Take away'} $d each time.');
    case 0:
      final a = rint(r, 1, 9), m = rint(r, 2, 3);
      final s = [a];
      while (s.length < n) {
        s.add(s.last * m);
      }
      if (s.last > 2000) retry();
      return (s, 'Multiply by $m each time.');
    case 1:
      final a = rint(r, 1, 10), d = rint(r, 1, 3);
      final s = [a];
      for (var k = 1; k < n; k++) {
        s.add(s.last + d * k);
      }
      return (
        s,
        'The jumps grow by $d each time: '
            '${[for (var k = 1; k < n; k++) '+${d * k}'].join(', ')}.',
      );
    default:
      final a = rint(r, 1, 20), p = rint(r, 3, 9), q = rint(r, 1, p - 1);
      final s = [a];
      for (var k = 1; k < n; k++) {
        s.add(k.isOdd ? s.last + p : s.last - q);
      }
      return (s, 'The jumps take turns: add $p, then take away $q.');
  }
}
