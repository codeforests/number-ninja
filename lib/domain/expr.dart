/// Evaluates small arithmetic expressions such as `(456+278)` or `24/4*3`
/// for the bank's answer check (BNK-04). Supports + - * /, brackets, unary
/// minus and decimals. Throws [FormatException] on anything else.
num evaluate(String source) => _Parser(source.replaceAll(' ', '')).parse();

class _Parser {
  _Parser(this.s);

  final String s;
  int i = 0;

  num parse() {
    final v = _expr();
    if (i != s.length) throw FormatException('Unexpected "${s[i]}"', s, i);
    return v;
  }

  num _expr() {
    var v = _term();
    while (i < s.length && (s[i] == '+' || s[i] == '-')) {
      final op = s[i++];
      final r = _term();
      v = op == '+' ? v + r : v - r;
    }
    return v;
  }

  num _term() {
    var v = _factor();
    while (i < s.length && (s[i] == '*' || s[i] == '/')) {
      final op = s[i++];
      final r = _factor();
      if (op == '*') {
        v = v * r;
      } else {
        if (r == 0) throw FormatException('Division by zero', s, i);
        v = v / r;
      }
    }
    return v;
  }

  num _factor() {
    if (i >= s.length) throw FormatException('Unexpected end', s, i);
    if (s[i] == '-') {
      i++;
      return -_factor();
    }
    if (s[i] == '(') {
      i++;
      final v = _expr();
      if (i >= s.length || s[i] != ')') {
        throw FormatException('Missing )', s, i);
      }
      i++;
      return v;
    }
    final start = i;
    while (i < s.length && RegExp(r'[0-9.]').hasMatch(s[i])) {
      i++;
    }
    if (start == i) throw FormatException('Expected a number', s, i);
    return num.parse(s.substring(start, i));
  }
}
