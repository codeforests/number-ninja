import 'dart:math';

import 'generator.dart';
import 'helpers.dart';

/// P1 revision templates (8 topics, design §2). Template names and their
/// order of random draws are frozen once a bank ships (BNK-05).
final p1Templates = <Template>[
  // p1.place: numbers to 100.
  Template('p1.place', 'value', 12, (r, level) {
    final n = level == 1 ? rint(r, 21, 59) : rint(r, 21, 99);
    final tens = n ~/ 10, ones = n % 10;
    if (ones == 0 || ones == tens) retry();
    final askTens = level == 1 || r.nextBool();
    final d = askTens ? tens : ones;
    final v = askTens ? tens * 10 : ones;
    return Draft.mcq(
      r,
      'What is the value of the digit $d in $n?',
      v,
      [askTens ? tens : ones * 10, n, ones * 10 + tens],
      explanation:
          'In $n, the digit $d is in the ${askTens ? 'tens' : 'ones'} '
          'place, so it stands for $v.',
    );
  }),
  Template('p1.place', 'tens-ones', 12, (r, level) {
    final t = rint(r, 1, 9);
    final o = level == 3 ? rint(r, 10, 19) : rint(r, 0, 9);
    if (level == 3 && t > 8) retry();
    final total = t * 10 + o;
    return Draft.number(
      '${plural(t, 'ten')} and ${plural(o, 'one')} make ___.',
      total,
      check: '$t*10+$o',
      explanation: '${plural(t, 'ten')} is ${t * 10}. ${t * 10} + $o = $total.',
    );
  }),
  Template('p1.place', 'compare', 12, (r, level) {
    final lo = level == 3 ? rint(r, 2, 8) * 10 : 10;
    final hi = level == 3 ? lo + 9 : 99;
    final xs = distinct(r, level == 1 ? 3 : 4, lo, hi);
    final most = r.nextBool();
    final ans = most ? xs.reduce(max) : xs.reduce(min);
    return Draft.mcq(
      r,
      'Which number is the ${most ? 'greatest' : 'smallest'}: '
      '${xs.join(', ')}?',
      ans,
      [for (final x in xs) x],
      explanation:
          'Compare the tens first, then the ones. '
          '$ans is the ${most ? 'greatest' : 'smallest'}.',
    );
  }),
  Template('p1.place', 'order', 12, (r, level) {
    final xs = distinct(r, level + 2, 10, 99);
    final up = level < 3 || r.nextBool();
    final sorted = List.of(xs)..sort();
    final ans = up ? sorted : sorted.reversed.toList();
    return Draft.drag(
      r,
      'Put ${xs.join(', ')} in order, from '
      '${up ? 'smallest to greatest' : 'greatest to smallest'}.',
      ans,
      const [],
      explanation: 'Compare the tens first, then the ones: ${ans.join(', ')}.',
    );
  }),
  Template('p1.place', 'more-less', 12, (r, level) {
    final step = level == 1 ? 1 : (level == 2 ? 10 : pick(r, [1, 10]));
    final more = r.nextBool();
    final n = more ? rint(r, 11, 99 - step) : rint(r, 11 + step, 99);
    final ans = more ? n + step : n - step;
    return Draft.number(
      'What is $step ${more ? 'more' : 'less'} than $n?',
      ans,
      check: '$n${more ? '+' : '-'}$step',
      explanation:
          '$step ${more ? 'more' : 'less'} than $n is $ans. '
          '${step == 10 ? 'The tens digit changes by 1.' : 'Count on or back by 1.'}',
    );
  }),

  // p1.bonds: number bonds and missing numbers.
  Template('p1.bonds', 'missing-part', 15, (r, level) {
    final whole = switch (level) {
      1 => rint(r, 6, 10),
      2 => rint(r, 11, 20),
      _ => rint(r, 3, 10) * 10,
    };
    final step = level == 3 ? 10 : 1;
    final part = rint(r, 1, whole ~/ step - 1) * step;
    return Draft.number(
      '$part and ___ make $whole.',
      whole - part,
      check: '$whole-$part',
      explanation: '$part + ${whole - part} = $whole.',
    );
  }),
  Template('p1.bonds', 'missing-box', 15, (r, level) {
    final whole = level == 3 ? rint(r, 4, 10) * 10 : rint(r, 11, 20);
    final step = level == 3 ? 10 : 1;
    final part = rint(r, 1, whole ~/ step - 1) * step;
    final first = r.nextBool();
    return Draft.number(
      first ? '___ + $part = $whole' : '$part + ___ = $whole',
      whole - part,
      check: '$whole-$part',
      explanation:
          'Think of the number bond: $whole is $part and ${whole - part}.',
    );
  }),
  Template('p1.bonds', 'pairs', 15, (r, level) {
    final whole = [rint(r, 6, 10), rint(r, 11, 20), rint(r, 21, 50)][level - 1];
    final a = rint(r, 1, whole - 1);
    String pair(int x, int y) => '$x and $y';
    final wrong = <String>[
      pair(a, whole - a + 1),
      pair(a + 1, whole - a + 1),
      pair(a, whole - a - 1),
      if (a > 1) pair(a - 1, whole - a + 1),
    ];
    return Draft.mcq(
      r,
      'Which pair makes $whole?',
      pair(a, whole - a),
      wrong,
      explanation: '$a + ${whole - a} = $whole.',
    );
  }),
  Template('p1.bonds', 'two-bonds', 15, (r, level) {
    final whole = level == 1 ? 10 : (level == 2 ? rint(r, 11, 20) : 100);
    final step = level == 3 ? 10 : 1;
    final ps = distinct(r, 2, 1, whole ~/ step - 1).map((p) => p * step);
    final a = ps.first, b = ps.last;
    final ans = [whole - a, whole - b];
    if (ans[0] == ans[1]) retry();
    return Draft.drag(
      r,
      'Drag the missing numbers into the boxes, in order: '
      '$a + ___ = $whole, then $b + ___ = $whole.',
      ans,
      [whole - a + step, whole - b - step, a, b],
      explanation: '$a + ${ans[0]} = $whole and $b + ${ans[1]} = $whole.',
    );
  }),

  // p1.groups: multiplication and division as equal groups.
  Template('p1.groups', 'total', 15, (r, level) {
    final g = rint(r, 2, level == 1 ? 4 : 5);
    final each = level == 3 ? pick(r, [2, 5, 10]) : rint(r, 2, 5);
    final item = pick(r, const [
      ('apple', 'apple'),
      ('star', 'star'),
      ('ball', 'ball'),
      ('flower', 'flower'),
    ]);
    return Draft.number(
      'There are $g groups of $each ${item.$1}s. '
      'How many ${item.$1}s are there in all?',
      g * each,
      check: '$g*$each',
      visual: {'kind': 'groups', 'groups': g, 'each': each, 'icon': item.$2},
      explanation:
          '$g groups of $each is ${List.filled(g, '$each').join(' + ')} '
          '= ${g * each}.',
    );
  }),
  Template('p1.groups', 'share', 15, (r, level) {
    final kids = rint(r, 2, level == 1 ? 3 : 5);
    final each = rint(r, 2, level == 3 ? 10 : 5);
    final total = kids * each;
    final thing = pick(r, const ['sweets', 'stickers', 'marbles', 'cards']);
    return Draft.number(
      'Share $total $thing equally among $kids children. '
      'How many $thing does each child get?',
      each,
      check: '$total/$kids',
      explanation:
          'Put $total $thing into $kids equal groups. '
          'Each group has $each, because $kids groups of $each is $total.',
    );
  }),
  Template('p1.groups', 'make-groups', 15, (r, level) {
    final size = level == 1 ? 2 : pick(r, [2, 5, 10]);
    final groups = rint(r, 2, level == 3 ? 10 : 6);
    final total = size * groups;
    final thing = pick(r, const ['pencils', 'eggs', 'books', 'cups']);
    return Draft.mcq(
      r,
      '$total $thing are put into groups of $size. '
      'How many groups are there?',
      groups,
      [groups + 1, groups - 1, total - size, size],
      explanation: '$groups groups of $size make $total.',
    );
  }),
  Template('p1.groups', 'repeated-add', 15, (r, level) {
    final each = rint(r, 2, level == 3 ? 10 : 5);
    final g = rint(r, 2, level == 1 ? 4 : 6);
    return Draft.mcq(
      r,
      'Which is the same as ${List.filled(g, '$each').join(' + ')}?',
      '$g groups of $each',
      [
        '${g + 1} groups of $each',
        '$g groups of ${each + 1}',
        if (g > 2) '${g - 1} groups of $each',
        '$each groups of $each',
      ],
      explanation: '$each is added $g times, so it is $g groups of $each.',
    );
  }),

  // p1.money: cents and dollars.
  Template('p1.money', 'count-coins', 15, (r, level) {
    final kinds = level == 1 ? [10, 20] : [5, 10, 20, 50];
    final n = rint(r, 2, level == 3 ? 5 : 4);
    final coins = [for (var k = 0; k < n; k++) pick(r, kinds)]
      ..sort((a, b) => b - a);
    final total = coins.fold(0, (a, b) => a + b);
    if (total > 100) retry();
    return Draft.number(
      'How much money is there? Give your answer in cents.',
      total,
      check: coins.join('+'),
      visual: {'kind': 'coins', 'cents': coins},
      explanation:
          'Count from the biggest coin: '
          '${coins.map((c) => '$c¢').join(' + ')} = $total¢.',
    );
  }),
  Template('p1.money', 'notes', 15, (r, level) {
    final (name, he) = child(r);
    final a = pick(r, [5, 10, 50]);
    final n = rint(r, 1, level == 1 ? 2 : 4);
    final b = pick(r, [2, 5, 10].where((b) => b < a).toList());
    final total = a + n * b;
    return Draft.number(
      '$name has a \$$a note and ${plural(n, '\$$b note')}. '
      'How many dollars does $he have?',
      total,
      check: '$a+$n*$b',
      explanation: '\$$a + ${List.filled(n, '\$$b').join(' + ')} = \$$total.',
    );
  }),
  Template('p1.money', 'left', 15, (r, level) {
    final (name, he) = child(r);
    final has = level == 1 ? rint(r, 5, 10) * 10 : rint(r, 10, 20) * 5;
    final cost = rint(r, 1, has ~/ 5 - 1) * 5;
    final thing = pick(r, const ['a ruler', 'an eraser', 'a pencil', 'a bun']);
    return Draft.number(
      '$name has $has¢. ${cap(he)} buys $thing for $cost¢. '
      'How much money does $he have left, in cents?',
      has - cost,
      check: '$has-$cost',
      explanation: '$has¢ − $cost¢ = ${has - cost}¢.',
    );
  }),
  Template('p1.money', 'exchange', 15, (r, level) {
    final coin = pick(r, level == 1 ? [10] : [5, 10, 20, 50]);
    final target = level == 3
        ? 100 * rint(r, 1, 2)
        : coin * rint(r, 2, 100 ~/ coin);
    if (target % coin != 0 || target ~/ coin > 20) {
      retry();
    }
    final shown = money(target);
    return Draft.number(
      'How many $coin¢ coins make $shown?',
      target ~/ coin,
      check: '$target/$coin',
      explanation:
          '${target == 100 ? '\$1 is 100¢. ' : (target > 100 ? '$shown is $target¢. ' : '')}'
          '${target ~/ coin} groups of $coin¢ make $target¢.',
    );
  }),

  // p1.time: to the hour and half hour.
  Template('p1.time', 'read-clock', 15, (r, level) {
    final h = rint(r, 1, 12);
    final half = level == 1 ? false : (level == 2 ? true : r.nextBool());
    final ans = timeWords(h, half ? 30 : 0);
    return Draft.mcq(
      r,
      'What time does the clock show?',
      ans,
      [
        timeWords(h, half ? 0 : 30),
        timeWords(h % 12 + 1, half ? 30 : 0),
        timeWords((h + 10) % 12 + 1, half ? 30 : 0),
      ],
      visual: {'kind': 'clock', 'h': h, 'm': half ? 30 : 0},
      explanation: half
          ? 'The minute hand points to 6, so it is half past. '
                'The hour hand is just past $h: $ans.'
          : 'The minute hand points to 12 and the hour hand to $h: $ans.',
    );
  }),
  Template('p1.time', 'later', 15, (r, level) {
    final h = rint(r, 1, 12);
    final half = level == 3 && r.nextBool();
    final add = rint(r, 1, level == 1 ? 2 : 4);
    final end = (h + add - 1) % 12 + 1;
    final ans = timeWords(end, half ? 30 : 0);
    return Draft.mcq(
      r,
      'It is ${timeWords(h, half ? 30 : 0)}. '
      'What time will it be ${plural(add, 'hour')} later?',
      ans,
      [
        timeWords(end % 12 + 1, half ? 30 : 0),
        timeWords((end + 10) % 12 + 1, half ? 30 : 0),
        timeWords(end, half ? 0 : 30),
      ],
      explanation: 'Count on ${plural(add, 'hour')} from $h: $ans.',
    );
  }),
  Template('p1.time', 'hands', 15, (r, level) {
    final h = rint(r, 1, 12);
    final minute = level == 3 || r.nextBool();
    // At half past, the hour hand sits between two numbers: ask only o'clock.
    final half = minute && level > 1 && r.nextBool();
    final ans = minute ? (half ? 6 : 12) : h;
    return Draft.number(
      'At ${timeWords(h, half ? 30 : 0)}, which number does the '
      '${minute ? 'minute (long)' : 'hour (short)'} hand point to'
      '?',
      ans,
      explanation: minute
          ? 'At ${timeWords(h, half ? 30 : 0)}, the minute hand points '
                'to $ans.'
          : 'The hour hand points to the hour, $h.',
    );
  }),
  Template('p1.time', 'order', 15, (r, level) {
    final n = level + 2;
    // Half hours from 6 o'clock (slot 12) to half past 11 (slot 23).
    final slots = distinct(r, n, 12, 23);
    final sorted = List.of(slots)..sort();
    String w(int s) => timeWords(s ~/ 2, s.isOdd ? 30 : 0);
    final ans = [for (final s in sorted) w(s)];
    return Draft.drag(
      r,
      'These times are all in the same morning: '
      '${[for (final s in slots) w(s)].join(', ')}. '
      'Put them in order, from earliest to latest.',
      ans,
      const [],
      explanation: 'In order through the day: ${ans.join(', ')}.',
    );
  }),

  // p1.measure: length and mass.
  Template('p1.measure', 'ruler', 15, (r, level) {
    final cm = rint(r, 2, level == 1 ? 8 : 15);
    final thing = pick(r, const [
      'pencil',
      'crayon',
      'ribbon',
      'key',
      'eraser',
    ]);
    return Draft.number(
      'How long is the $thing? Give your answer in cm.',
      cm,
      visual: {'kind': 'ruler', 'cm': cm},
      explanation: 'The $thing starts at 0 and ends at $cm, so it is $cm cm.',
    );
  }),
  Template('p1.measure', 'longer', 15, (r, level) {
    final a = rint(r, 5, level == 1 ? 15 : 40);
    final d = rint(r, 2, 9);
    final longer = r.nextBool();
    final b = longer ? a + d : a - d;
    if (b <= 0) retry();
    return Draft.number(
      'A rope is $a cm long. A string is $d cm '
      '${longer ? 'longer' : 'shorter'} than the rope. '
      'How long is the string, in cm?',
      b,
      check: '$a${longer ? '+' : '-'}$d',
      explanation: '$a ${longer ? '+' : '−'} $d = $b, so the string is $b cm.',
    );
  }),
  Template('p1.measure', 'heaviest', 15, (r, level) {
    final things = pickN(r, const [
      'bag',
      'box',
      'pail',
      'pumpkin',
      'basket',
    ], 3);
    final kg = distinct(r, 3, 2, level == 1 ? 9 : 30);
    final heavy = level == 1 || r.nextBool();
    final best = heavy ? kg.reduce(max) : kg.reduce(min);
    final ans = things[kg.indexOf(best)];
    return Draft.mcq(
      r,
      'The ${things[0]} is ${kg[0]} kg, the ${things[1]} is ${kg[1]} kg '
          'and the ${things[2]} is ${kg[2]} kg. '
          'Which is the ${heavy ? 'heaviest' : 'lightest'}?',
      'the $ans',
      [for (final t in things) 'the $t'],
      explanation:
          '$best kg is the ${heavy ? 'most' : 'least'}, so the $ans is the '
          '${heavy ? 'heaviest' : 'lightest'}.',
    );
  }),
  Template('p1.measure', 'difference', 15, (r, level) {
    final kg = level == 2;
    final a = rint(r, 10, level == 1 ? 20 : 50);
    final b = rint(r, 3, a - 2);
    final (x, y) = kg ? ('box', 'bag') : ('pen', 'crayon');
    final unit = kg ? 'kg' : 'cm';
    return Draft.number(
      kg
          ? 'A $x weighs $a kg. A $y weighs $b kg. '
                'How much heavier is the $x, in kg?'
          : 'A $x is $a cm long. A $y is $b cm long. '
                'How much longer is the $x, in cm?',
      a - b,
      check: '$a-$b',
      explanation: '$a $unit − $b $unit = ${a - b} $unit.',
    );
  }),

  // p1.shapes: 2D shapes and patterns.
  Template('p1.shapes', 'count', 15, (r, level) {
    final n = level + 4;
    final seq = [for (var k = 0; k < n; k++) pick(r, shapeNames)];
    final target = pick(r, seq);
    final c = seq.where((s) => s == target).length;
    return Draft.number(
      'How many ${target}s are there?',
      c,
      visual: {'kind': 'shapes', 'items': shapeItems(seq, colorFor(r, seq))},
      explanation: 'Count the ${target}s one by one: ${plural(c, target)}.',
    );
  }),
  Template('p1.shapes', 'next', 15, (r, level) {
    final unit = patternUnit(r, level);
    final shown = rint(r, unit.length + 1, unit.length * 2 + 1);
    final seq = [for (var k = 0; k < shown; k++) unit[k % unit.length]];
    final ans = unit[shown % unit.length];
    final colors = colorFor(r, unit);
    final opts = {...unit, ...shapeNames}.toList();
    return Draft.mcq(
      r,
      'What shape comes next in the pattern?',
      ans,
      opts,
      visual: {'kind': 'shapes', 'items': shapeItems(seq, colors)},
      explanation:
          'The pattern repeats ${unit.join(', ')}. After ${seq.last} '
          'comes $ans.',
    );
  }),
  Template('p1.shapes', 'finish', 15, (r, level) {
    final unit = patternUnit(r, level);
    final shown = rint(r, unit.length + 1, unit.length * 2);
    final seq = [for (var k = 0; k < shown; k++) unit[k % unit.length]];
    final ans = [for (var k = shown; k < shown + 2; k++) unit[k % unit.length]];
    return Draft.drag(
      r,
      'Drag shapes to fill the next 2 places in the pattern.',
      ans,
      shapeNames,
      visual: {'kind': 'shapes', 'items': shapeItems(seq, colorFor(r, unit))},
      explanation:
          'The pattern repeats ${unit.join(', ')}. Next come ${ans.join(', ')}.',
    );
  }),
  Template('p1.shapes', 'sides', 15, (r, level) {
    const sides = {'triangle': 3, 'square': 4, 'rectangle': 4};
    final kinds = pickN(r, sides.keys.toList(), level == 1 ? 1 : 2);
    final counts = [for (final _ in kinds) rint(r, 1, level == 3 ? 5 : 3)];
    final total = [
      for (var k = 0; k < kinds.length; k++) counts[k] * sides[kinds[k]]!,
    ].fold(0, (a, b) => a + b);
    final what = [
      for (var k = 0; k < kinds.length; k++) plural(counts[k], kinds[k]),
    ].join(' and ');
    return Draft.number(
      'Jun Wei draws $what. How many sides are there altogether?',
      total,
      check: [
        for (var k = 0; k < kinds.length; k++)
          '${counts[k]}*${sides[kinds[k]]}',
      ].join('+'),
      explanation:
          'A triangle has 3 sides; a square and a rectangle have 4. '
          'Altogether: $total sides.',
    );
  }),

  // p1.graphs: picture graphs, one picture for one.
  Template('p1.graphs', 'read', 15, (r, level) {
    final g = graph(r, level, 1);
    final row = pick(r, g.rows);
    return Draft.number(
      'How many children chose ${row.$1}?',
      row.$2,
      visual: g.visual,
      explanation: 'Count the pictures next to ${row.$1}. There are ${row.$2}.',
    );
  }),
  Template('p1.graphs', 'most', 15, (r, level) {
    final g = graph(r, level, 1);
    final most = r.nextBool();
    final counts = g.rows.map((x) => x.$2).toList();
    final best = most ? counts.reduce(max) : counts.reduce(min);
    if (counts.where((c) => c == best).length > 1) {
      retry();
    }
    final ans = g.rows.firstWhere((x) => x.$2 == best).$1;
    return Draft.mcq(
      r,
      'Which ${g.thing} did the ${most ? 'most' : 'fewest'} children choose?',
      ans,
      [for (final x in g.rows) x.$1],
      visual: g.visual,
      explanation:
          'The row for $ans has the ${most ? 'most' : 'fewest'} pictures: '
          '$best.',
    );
  }),
  Template('p1.graphs', 'more', 15, (r, level) {
    final g = graph(r, level, 1);
    final two = pickN(r, g.rows, 2)..sort((a, b) => b.$2 - a.$2);
    if (two[0].$2 == two[1].$2) retry();
    return Draft.number(
      'How many more children chose ${two[0].$1} than ${two[1].$1}?',
      two[0].$2 - two[1].$2,
      check: '${two[0].$2}-${two[1].$2}',
      visual: g.visual,
      explanation:
          '${cap(two[0].$1)} has ${two[0].$2} and ${two[1].$1} has '
          '${two[1].$2}. '
          '${two[0].$2} − ${two[1].$2} = ${two[0].$2 - two[1].$2}.',
    );
  }),
  Template('p1.graphs', 'total', 15, (r, level) {
    final g = graph(r, level, 1);
    final counts = g.rows.map((x) => x.$2).toList();
    final total = counts.fold(0, (a, b) => a + b);
    return Draft.number(
      'How many children are shown in the picture graph in all?',
      total,
      check: counts.join('+'),
      visual: g.visual,
      explanation: 'Add every row: ${counts.join(' + ')} = $total.',
    );
  }),
];

