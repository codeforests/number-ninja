import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/stars.dart';

void main() {
  test('starsFor follows design §5 (AC-5)', () {
    expect(starsFor(10), 3);
    expect(starsFor(9), 2);
    expect(starsFor(8), 2);
    expect(starsFor(7), 1);
    expect(starsFor(6), 1);
    expect(starsFor(5), 0);
    expect(starsFor(0), 0);
  });
}
