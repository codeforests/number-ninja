import 'dart:math';

/// A whole number from [lo] to [hi], both included.
int rint(Random r, int lo, int hi) => lo + r.nextInt(hi - lo + 1);

T pick<T>(Random r, List<T> xs) => xs[r.nextInt(xs.length)];

/// [n] different values from [xs], in random order.
List<T> pickN<T>(Random r, List<T> xs, int n) =>
    (List.of(xs)..shuffle(r)).take(n).toList();

/// [n] different whole numbers from [lo] to [hi].
List<int> distinct(Random r, int n, int lo, int hi) {
  final s = <int>{};
  while (s.length < n) {
    s.add(rint(r, lo, hi));
  }
  return s.toList();
}

const girls = ['Mei', 'Siti', 'Aisha', 'Hui Min', 'Priya'];
const boys = ['Ravi', 'Jun Wei', 'Ben', 'Ahmad', 'Daniel'];
const names = [...girls, ...boys];

/// A child's name with the matching pronoun ("she" or "he").
(String, String) child(Random r) =>
    r.nextBool() ? (pick(r, girls), 'she') : (pick(r, boys), 'he');

/// `she` → `She`.
String cap(String s) => s[0].toUpperCase() + s.substring(1);

/// `$3.05` for 305 cents.
String dollars(int cents) =>
    '\$${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

/// `3.05` for 305 cents: a typed answer in dollars.
String dollarAnswer(int cents) => (cents / 100).toStringAsFixed(2);

/// `45¢` below a dollar, else `$1.20`.
String money(int cents) => cents < 100 ? '$cents¢' : dollars(cents);

/// Whether a + b carries in any column.
bool carries(int a, int b) {
  while (a > 0 || b > 0) {
    if (a % 10 + b % 10 >= 10) return true;
    a ~/= 10;
    b ~/= 10;
  }
  return false;
}

/// Whether a − b borrows in any column (a ≥ b).
bool borrows(int a, int b) {
  while (b > 0) {
    if (a % 10 < b % 10) return true;
    a ~/= 10;
    b ~/= 10;
  }
  return false;
}

/// a + b without carrying: the usual mistake, used as a distractor.
int addNoCarry(int a, int b) {
  var out = 0, place = 1;
  while (a > 0 || b > 0) {
    out += (a % 10 + b % 10) % 10 * place;
    a ~/= 10;
    b ~/= 10;
    place *= 10;
  }
  return out;
}

/// a − b taking the smaller digit from the larger in each column: the usual
/// mistake, used as a distractor.
int subNoBorrow(int a, int b) {
  var out = 0, place = 1;
  while (a > 0 || b > 0) {
    out += (a % 10 - b % 10).abs() * place;
    a ~/= 10;
    b ~/= 10;
    place *= 10;
  }
  return out;
}

/// `1 apple`, `3 apples`.
String plural(int n, String one, [String? many]) =>
    n == 1 ? '1 $one' : '$n ${many ?? '${one}s'}';

/// Shape names drawn by the `shapes` visual.
const shapeNames = ['circle', 'square', 'triangle', 'rectangle'];
const shapeColors = ['red', 'blue', 'yellow', 'green'];

/// Repeating pattern units for shape-pattern questions.
List<String> patternUnit(Random r, int level) {
  final n = level == 1 ? 2 : 3;
  final pool = pickN(r, shapeNames, n);
  if (level == 3 && r.nextBool()) return [pool[0], pool[0], pool[1]];
  if (level == 3) return [pool[0], pool[1], pool[1], pool[2]];
  return pool;
}

/// `{shape, color}` items for a shapes visual; one colour per shape name.
List<Map<String, dynamic>> shapeItems(
  List<String> seq,
  Map<String, String> c,
) => [
  for (final s in seq) {'shape': s, 'color': c[s]},
];

Map<String, String> colorFor(Random r, List<String> shapes) {
  final cs = List.of(shapeColors)..shuffle(r);
  final m = <String, String>{};
  for (final s in shapes) {
    m.putIfAbsent(s, () => cs[m.length % cs.length]);
  }
  return m;
}