/// `3 o'clock` or `half past 3`.
String timeWords(int h, int m) => m == 30 ? 'half past $h' : "$h o'clock";

/// A picture graph of children's favourites, [scale] children per picture.
({List<(String, int)> rows, String thing, Map<String, dynamic> visual}) graph(
  Random r,
  int level,
  int scale, {
  int maxPictures = 9,
}) {
  final set = pick(r, graphSets);
  final labels = pickN(r, set.$3, level == 1 ? 3 : 4);
  final pics = distinct(r, labels.length, 1, maxPictures);
  final rows = [
    for (var k = 0; k < labels.length; k++) (labels[k], pics[k] * scale),
  ];
  return (
    rows: rows,
    thing: set.$1,
    visual: {
      'kind': 'pictureGraph',
      'title': set.$2,
      'rows': [
        for (final x in rows) {'label': x.$1, 'count': x.$2},
      ],
      'scale': scale,
      'icon': 'child',
    },
  );
}

const graphSets = [
  (
    'fruit',
    'Favourite fruit',
    ['apples', 'bananas', 'durians', 'mangoes', 'grapes'],
  ),
  ('pet', 'Favourite pet', ['cats', 'dogs', 'fish', 'rabbits', 'hamsters']),
  ('colour', 'Favourite colour', ['red', 'blue', 'green', 'yellow', 'purple']),
  (
    'snack',
    'Favourite snack',
    ['biscuits', 'popcorn', 'kaya toast', 'curry puffs', 'ice cream'],
  ),
  (
    'sport',
    'Favourite sport',
    ['football', 'swimming', 'badminton', 'running', 'basketball'],
  ),
];
