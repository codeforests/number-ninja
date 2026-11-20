import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/crash.dart';

void main() {
  const stack =
      '#0      Foo.bar (package:x/a.dart:10:5)\n'
      '#1      Baz.qux (package:x/b.dart:20:7)\n'
      '#2      main (package:x/main.dart:3:1)\n';

  test('signature ignores column numbers and frames past the fifth', () {
    final moved = stack.replaceAll(':10:5)', ':10:9)');
    expect(
      crashSignature('StateError', stack),
      crashSignature('StateError', moved),
    );
    final deep = List.generate(8, (i) => '#$i f (a.dart:$i:1)').join('\n');
    final deeper = '$deep\n#8 g (b.dart:1:1)';
    expect(crashSignature('E', deep), crashSignature('E', deeper));
  });

  test('signature differs by type and by line', () {
    expect(crashSignature('A', stack), isNot(crashSignature('B', stack)));
    final otherLine = stack.replaceAll(':10:5)', ':11:5)');
    expect(crashSignature('A', stack), isNot(crashSignature('A', otherLine)));
  });

  test('scrubText replaces names and email, case-insensitive (AC-2)', () {
    final out = scrubText(
      'Bad nickname MIA for mia tan, mail Ken@Example.com',
      ['Mia', 'Mia Tan', 'x'],
      'ken@example.com',
    );
    expect(out, 'Bad nickname <name> for <name>, mail <email>');
  });

  test('scrubText leaves one-letter names alone', () {
    expect(scrubText('a b c', ['a'], null), 'a b c');
  });

  test('trimStack keeps whole top lines; trimMessage caps (AC-2)', () {
    final long = List.generate(500, (i) => '#$i frame line $i').join('\n');
    final t = trimStack(long);
    expect(t.length, lessThanOrEqualTo(crashStackMax));
    expect(t.startsWith('#0 frame line 0\n'), isTrue);
    expect(long.contains('$t\n'), isTrue);
    expect(trimMessage('x' * 5000).length, crashMessageMax);
    expect(trimMessage('short'), 'short');
    expect(trimText('y' * 300).length, crashTextMax);
  });
}
