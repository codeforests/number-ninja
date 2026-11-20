import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/family.dart';

void main() {
  test('an empty nickname shows as Player N (FEAT-25 AD-2)', () {
    expect(displayName('', 0), 'Player 1');
    expect(displayName('  ', 2), 'Player 3');
    expect(displayName(' Mia ', 0), 'Mia');
  });

  test('new children get the first unused avatar (AD-7)', () {
    expect(nextAvatar([]), avatarIds.first);
    expect(nextAvatar(['fox', 'cat']), 'owl');
    expect(nextAvatar(avatarIds), avatarIds.first);
    expect(avatarIds.toSet(), hasLength(avatarIds.length));
    expect(avatarIds.length, greaterThanOrEqualTo(maxChildren));
  });
}
