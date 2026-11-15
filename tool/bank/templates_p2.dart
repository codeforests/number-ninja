import 'dart:math';

import 'generator.dart';
import 'helpers.dart';
import 'templates_p1.dart' show graph;

/// P2 (MOE) templates, 11 topics (design §2). No plain add/subtract drills
/// within 100 (D2). Template names and their order of random draws are frozen
/// once a bank ships (BNK-05).
final p2Templates = <Template>[
  // p2.place: numbers to 1000.
  Template('p2.place', 'value', 10, (r, level) {
    final n = rint(r, 102, 999);
    final ds = [n ~/ 100, n ~/ 10 % 10, n % 10];
    if (ds.toSet().length < 3 || ds.contains(0)) retry();
    final at = level == 1 ? 0 : rint(r, 0, 2);
    final place = ['hundreds', 'tens', 'ones'][at];
    final v = ds[at] * [100, 10, 1][at];
    return Draft.mcq(
      r,
      'What is the value of the digit ${ds[at]} in $n?',
      v,
      [ds[at], ds[at] * 10, ds[at] * 100, n],
      explanation:
          'In $n, the digit ${ds[at]} is in the $place place, '
          'so it stands for $v.',
    );
  }),
  Template('p2.place', 'expanded', 10, (r, level) {
    final h = rint(r, 1, 9), t = rint(r, 0, 9), o = rint(r, 0, 9);
    if (level == 3) {
      // Regrouped tens: 4 hundreds and 15 tens.
      final tens = rint(r, 10, 19);
      if (h * 100 + tens * 10 + o > 999) retry();
      final v = h * 100 + tens * 10 + o;
      return Draft.number(
        '${plural(h, 'hundred')}, $tens tens and ${plural(o, 'one')} '
        'make ___.',
        v,
        check: '$h*100+$tens*10+$o',
        explanation:
            '$tens tens is ${tens * 10}. ${h * 100} + ${tens * 10} + $o = $v.',
      );
    }
    final v = h * 100 + t * 10 + o;
    final mixed = level == 2;
    return Draft.number(
      mixed
          ? '${plural(o, 'one')}, ${plural(h, 'hundred')} and '
                '${plural(t, 'ten')} make ___.'
          : '${plural(h, 'hundred')}, ${plural(t, 'ten')} and '
                '${plural(o, 'one')} make ___.',
      v,
      check: '$h*100+$t*10+$o',
      explanation: '${h * 100} + ${t * 10} + $o = $v.',
    );
  }),
  Template('p2.place', 'compare', 10, (r, level) {
    final base = level == 3 ? rint(r, 1, 9) * 100 : 100;
    final xs = distinct(
      r,
      level == 1 ? 3 : 4,
      base,
      level == 3 ? base + 99 : 999,
    );
    final most = r.nextBool();
    final ans = most ? xs.reduce(max) : xs.reduce(min);
    return Draft.mcq(
      r,
      'Which number is the ${most ? 'greatest' : 'smallest'}: '
      '${xs.join(', ')}?',
      ans,
      xs,
      explanation:
          'Compare the hundreds, then the tens, then the ones. '
          '$ans is the ${most ? 'greatest' : 'smallest'}.',
    );
  }),
  Template('p2.place', 'order', 10, (r, level) {
    final xs = level == 3
        ? [for (final d in distinct(r, 4, 0, 99)) rint(r, 1, 9) * 100 + d]
        : distinct(r, level + 2, 100, 999);
    if (xs.toSet().length < xs.length) retry();
    final up = r.nextBool();
    final sorted = List.of(xs)..sort();
    final ans = up ? sorted : sorted.reversed.toList();
    return Draft.drag(
      r,
      'Put ${xs.join(', ')} in order, from '
      '${up ? 'smallest to greatest' : 'greatest to smallest'}.',
      ans,
      const [],
      explanation:
          'Compare the hundreds first, then the tens, then the ones: '
          '${ans.join(', ')}.',
    );
  }),
  Template('p2.place', 'odd-even', 10, (r, level) {
    final odd = r.nextBool();
    final lo = level == 1 ? 10 : 100;
    final hi = level == 1 ? 99 : 999;
    final xs = distinct(r, 12, lo, hi);
    final right = xs.firstWhere((x) => x.isOdd == odd);
    final wrong = xs.where((x) => x.isOdd != odd).take(3).toList();
    if (wrong.length < 3) retry();
    return Draft.mcq(
      r,
      'Which of these numbers is ${odd ? 'odd' : 'even'}: '
      '${(([right, ...wrong])..sort()).join(', ')}?',
      right,
      wrong,
      explanation:
          'Look at the ones digit. $right ends in ${right % 10}, which is '
          '${odd ? 'odd' : 'even'}.',
    );
  }),
  Template('p2.place', 'more-less', 10, (r, level) {
    final step = level == 1 ? 10 : (level == 2 ? 100 : pick(r, [10, 100]));
    final more = r.nextBool();
    final n = more ? rint(r, 100, 999 - step) : rint(r, 100 + step, 999);
    final ans = more ? n + step : n - step;
    return Draft.number(
      'What is $step ${more ? 'more' : 'less'} than $n?',
      ans,
      check: '$n${more ? '+' : '-'}$step',
      explanation:
          '$step ${more ? 'more' : 'less'} than $n is $ans. The '
          '${step == 10 ? 'tens' : 'hundreds'} digit changes by 1.',
    );
  }),

  // p2.regroup: every question regroups or has two steps (AC-7).
  Template('p2.regroup', 'add', 12, (r, level) {
    final (a, b) = switch (level) {
      1 => (rint(r, 45, 99), rint(r, 25, 99)),
      2 => (rint(r, 100, 699), rint(r, 20, 99)),
      _ => (rint(r, 100, 599), rint(r, 100, 399)),
    };
    final s = a + b;
    if (s > 999 || s <= 100 || !carries(a, b)) retry();
    if (level == 3 &&
        !(a % 10 + b % 10 >= 10 && a ~/ 10 % 10 + b ~/ 10 % 10 >= 9)) {
      retry(); // two regroups
    }
    if (level == 1) {
      return Draft.mcq(
        r,
        'What is $a + $b?',
        s,
        [addNoCarry(a, b), s + 10, s - 10, s + 1],
        check: '$a+$b',
        explanation:
            'Add the ones, then the tens, and regroup 10 ones as 1 ten '
            '(and 10 tens as 1 hundred). $a + $b = $s.',
      );
    }
    return Draft.number(
      '$a + $b = ___',
      s,
      check: '$a+$b',
      explanation:
          'Add the ones first and regroup when a column makes 10 or more. '
          '$a + $b = $s.',
    );
  }),
  Template('p2.regroup', 'subtract', 12, (r, level) {
    final a = level == 3
        ? rint(r, 1, 9) * 100 + rint(r, 0, 9)
        : rint(r, 101, 999);
    if (a < 210) retry();
    final b = rint(r, level == 1 ? 12 : 101, a - 1);
    if (!borrows(a, b) || a - b < 10) retry();
    if (level == 1) {
      return Draft.mcq(
        r,
        'What is $a − $b?',
        a - b,
        [subNoBorrow(a, b), a - b + 10, a - b - 10, a - b + 100],
        check: '$a-$b',
        explanation:
            'When the top digit is smaller, regroup 1 ten as 10 ones '
            '(or 1 hundred as 10 tens). $a − $b = ${a - b}.',
      );
    }
    return Draft.number(
      '$a − $b = ___',
      a - b,
      check: '$a-$b',
      explanation:
          '${level == 3 ? 'There are no tens to take from, so first regroup '
                    '1 hundred as 10 tens. ' : 'Regroup when the top digit is smaller. '}'
          '$a − $b = ${a - b}.',
    );
  }),
  Template('p2.regroup', 'missing', 12, (r, level) {
    final whole = rint(r, 200, 999);
    final part = rint(r, 101, whole - 50);
    final other = whole - part;
    if (!borrows(whole, part)) retry();
    final kind = level == 3 ? 2 : r.nextInt(2);
    final prompt = switch (kind) {
      0 => '___ + $part = $whole',
      1 => '$part + ___ = $whole',
      _ => '$whole − ___ = $part',
    };
    return Draft.number(
      prompt,
      other,
      check: '$whole-$part',
      explanation:
          'Find the missing part: $whole − $part = $other. '
          'Check: $part + $other = $whole.',
    );
  }),
  Template('p2.regroup', 'word', 12, (r, level) {
    final (name, he) = child(r);
    final add = level != 2 && r.nextBool() || level == 1;
    final thing = pick(r, const ['stickers', 'beads', 'stamps', 'cards']);
    if (add) {
      final a = rint(r, 120, 600), b = rint(r, 60, 380);
      if (!carries(a, b) || a + b > 999) retry();
      return Draft.number(
        '$name has $a $thing. ${cap(he)} buys $b more. '
        'How many $thing does $he have now?',
        a + b,
        check: '$a+$b',
        explanation: '"More" means add: $a + $b = ${a + b}.',
      );
    }
    final a = rint(r, 300, 999), b = rint(r, 101, a - 50);
    if (!borrows(a, b)) retry();
    return Draft.number(
      '$name has $a $thing. ${cap(he)} gives away $b of them. '
      'How many $thing does $he have left?',
      a - b,
      check: '$a-$b',
      explanation: '"Left" means take away: $a − $b = ${a - b}.',
    );
  }),
  Template('p2.regroup', 'two-step', 12, (r, level) {
    final shop = pick(r, const [
      ('eggs', 'sold'),
      ('buns', 'sold'),
      ('tickets', 'sold'),
      ('books', 'lent out'),
    ]);
    final total = rint(r, 400, 999);
    final a = rint(r, 100, total ~/ 2), b = rint(r, 50, total ~/ 3);
    if (total - a - b < 10) retry();
    if (level == 1) {
      final c = rint(r, 100, 400);
      if (total - a + c > 999) retry();
      return Draft.number(
        'A shop had $total ${shop.$1}. It ${shop.$2} $a, then got $c more. '
        'How many ${shop.$1} does it have now?',
        total - a + c,
        check: '$total-$a+$c',
        explanation:
            'First $total − $a = ${total - a}. '
            'Then ${total - a} + $c = ${total - a + c}.',
      );
    }
    return Draft.number(
      'A shop had $total ${shop.$1}. It ${shop.$2} $a in the morning and '
      '$b in the afternoon. How many ${shop.$1} were left?',
      total - a - b,
      check: '$total-$a-$b',
      explanation:
          'First $total − $a = ${total - a}. '
          'Then ${total - a} − $b = ${total - a - b}.',
    );
  }),

  // p2.times: tables of 2, 3, 4, 5 and 10.
  Template('p2.times', 'fact', 12, (r, level) {
    final t = pick(r, level == 1 ? [2, 5, 10] : [3, 4]);
    final n = rint(r, level == 3 ? 6 : 2, 10);
    final flip = r.nextBool();
    return Draft.number(
      flip ? '$n × $t = ___' : '$t × $n = ___',
      t * n,
      check: '$t*$n',
      explanation: '$n groups of $t make ${t * n}.',
    );
  }),
  Template('p2.times', 'missing', 12, (r, level) {
    final t = pick(r, level == 1 ? [2, 5, 10] : [3, 4, 5]);
    final n = rint(r, 2, 10);
    return Draft.number(
      level == 3 ? '$t × ___ = ${t * n}' : '___ × $t = ${t * n}',
      n,
      check: '${t * n}/$t',
      explanation: '$n × $t = ${t * n}, so the missing number is $n.',
    );
  }),
  Template('p2.times', 'groups', 12, (r, level) {
    final each = pick(r, level == 1 ? [2, 5] : [3, 4, 5, 10]);
    final g = rint(r, 2, level == 3 ? 10 : 6);
    final c = pick(r, const [
      ('bags', 'oranges', 'orange'),
      ('plates', 'cookies', 'cookie'),
      ('boxes', 'crayons', 'crayon'),
      ('vases', 'flowers', 'flower'),
    ]);
    return Draft.number(
      'There are $g ${c.$1} with $each ${c.$2} in each. '
      'How many ${c.$2} are there?',
      g * each,
      check: '$g*$each',
      visual: {'kind': 'groups', 'groups': g, 'each': each, 'icon': c.$3},
      explanation: '$g groups of $each: $g × $each = ${g * each}.',
    );
  }),
  Template('p2.times', 'word', 12, (r, level) {
    final c = pick(r, const [
      ('car', 'wheels', 4),
      ('stool', 'legs', 3),
      ('hand', 'fingers', 5),
      ('bicycle', 'wheels', 2),
      ('pack', 'pens', 10),
      ('tricycle', 'wheels', 3),
    ]);
    final n = rint(r, 2, 10);
    final ans = n * c.$3;
    return Draft.mcq(
      r,
      'A ${c.$1} has ${c.$3} ${c.$2}. How many ${c.$2} do $n ${c.$1}s have?',
      ans,
      [n + c.$3, ans + c.$3, ans - c.$3],
      explanation: '$n × ${c.$3} = $ans.',
    );
  }),
  Template('p2.times', 'skip-count', 12, (r, level) {
    final t = pick(r, level == 1 ? [2, 5, 10] : [3, 4]);
    final start = rint(r, 1, level == 3 ? 6 : 3) * t;
    final seq = [for (var k = 0; k < 6; k++) start + k * t];
    final gaps = level == 1 ? [3, 5] : [2, 4];
    final shown = [
      for (var k = 0; k < 6; k++) gaps.contains(k) ? '___' : '${seq[k]}',
    ];
    final ans = [for (final g in gaps) seq[g]];
    return Draft.drag(
      r,
      'Count in ${t}s. Drag the missing numbers into the boxes: '
      '${shown.join(', ')}',
      ans,
      [ans[0] + 1, ans[1] - 1, ans[0] + t * 2],
      explanation: 'Add $t each time: ${seq.join(', ')}.',
    );
  }),

  // p2.divide: by 2, 3, 4, 5 and 10.
  Template('p2.divide', 'fact', 12, (r, level) {
    final d = pick(r, level == 1 ? [2, 5, 10] : [3, 4]);
    final q = rint(r, level == 3 ? 6 : 2, 10);
    return Draft.number(
      '${d * q} ÷ $d = ___',
      q,
      check: '${d * q}/$d',
      explanation: '$q × $d = ${d * q}, so ${d * q} ÷ $d = $q.',
    );
  }),
  Template('p2.divide', 'share', 12, (r, level) {
    final d = pick(r, level == 1 ? [2, 5] : [3, 4, 5, 10]);
    final q = rint(r, 2, 10);
    final thing = pick(r, const ['sweets', 'marbles', 'stickers', 'pencils']);
    return Draft.number(
      '${d * q} $thing are shared equally among $d children. '
      'How many $thing does each child get?',
      q,
      check: '${d * q}/$d',
      explanation: '${d * q} ÷ $d = $q, because $d × $q = ${d * q}.',
    );
  }),
  Template('p2.divide', 'groups', 12, (r, level) {
    final c = pick(r, const [
      ('eggs', 'trays', 10),
      ('cupcakes', 'boxes', 4),
      ('children', 'teams', 5),
      ('socks', 'pairs', 2),
      ('chairs', 'rows', 3),
    ]);
    final q = rint(r, 2, level == 3 ? 10 : 6);
    final total = q * c.$3;
    return Draft.mcq(
      r,
      'There are $total ${c.$1}. They are put into ${c.$2} of ${c.$3}. '
      'How many ${c.$2} are there?',
      q,
      [q + 1, q - 1, total - c.$3, q * 2],
      explanation: '$total ÷ ${c.$3} = $q.',
    );
  }),
  Template('p2.divide', 'missing', 12, (r, level) {
    final d = pick(r, level == 1 ? [2, 5, 10] : [3, 4, 5]);
    final q = rint(r, 2, 10);
    final first = level != 3;
    return Draft.number(
      first ? '___ ÷ $d = $q' : '${d * q} ÷ ___ = $q',
      first ? d * q : d,
      check: first ? '$q*$d' : '${d * q}/$q',
      explanation: first
          ? '$q × $d = ${d * q}, so ${d * q} ÷ $d = $q.'
          : '${d * q} ÷ $d = $q, because $q × $d = ${d * q}.',
    );
  }),
  Template('p2.divide', 'family', 12, (r, level) {
    final a = pick(r, [2, 3, 4, 5, 10]);
    final b = rint(r, 2, 10);
    if (a == b) retry();
    final p = a * b;
    return Draft.mcq(
      r,
      'We know that $a × $b = $p. Which of these is also true?',
      '$p ÷ $a = $b',
      ['$p ÷ $a = ${b + 1}', '$b ÷ $a = $p', '$p ÷ $b = $b', '$a ÷ $b = $p'],
      explanation:
          'Multiplying and dividing go together: $a × $b = $p, '
          'so $p ÷ $a = $b.',
    );
  }),

  // p2.fractions: halves to twelfths.
  Template('p2.fractions', 'name', 10, (r, level) {
    final parts = rint(r, 2, level == 1 ? 6 : 12);
    final shaded = rint(r, 1, parts - 1);
    final ans = '$shaded/$parts';
    return Draft.mcq(
      r,
      'What fraction of the shape is shaded?',
      ans,
      [
        '$parts/$shaded',
        '$shaded/${parts - shaded}',
        '${parts - shaded}/$parts',
        '1/$parts',
      ],
      visual: {'kind': 'fraction', 'parts': parts, 'shaded': shaded},
      explanation:
          'The shape has $parts equal parts and $shaded '
          '${shaded == 1 ? 'is' : 'are'} shaded: $ans.',
    );
  }),
  Template('p2.fractions', 'unshaded', 10, (r, level) {
    final parts = rint(r, 3, level == 1 ? 6 : 12);
    final shaded = rint(r, 1, parts - 1);
    final ans = '${parts - shaded}/$parts';
    return Draft.mcq(
      r,
      'What fraction of the shape is not shaded?',
      ans,
      ['$shaded/$parts', '${parts - shaded}/$shaded', '1/$parts'],
      visual: {'kind': 'fraction', 'parts': parts, 'shaded': shaded},
      explanation:
          '${parts - shaded} of the $parts equal parts are not shaded: $ans.',
    );
  }),
  Template('p2.fractions', 'compare', 10, (r, level) {
    final bigger = level == 1 || r.nextBool();
    final List<(int, int)> fs;
    final String why;
    if (level == 1) {
      fs = [for (final d in distinct(r, 3, 2, 12)) (1, d)];
      why = 'With the same top number, fewer parts means bigger parts.';
    } else if (level == 2) {
      final d = rint(r, 5, 12);
      fs = [for (final n in distinct(r, 3, 1, d - 1)) (n, d)];
      why = 'They have the same parts, so more parts shaded is bigger.';
    } else {
      final n = rint(r, 2, 5);
      fs = [for (final d in distinct(r, 3, n + 1, 12)) (n, d)];
      why =
          'Each has $n parts, so the fraction with bigger parts '
          '(a smaller bottom number) is bigger.';
    }
    double v((int, int) f) => f.$1 / f.$2;
    final best = fs.reduce(
      (a, b) => (bigger ? v(a) > v(b) : v(a) < v(b)) ? a : b,
    );
    String s((int, int) f) => '${f.$1}/${f.$2}';
    return Draft.mcq(
      r,
      'Which fraction is the ${bigger ? 'greatest' : 'smallest'}: '
      '${fs.map(s).join(', ')}?',
      s(best),
      fs.map(s).toList(),
      explanation:
          '$why ${s(best)} is the ${bigger ? 'greatest' : 'smallest'}.',
    );
  }),
  Template('p2.fractions', 'add', 10, (r, level) {
    final d = rint(r, 3, 12);
    final a = rint(r, 1, d - 2), b = rint(r, 1, d - a);
    final sum = a + b;
    final ans = sum == d ? '1' : '$sum/$d';
    if (level == 1 && sum == d) retry();
    return Draft.mcq(
      r,
      'What is $a/$d + $b/$d?',
      ans,
      [
        '$sum/${d * 2}',
        '${sum + 1}/$d',
        '$sum/${d + d}',
        '${a * b}/$d',
        '${sum - 1}/$d',
      ],
      explanation: sum == d
          ? 'Add the top numbers: $a + $b = $sum. $sum/$d is one whole: 1.'
          : 'The parts are the same size, so add the top numbers: '
                '$a + $b = $sum. The answer is $sum/$d.',
    );
  }),
  Template('p2.fractions', 'subtract', 10, (r, level) {
    final d = rint(r, 3, 12);
    final whole = level == 3;
    final a = whole ? d : rint(r, 2, d - 1);
    final b = rint(r, 1, a - 1);
    final ans = '${a - b}/$d';
    return Draft.mcq(
      r,
      whole ? 'What is 1 − $b/$d?' : 'What is $a/$d − $b/$d?',
      ans,
      ['$a/$d', '${a + b}/$d', '${a - b + 1}/$d', '$b/$d'],
      explanation: whole
          ? '1 whole is $d/$d. $d/$d − $b/$d = $ans.'
          : 'Take away the top numbers: $a − $b = ${a - b}. The answer is $ans.',
    );
  }),
  Template('p2.fractions', 'order', 10, (r, level) {
    final List<(int, int)> fs;
    if (level == 2) {
      final d = rint(r, 5, 12);
      fs = [for (final n in distinct(r, 3, 1, d - 1)) (n, d)];
    } else {
      fs = [for (final d in distinct(r, level + 2, 2, 12)) (1, d)];
    }
    final sorted = List.of(fs)..sort((a, b) => (a.$1 * b.$2) - (b.$1 * a.$2));
    String s((int, int) f) => '${f.$1}/${f.$2}';
    return Draft.drag(
      r,
      'Put ${fs.map(s).join(', ')} in order, from smallest to greatest.',
      sorted.map(s).toList(),
      const [],
      explanation: level == 2
          ? 'Same-sized parts: fewer shaded parts is smaller. '
                '${sorted.map(s).join(', ')}.'
          : 'One part each: the more parts a whole is cut into, the smaller '
                'each part. ${sorted.map(s).join(', ')}.',
    );
  }),

  // p2.measure: m and cm, kg and g, litres.
  Template('p2.measure', 'metres', 12, (r, level) {
    final m = rint(r, 1, 9), cm = rint(r, 1, 99);
    if (level == 3) {
      final total = m * 100 + cm;
      return Draft.number(
        '$total cm = $m m ___ cm',
        cm,
        check: '$total-$m*100',
        explanation: '$m m is ${m * 100} cm. $total − ${m * 100} = $cm.',
      );
    }
    final mm = level == 1 ? 0 : cm;
    return Draft.number(
      mm == 0 ? '$m m = ___ cm' : '$m m $mm cm = ___ cm',
      m * 100 + mm,
      check: '$m*100+$mm',
      explanation:
          '1 m = 100 cm, so $m m = ${m * 100} cm'
          '${mm == 0 ? '.' : '. ${m * 100} + $mm = ${m * 100 + mm}.'}',
    );
  }),
  Template('p2.measure', 'grams', 12, (r, level) {
    final kg = rint(r, 1, 9), g = rint(r, 1, 9) * (level == 3 ? 10 : 100);
    if (level == 1) {
      return Draft.number(
        '$kg kg = ___ g',
        kg * 1000,
        check: '$kg*1000',
        explanation: '1 kg = 1000 g, so $kg kg = ${kg * 1000} g.',
      );
    }
    return Draft.number(
      '$kg kg $g g = ___ g',
      kg * 1000 + g,
      check: '$kg*1000+$g',
      explanation:
          '$kg kg = ${kg * 1000} g. ${kg * 1000} + $g = '
          '${kg * 1000 + g}.',
    );
  }),
  Template('p2.measure', 'litres', 12, (r, level) {
    final (name, he) = child(r);
    if (level == 3) {
      final jug = rint(r, 2, 5), n = rint(r, 2, 10);
      return Draft.number(
        'A pail holds ${jug * n} ℓ of water. $name fills it with a $jug ℓ '
        'jug. How many jugs of water does $he pour in?',
        n,
        check: '${jug * n}/$jug',
        explanation: '${jug * n} ÷ $jug = $n jugs.',
      );
    }
    final b = rint(r, 2, 5), n = rint(r, 2, level == 1 ? 5 : 10);
    return Draft.number(
      'A bottle holds $b ℓ of juice. How many litres do $n bottles hold?',
      b * n,
      check: '$n*$b',
      explanation: '$n × $b ℓ = ${b * n} ℓ.',
    );
  }),
  Template('p2.measure', 'compare', 12, (r, level) {
    final mass = level == 2;
    final unitBig = mass ? 'kg' : 'm';
    final unitSmall = mass ? 'g' : 'cm';
    final per = mass ? 1000 : 100;
    final vals = distinct(
      r,
      4,
      level == 1 ? 1 : 5,
      mass ? 40 : 40,
    ).map((v) => v * per ~/ 10).toList();
    String show(int v, int k) {
      if (v % per == 0 && k.isEven) return '${v ~/ per} $unitBig';
      if (v > per && k == 1) {
        return '${v ~/ per} $unitBig ${v % per} $unitSmall';
      }
      return '$v $unitSmall';
    }

    final shown = [for (var k = 0; k < 4; k++) show(vals[k], k)];
    if (shown.any((s) => s.endsWith(' 0 $unitSmall') || s.startsWith('0 '))) {
      retry();
    }
    final most = r.nextBool();
    final best = most ? vals.reduce(max) : vals.reduce(min);
    final word = mass
        ? (most ? 'heaviest' : 'lightest')
        : (most ? 'longest' : 'shortest');
    return Draft.mcq(
      r,
      'Which is the $word: ${shown.join(', ')}?',
      shown[vals.indexOf(best)],
      shown,
      explanation:
          'Change them all to $unitSmall first (1 $unitBig = $per $unitSmall). '
          '${shown[vals.indexOf(best)]} is the $word.',
    );
  }),
  Template('p2.measure', 'units', 12, (r, level) {
    const things = [
      ('the length of a classroom', 'm'),
      ('the length of a pencil', 'cm'),
      ('the height of a door', 'm'),
      ('the length of an eraser', 'cm'),
      ('the mass of a watermelon', 'kg'),
      ('the mass of a strawberry', 'g'),
      ('the mass of a schoolbag', 'kg'),
      ('the mass of a coin', 'g'),
      ('the amount of water in a bathtub', 'ℓ'),
      ('the amount of water in a fish tank', 'ℓ'),
      ('the length of a bus', 'm'),
      ('the mass of a pencil', 'g'),
      ('the width of a book', 'cm'),
      ('the mass of a bag of rice', 'kg'),
      ('the amount of water in a pail', 'ℓ'),
    ];
    final t = pick(r, things);
    return Draft.mcq(
      r,
      'Which unit would you use to measure ${t.$1}?',
      t.$2,
      ['m', 'cm', 'kg', 'g', 'ℓ']..shuffle(r),
      explanation: switch (t.$2) {
        'm' => 'It is long, so use metres (m).',
        'cm' => 'It is short, so use centimetres (cm).',
        'kg' => 'It is heavy, so use kilograms (kg).',
        'g' => 'It is light, so use grams (g).',
        _ => 'It is an amount of water, so use litres (ℓ).',
      },
    );
  }),

  // p2.money: dollars and cents, change.
  Template('p2.money', 'change', 15, (r, level) {
    final (name, he) = child(r);
    final paid = [500, 1000, 1000][level - 1];
    final cost = level == 1
        ? rint(r, 11, 49) * 10
        : rint(r, 101, paid ~/ 5 - 1) * 5;
    final thing = pick(r, const [
      'a book',
      'a toy car',
      'a pencil case',
      'a water bottle',
    ]);
    return Draft.number(
      '$name buys $thing for ${dollars(cost)}. ${cap(he)} pays with a '
      '${dollars(paid).replaceAll('.00', '')} note. How much change does '
      '$he get? Give your answer in dollars.',
      dollarAnswer(paid - cost),
      check: '($paid-$cost)/100',
      explanation:
          '${dollars(paid)} − ${dollars(cost)} = ${dollars(paid - cost)}.',
    );
  }),
  Template('p2.money', 'total', 15, (r, level) {
    final a = rint(r, 11, level == 1 ? 30 : 99) * (level == 1 ? 10 : 5);
    final b = rint(r, 11, level == 1 ? 30 : 99) * (level == 1 ? 10 : 5);
    final items = pickN(r, const [
      'pen',
      'ruler',
      'notebook',
      'eraser',
      'file',
    ], 2);
    return Draft.number(
      'A ${items[0]} costs ${dollars(a)} and a ${items[1]} costs '
      '${dollars(b)}. How much do they cost altogether? '
      'Give your answer in dollars.',
      dollarAnswer(a + b),
      check: '($a+$b)/100',
      explanation:
          'Add the dollars and the cents: ${dollars(a)} + ${dollars(b)} = '
          '${dollars(a + b)}.',
    );
  }),
  Template('p2.money', 'convert', 15, (r, level) {
    final c = rint(r, 101, 999);
    if (level == 1 && c % 100 < 10) retry();
    if (level == 3) {
      return Draft.number(
        '$c¢ = \$___',
        dollarAnswer(c),
        check: '$c/100',
        explanation: '100¢ = \$1, so $c¢ = ${dollars(c)}.',
      );
    }
    return Draft.number(
      '${dollars(c)} = ___¢',
      c,
      check: '${c ~/ 100}*100+${c % 100}',
      explanation:
          '\$${c ~/ 100} = ${c ~/ 100 * 100}¢. '
          '${c ~/ 100 * 100}¢ + ${c % 100}¢ = $c¢.',
    );
  }),
  Template('p2.money', 'coins', 15, (r, level) {
    final kinds = [10, 20, 50, 100];
    final n = rint(r, 3, level + 3);
    final coins = [
      for (var k = 0; k < n; k++) pick(r, level == 1 ? [50, 100] : kinds),
      if (level == 3) 5,
    ]..sort((a, b) => b - a);
    final total = coins.fold(0, (a, b) => a + b);
    if (total <= 100) retry();
    return Draft.number(
      'How much money is there? Give your answer in dollars.',
      dollarAnswer(total),
      check: '(${coins.join('+')})/100',
      visual: {'kind': 'coins', 'cents': coins},
      explanation:
          'Count from the biggest coin: '
          '${coins.map(money).join(' + ')} = ${dollars(total)}.',
    );
  }),

  // p2.time: 5-minute steps, a.m. and p.m., durations.
  Template('p2.time', 'read', 12, (r, level) {
    final h = rint(r, 1, 12);
    final m = rint(r, 1, 11) * 5;
    if (level == 1 && m % 15 != 0) retry();
    final ans = clock(h, m);
    // Mixing up the hands, and reading the hour hand as the next hour.
    final swapped = m ~/ 5 == h ? null : clock(m ~/ 5, (h % 12) * 5);
    return Draft.mcq(
      r,
      'What time does the clock show?',
      ans,
      [
        clock(h % 12 + 1, m),
        ?swapped,
        clock(h, (m + 30) % 60),
        clock((h + 10) % 12 + 1, m),
      ],
      visual: {'kind': 'clock', 'h': h, 'm': m},
      explanation:
          'The short hand is just past $h. The long hand points to '
          '${m ~/ 5}, which is $m minutes. It is $ans.',
    );
  }),
  Template('p2.time', 'later', 12, (r, level) {
    final (name, he) = child(r);
    final start = 12 * 60 + rint(r, 2 * 12, 8 * 12) * 5; // 2 to 8 p.m.
    final add = rint(r, 2, level == 1 ? 6 : 12) * 5;
    final end = start + add;
    if (level == 1 && start ~/ 60 != end ~/ 60) retry();
    if (level == 3 && start ~/ 60 == end ~/ 60) retry();
    final act = pick(r, const [
      'reading',
      'drawing',
      'playing the piano',
      'swimming',
    ]);
    final ans = clock12(end);
    return Draft.mcq(
      r,
      '$name starts $act at ${clock12(start)}. ${cap(he)} stops '
      '$add minutes later. What time does $he stop?',
      ans,
      [
        clock12(end + 10),
        clock12(end - 5),
        clock12(start + add + 60),
        clock12(end + 5),
      ],
      explanation: 'Count on $add minutes from ${clock12(start)}: $ans.',
    );
  }),
  Template('p2.time', 'duration', 12, (r, level) {
    final start = rint(r, 8 * 12, 18 * 12) * 5;
    final len = rint(r, 3, level == 3 ? 11 : 9) * 5;
    final end = start + len;
    if (level < 3 && start ~/ 60 != end ~/ 60) retry();
    if (level == 3 && start ~/ 60 == end ~/ 60) retry();
    final show = pick(r, const [
      'A show',
      'A lesson',
      'A football match',
      'A movie',
    ]);
    return Draft.number(
      '$show starts at ${clock12(start)} and ends at ${clock12(end)}. '
      'How many minutes long is it?',
      len,
      check: '$end-$start',
      explanation: level == 3
          ? 'From ${clock12(start)} to ${clock12(end ~/ 60 * 60)} is '
                '${end ~/ 60 * 60 - start} minutes. Then to ${clock12(end)} is '
                '${end % 60} more. ${end ~/ 60 * 60 - start} + ${end % 60} = $len.'
          : 'Count on from ${clock12(start)} to ${clock12(end)}: $len minutes.',
    );
  }),
  Template('p2.time', 'am-pm', 12, (r, level) {
    const events = [
      ('eats breakfast', 'in the morning', 6, 8),
      ('goes to school', 'in the morning', 6, 7),
      ('has lunch', 'in the afternoon', 12, 13),
      ('goes swimming', 'in the afternoon', 14, 17),
      ('eats dinner', 'in the evening', 18, 20),
      ('goes to bed', 'at night', 20, 21),
      ('plays in the park', 'in the morning', 9, 11),
      ('does homework', 'in the afternoon', 15, 17),
    ];
    final (name, _) = child(r);
    final e = pick(r, events);
    final t = rint(r, e.$3 * 12, e.$4 * 12) * 5;
    final ans = clock12(t);
    return Draft.mcq(
      r,
      '$name ${e.$1} ${e.$2}, at ${clock(t ~/ 60 % 12 == 0 ? 12 : t ~/ 60 % 12, t % 60)}. '
      'How do we write this time?',
      ans,
      [clock12((t + 12 * 60) % (24 * 60)), clock12(t + 60), clock12(t - 60)],
      explanation:
          'a.m. is from midnight to noon; p.m. is from noon to midnight. '
          'Times ${e.$2} are ${t < 12 * 60 ? 'a.m.' : 'p.m.'}: $ans.',
    );
  }),
  Template('p2.time', 'minutes', 12, (r, level) {
    final h = rint(r, 1, level == 3 ? 3 : 2);
    final m = rint(r, 1, 11) * 5;
    if (level == 1) {
      return Draft.number(
        '1 hour $m minutes = ___ minutes',
        60 + m,
        check: '60+$m',
        explanation: '1 hour = 60 minutes. 60 + $m = ${60 + m}.',
      );
    }
    return Draft.number(
      '${h * 60 + m} minutes = $h ${h == 1 ? 'hour' : 'hours'} ___ minutes',
      m,
      check: '${h * 60 + m}-$h*60',
      explanation:
          '$h ${h == 1 ? 'hour is' : 'hours are'} ${h * 60} minutes. '
          '${h * 60 + m} − ${h * 60} = $m.',
    );
  }),

  // p2.shapes: 2D and 3D shapes, patterns.
  Template('p2.shapes', 'count', 16, (r, level) {
    final pool = [...shapeNames, 'semicircle', 'quarter circle'];
    final n = level + 5;
    final seq = [for (var k = 0; k < n; k++) pick(r, pool)];
    final target = level == 1
        ? pick(r, seq)
        : pick(r, ['semicircle', 'quarter circle']);
    final c = seq.where((s) => s == target).length;
    if (c == 0) retry();
    return Draft.number(
      'How many ${target}s are there?',
      c,
      visual: {'kind': 'shapes', 'items': shapeItems(seq, colorFor(r, seq))},
      explanation: 'Count the ${target}s one by one: ${plural(c, target)}.',
    );
  }),
  Template('p2.shapes', 'next', 16, (r, level) {
    // Patterns that change in shape and colour.
    final shapes = pickN(r, [...shapeNames, 'semicircle'], level + 1);
    final colors = pickN(r, shapeColors, level == 1 ? 1 : 2);
    final len =
        shapes.length *
        colors.length ~/
        (colors.length == 2 && shapes.length.isEven ? 2 : 1);
    final unit = [
      for (var k = 0; k < len; k++)
        {
          'shape': shapes[k % shapes.length],
          'color': colors[k % colors.length],
        },
    ];
    final shown = rint(r, len + 1, len * 2);
    final seq = [for (var k = 0; k < shown; k++) unit[k % len]];
    final next = unit[shown % len];
    String name(Map<String, String?> m) => '${m['color']} ${m['shape']}';
    return Draft.mcq(
      r,
      'What comes next in the pattern?',
      name(next),
      [
        for (final s in shapes)
          for (final c in colors) '$c $s',
        '${pick(r, shapeColors)} ${next['shape']}',
        for (final s in [...shapeNames, 'semicircle']) '${next['color']} $s',
      ]..shuffle(r),
      visual: {'kind': 'shapes', 'items': seq},
      explanation:
          'The pattern repeats every $len shapes. Next is the ${name(next)}.',
    );
  }),
  Template('p2.shapes', 'finish', 16, (r, level) {
    final unit = patternUnit(r, level == 1 ? 2 : 3);
    final shown = rint(r, unit.length + 1, unit.length * 2);
    final seq = [for (var k = 0; k < shown; k++) unit[k % unit.length]];
    final ans = [for (var k = shown; k < shown + 3; k++) unit[k % unit.length]];
    return Draft.drag(
      r,
      'Drag shapes to fill the next 3 places in the pattern.',
      ans,
      [...shapeNames, 'semicircle'],
      visual: {'kind': 'shapes', 'items': shapeItems(seq, colorFor(r, unit))},
      explanation:
          'The pattern repeats ${unit.join(', ')}. Next come ${ans.join(', ')}.',
    );
  }),
  Template('p2.shapes', 'solids', 12, (r, level) {
    const objects = [
      ('a tin of soup', 'cylinder'),
      ('a football', 'sphere'),
      ('a dice', 'cube'),
      ('a tissue box', 'cuboid'),
      ('a party hat', 'cone'),
      ('an orange', 'sphere'),
      ('a brick', 'cuboid'),
      ('a drum', 'cylinder'),
      ('an ice cream cone', 'cone'),
      ('a sugar cube', 'cube'),
      ('a cereal box', 'cuboid'),
      ('a marble', 'sphere'),
    ];
    const faces = {
      'cube': 6,
      'cuboid': 6,
      'cylinder': 2,
      'cone': 1,
      'sphere': 0,
    };
    const solids = ['cube', 'cuboid', 'cylinder', 'cone', 'sphere'];
    if (level == 3) {
      final s = pick(r, solids);
      return Draft.number(
        'How many flat faces does a $s have?',
        faces[s]!,
        explanation: switch (s) {
          'sphere' => 'A sphere is round all over: 0 flat faces.',
          'cone' => 'A cone has 1 flat face at the bottom.',
          'cylinder' => 'A cylinder has a flat face at each end: 2.',
          _ => 'A $s has 6 flat faces.',
        },
      );
    }
    final o = pick(r, objects);
    return Draft.mcq(
      r,
      'Which solid has the same shape as ${o.$1}?',
      o.$2,
      solids,
      explanation: '${cap(o.$1)} is shaped like a ${o.$2}.',
    );
  }),

  // p2.graphs: picture graphs with scales.
  Template('p2.graphs', 'read', 12, (r, level) {
    final scale = [2, 5, 10][level - 1];
    final g = graph(r, level, scale, maxPictures: 8);
    final row = pick(r, g.rows);
    return Draft.number(
      'Each picture stands for $scale children. '
      'How many children chose ${row.$1}?',
      row.$2,
      check: '${row.$2 ~/ scale}*$scale',
      visual: g.visual,
      explanation:
          'There are ${row.$2 ~/ scale} pictures for ${row.$1}. '
          '${row.$2 ~/ scale} × $scale = ${row.$2}.',
    );
  }),
  Template('p2.graphs', 'more', 12, (r, level) {
    final scale = pick(r, [2, 5, 10]);
    final g = graph(r, level, scale, maxPictures: 8);
    final two = pickN(r, g.rows, 2)..sort((a, b) => b.$2 - a.$2);
    final d = two[0].$2 - two[1].$2;
    return Draft.number(
      'Each picture stands for $scale children. How many more children '
      'chose ${two[0].$1} than ${two[1].$1}?',
      d,
      check: '${two[0].$2}-${two[1].$2}',
      visual: g.visual,
      explanation:
          '${cap(two[0].$1)} has ${two[0].$2} and ${two[1].$1} has '
          '${two[1].$2}. ${two[0].$2} − ${two[1].$2} = $d.',
    );
  }),
  Template('p2.graphs', 'total', 12, (r, level) {
    final scale = pick(r, [2, 5, 10]);
    final g = graph(r, level, scale, maxPictures: 6);
    final pics = g.rows.map((x) => x.$2 ~/ scale).toList();
    final sum = pics.fold(0, (a, b) => a + b);
    return Draft.number(
      'Each picture stands for $scale children. '
      'How many children are shown in all?',
      sum * scale,
      check: '(${pics.join('+')})*$scale',
      visual: g.visual,
      explanation:
          'There are $sum pictures in all. $sum × $scale = ${sum * scale}.',
    );
  }),
  Template('p2.graphs', 'most', 12, (r, level) {
    final scale = pick(r, [2, 5, 10]);
    final g = graph(r, level, scale, maxPictures: 8);
    final most = r.nextBool();
    final counts = g.rows.map((x) => x.$2).toList();
    final best = most ? counts.reduce(max) : counts.reduce(min);
    final ans = g.rows.firstWhere((x) => x.$2 == best).$1;
    return Draft.mcq(
      r,
      'Each picture stands for $scale children. '
      'Which ${g.thing} did exactly $best children choose?',
      ans,
      [for (final x in g.rows) x.$1],
      visual: g.visual,
      explanation:
          '$best ÷ $scale = ${best ~/ scale} pictures. '
          'The row for $ans has ${best ~/ scale} pictures.',
    );
  }),
  Template('p2.graphs', 'pictures', 12, (r, level) {
    final scale = [2, 5, 10][level - 1];
    final n = rint(r, 2, 10);
    final thing = pick(r, const ['children', 'books', 'cars', 'birds']);
    return Draft.number(
      'In a picture graph, each picture stands for $scale $thing. '
      'How many pictures are needed to show ${n * scale} $thing?',
      n,
      check: '${n * scale}/$scale',
      explanation: '${n * scale} ÷ $scale = $n pictures.',
    );
  }),

  // p2.words: 1- and 2-step word problems.
  Template('p2.words', 'packets', 12, (r, level) {
    final (name, he) = child(r);
    final p = rint(r, 2, 5), each = pick(r, [2, 3, 4, 5, 10]);
    final give = rint(r, 1, p * each - 1);
    if (level == 1) {
      return Draft.number(
        '$name buys $p packets of stickers. Each packet has $each stickers. '
        'How many stickers does $he buy?',
        p * each,
        check: '$p*$each',
        explanation: '$p × $each = ${p * each}.',
      );
    }
    return Draft.number(
      '$name buys $p packets of stickers. Each packet has $each stickers. '
      '${cap(he)} gives $give stickers to a friend. '
      'How many stickers does $he have left?',
      p * each - give,
      check: '$p*$each-$give',
      explanation:
          'First $p × $each = ${p * each}. Then ${p * each} − $give = '
          '${p * each - give}.',
    );
  }),
  Template('p2.words', 'share-rest', 12, (r, level) {
    final (name, he) = child(r);
    final jars = pick(r, [2, 3, 4, 5]);
    final each = rint(r, 2, 10);
    final keep = rint(r, 1, 9);
    final total = jars * each + keep;
    return Draft.number(
      '$name has $total marbles. ${cap(he)} keeps $keep and puts the rest '
      'equally into $jars jars. How many marbles are in each jar?',
      each,
      check: '($total-$keep)/$jars',
      explanation:
          '$total − $keep = ${total - keep}. ${total - keep} ÷ $jars = $each.',
    );
  }),
  Template('p2.words', 'altogether', 12, (r, level) {
    final two = pickN(r, names, 2);
    final a = rint(r, 100, 400), more = rint(r, 20, 150);
    final b = a + more;
    if (a + b > 999) retry();
    final thing = pick(r, const ['beads', 'shells', 'stamps']);
    if (level == 1) {
      return Draft.number(
        '${two[0]} has $a $thing. ${two[1]} has $more more $thing than '
        '${two[0]}. How many $thing does ${two[1]} have?',
        b,
        check: '$a+$more',
        explanation: '$a + $more = $b.',
      );
    }
    return Draft.number(
      '${two[0]} has $a $thing. ${two[1]} has $more more $thing than '
      '${two[0]}. How many $thing do they have altogether?',
      a + b,
      check: '$a+($a+$more)',
      explanation:
          '${two[1]} has $a + $more = $b. Altogether: $a + $b = ${a + b}.',
    );
  }),
  Template('p2.words', 'change', 12, (r, level) {
    final (name, he) = child(r);
    final price = rint(r, 2, 6), n = rint(r, 2, 5);
    final paid = [10, 20, 50].firstWhere((p) => p > price * n);
    final thing = pick(r, const ['pens', 'cupcakes', 'notebooks', 'balls']);
    return Draft.number(
      'Each of the $thing costs \$$price. $name buys $n $thing and pays '
      'with a \$$paid note. How much change does $he get, in dollars?',
      paid - price * n,
      check: '$paid-$n*$price',
      explanation:
          '$n × \$$price = \$${price * n}. \$$paid − \$${price * n} = '
          '\$${paid - price * n}.',
    );
  }),
  Template('p2.words', 'cut', 12, (r, level) {
    final pieces = pick(r, [2, 3, 4, 5, 10]);
    final each = rint(r, 2, level == 3 ? 20 : 10) * (level == 1 ? 1 : 5);
    final total = pieces * each;
    const unit = 'cm';
    return Draft.mcq(
      r,
      'A ribbon is $total $unit long. It is cut into $pieces equal pieces. '
          'How long is each piece?',
      '$each $unit',
      [
        '${total - pieces} $unit',
        '${each + pieces} $unit',
        '${total * pieces} $unit',
        '${each * 2} $unit',
      ],
      explanation: '$total ÷ $pieces = $each, so each piece is $each $unit.',
    );
  }),
];

/// `3:05`.
String clock(int h, int m) => '$h:${m.toString().padLeft(2, '0')}';

/// [minutes] after midnight as `3:05 p.m.`.
String clock12(int minutes) {
  final t = minutes % (24 * 60);
  final h = t ~/ 60, m = t % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '${clock(h12, m)} ${h < 12 ? 'a.m.' : 'p.m.'}';
}
